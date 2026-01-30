import GraphQL
import struct GraphQLTransportWS.EmptyInitPayload
import class GraphQLTransportWS.Server
import class GraphQLWS.Server
import Hummingbird
import HummingbirdWebSocket
import Logging

extension GraphQLHandler {
    func handleWebSocket(
        inbound: WebSocketInboundStream,
        outbound: WebSocketOutboundWriter,
        graphqlContext: GraphQLContext,
        subProtocol: WebSocketSubProtocol,
        logger: Logger
    ) async throws {
        let messenger = WebSocketMessenger(inbound: inbound, outbound: outbound, logger: logger)

        switch subProtocol {
        case .graphqlTransportWs:
            // https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md
            let server = GraphQLTransportWS.Server<WebSocketInit, AsyncThrowingStream<GraphQLResult, Error>>(
                messenger: messenger,
                onExecute: { graphQLRequest in
                    try await graphql(
                        schema: self.schema,
                        request: graphQLRequest.query,
                        rootValue: self.rootValue,
                        context: graphqlContext,
                        variableValues: graphQLRequest.variables,
                        operationName: graphQLRequest.operationName
                    )
                },
                onSubscribe: { graphQLRequest in
                    try await graphqlSubscribe(
                        schema: self.schema,
                        request: graphQLRequest.query,
                        rootValue: self.rootValue,
                        context: graphqlContext,
                        variableValues: graphQLRequest.variables,
                        operationName: graphQLRequest.operationName
                    ).get()
                }
            )
            server.onMessage { message in
                logger.trace("GraphQL server received: \(String(message))")
            }
            server.auth(config.websocket.onWebsocketInit)
        case .graphqlWs:
            // https://github.com/apollographql/subscriptions-transport-ws/blob/master/PROTOCOL.md
            let server = GraphQLWS.Server<WebSocketInit, AsyncThrowingStream<GraphQLResult, Error>>(
                messenger: messenger,
                onExecute: { graphQLRequest in
                    try await graphql(
                        schema: self.schema,
                        request: graphQLRequest.query,
                        rootValue: self.rootValue,
                        context: graphqlContext,
                        variableValues: graphQLRequest.variables,
                        operationName: graphQLRequest.operationName
                    )
                },
                onSubscribe: { graphQLRequest in
                    try await graphqlSubscribe(
                        schema: self.schema,
                        request: graphQLRequest.query,
                        rootValue: self.rootValue,
                        context: graphqlContext,
                        variableValues: graphQLRequest.variables,
                        operationName: graphQLRequest.operationName
                    ).get()
                }
            )
            server.onMessage { message in
                logger.trace("GraphQL server received: \(String(message))")
            }
            server.auth(config.websocket.onWebsocketInit)
        }
        try await messenger.start()
    }
}
