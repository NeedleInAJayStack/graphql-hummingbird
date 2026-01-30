import GraphQLTransportWS
import GraphQLWS
import HummingbirdWebSocket
import Logging
import NIOCore

/// Messenger wrapper for WebSockets
class WebSocketMessenger: GraphQLTransportWS.Messenger, GraphQLWS.Messenger, @unchecked Sendable {
    private let inbound: WebSocketInboundStream
    private let outbound: WebSocketOutboundWriter
    private let logger: Logger

    private var onReceive: (String) async throws -> Void = { _ in }

    init(
        inbound: WebSocketInboundStream,
        outbound: WebSocketOutboundWriter,
        logger: Logger
    ) {
        self.inbound = inbound
        self.outbound = outbound
        self.logger = logger
    }

    /// A blocking method to start listening to the inbound messages and bind them to the onReceive callback
    func start() async throws {
        // TODO: Make maxSize configurable
        for try await message in inbound.messages(maxSize: 1024 * 1024) {
            guard case let .text(text) = message else { continue }
            do {
                try await onReceive(text)
            } catch {
                try? await self.error("\(error)", code: 4400)
            }
        }
    }

    func send<S: Collection>(_ message: S) async throws where S.Element == Character {
        logger.trace("GraphQL server sent: \(String(message))")
        try await outbound.write(.text(String(message)))
    }

    func onReceive(callback: @escaping (String) async throws -> Void) {
        onReceive = callback
    }

    func error(_ message: String, code: Int) async throws {
        try await outbound.close(.init(codeNumber: code), reason: message)
    }

    func close() async throws {
        try await outbound.close(.goingAway, reason: nil)
    }
}
