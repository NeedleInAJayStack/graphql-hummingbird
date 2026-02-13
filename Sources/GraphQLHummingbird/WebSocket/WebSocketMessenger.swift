import GraphQLTransportWS
import GraphQLWS
import HummingbirdWebSocket
import Logging
import NIOCore

/// Messenger wrapper for WebSockets
class WebSocketMessenger: GraphQLTransportWS.Messenger, GraphQLWS.Messenger, @unchecked Sendable {
    private let outbound: WebSocketOutboundWriter
    private let logger: Logger

    init(
        outbound: WebSocketOutboundWriter,
        logger: Logger
    ) {
        self.outbound = outbound
        self.logger = logger
    }

    func send<S: Collection>(_ message: S) async throws where S.Element == Character {
        logger.trace("GraphQL server sent: \(String(message))")
        try await outbound.write(.text(String(message)))
    }

    func error(_ message: String, code: Int) async throws {
        try await outbound.close(.init(codeNumber: code), reason: message)
    }

    func close() async throws {
        try await outbound.close(.goingAway, reason: nil)
    }
}
