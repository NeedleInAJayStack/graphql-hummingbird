import GraphQL
import Hummingbird

struct GraphQLHandler<
    Context: RequestContext,
    GraphQLContext: Sendable,
    WebSocketInit: Equatable & Codable & Sendable
>: Sendable {
    let schema: GraphQLSchema
    let rootValue: any Sendable
    let config: GraphQLConfig<WebSocketInit>
    let computeContext: @Sendable (Request, Context) async throws -> GraphQLContext
}
