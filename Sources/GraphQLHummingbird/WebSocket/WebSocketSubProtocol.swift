/// Supported websocket sub-protocols
public enum WebSocketSubProtocol: String, Codable, CaseIterable, Sendable {
    case graphqlTransportWs = "graphql-transport-ws"
    case graphqlWs = "graphql-ws"
}
