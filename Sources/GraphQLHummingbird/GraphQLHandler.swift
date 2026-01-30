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

    init(
        schema: GraphQLSchema,
        rootValue: any Sendable,
        config: GraphQLConfig<WebSocketInit>,
        computeContext: @Sendable @escaping (Request, Context) async throws -> GraphQLContext
    ) {
        self.schema = schema
        self.rootValue = rootValue
        self.config = config
        self.computeContext = computeContext
    }
}
