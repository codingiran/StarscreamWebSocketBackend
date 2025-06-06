//
//  StarscreamWebSocketBackend.swift
//  StarscreamWebSocketBackend
//
//  Created by CodingIran on 2025/5/26.
//

import Foundation
import Starscream
import WebSocketClient

// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.9)
    #error("StarscreamWebSocketBackend doesn't support Swift versions below 5.9")
#endif

public enum StarscreamWebSocketBackendInfo: Sendable {
    /// Current StarscreamWebSocketBackend version.
    public static let version = "0.0.1"
}

public final class StarscreamWebSocketBackend: @unchecked Sendable {
    private var webSocket: WebSocket?

    private var eventContinuation: AsyncStream<WebSocketClientEvent>.Continuation?
}

extension StarscreamWebSocketBackend: WebSocketClientBackend {
    public func connect(request: URLRequest) async {
        webSocket = WebSocket(request: request, useCustomEngine: true)
        webSocket?.delegate = self
        webSocket?.connect()
    }

    public func disconnect(closeCode: WebSocketClientCloseCode, reason _: String?) async {
        guard let webSocket else { return }
        webSocket.disconnect(closeCode: UInt16(closeCode.rawValue))
    }

    public func write(frame: WebSocketClientFrame) async throws {
        guard let webSocket else { return }
        switch frame {
        case let .text(text):
            await withCheckedContinuation { continuation in
                webSocket.write(string: text) {
                    continuation.resume()
                }
            }
        case let .data(data):
            await withCheckedContinuation { continuation in
                webSocket.write(data: data) {
                    continuation.resume()
                }
            }
        case .ping:
            await withCheckedContinuation { continuation in
                webSocket.write(ping: Data()) {
                    continuation.resume()
                }
            }
        }
    }

    public var eventStream: AsyncStream<WebSocketClientEvent> {
        AsyncStream { continuation in
            continuation.onTermination = { _ in
                self.clearContinuation()
            }
            self.eventContinuation = continuation
        }
    }

    func didReceive(event: WebSocketClientEvent) {
        guard let eventContinuation: AsyncStream<WebSocketClientEvent>.Continuation else { return }
        eventContinuation.yield(event)
    }

    func clearContinuation() {
        eventContinuation = nil
    }
}

public extension StarscreamWebSocketBackend {
    enum Error: LocalizedError {
        case unknown
        case cancellation
        case peerClosed

        public var errorDescription: String? {
            switch self {
            case .unknown:
                return "unknown"
            case .cancellation:
                return "cancellation"
            case .peerClosed:
                return "peer closed"
            }
        }
    }
}

extension StarscreamWebSocketBackend: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client _: Starscream.WebSocketClient) {
        switch event {
        case let .connected(dictionary):
            didReceive(event: .connected(dictionary))
        case let .disconnected(reason, closeCode):
            didReceive(event: .disconnected(reason, .init(code: closeCode)))
        case let .text(string):
            didReceive(event: .text(string))
        case let .binary(data):
            didReceive(event: .data(data))
        case .pong:
            didReceive(event: .pong)
        case .ping, .viabilityChanged, .reconnectSuggested:
            break
        case let .error(error):
            didReceive(event: .error(error ?? StarscreamWebSocketBackend.Error.unknown))
        case .cancelled:
            didReceive(event: .error(StarscreamWebSocketBackend.Error.cancellation))
        case .peerClosed:
            didReceive(event: .error(StarscreamWebSocketBackend.Error.peerClosed))
        }
    }
}
