import GraphQL
import Hummingbird

struct GraphQLHandler<
    Context: RequestContext,
    GraphQLContext: Sendable,
    WebSocketInit: Equatable & Codable & Sendable,
    WebSocketInitResult: Sendable
>: Sendable {
    let schema: GraphQLSchema
    let rootValue: any Sendable
    let config: GraphQLConfig<WebSocketInit, WebSocketInitResult>
    let computeContext: @Sendable (GraphQLContextComputationInputs<Context, WebSocketInitResult>) async throws -> GraphQLContext
}

public struct GraphQLContextComputationInputs<
    Context: RequestContext,
    WebSocketInitResult: Sendable
>: Sendable {
    public let hummingbirdRequest: Request
    public let hummingbirdContext: Context
    public let graphQLRequest: GraphQLRequest
    public let websocketInitResult: WebSocketInitResult?
}
