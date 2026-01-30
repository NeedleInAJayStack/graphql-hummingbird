# GraphQLHummingbird

***WARNING***: This package is in v0.x beta. It's API is still evolving and is subject to breaking changes in minor version bumps.

A Swift library for integrating [GraphQL](https://github.com/GraphQLSwift/GraphQL) with [Hummingbird](https://github.com/hummingbird-project/hummingbird), enabling you to easily expose GraphQL APIs in your Hummingbird applications.

## Features

- Simple integration of GraphQL schemas with Hummingbird routing
- Compatibility with the [GraphQL over HTTP spec](https://github.com/graphql/graphql-over-http/blob/main/spec/GraphQLOverHTTP.md)
- Subscription support using WebSockets, with support for [`graphql-transport-ws`](https://github.com/GraphQLSwift/GraphQLTransportWS) and [`graphql-ws`](https://github.com/apollographql/subscriptions-transport-ws/blob/master/PROTOCOL.md) subprotocols
- Built-in [GraphiQL](https://github.com/graphql/graphiql) IDE

## Installation

Add GraphQLHummingbird as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/NeedleInAJayStack/graphql-hummingbird.git", from: "1.0.0"),
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "GraphQLHummingbird", package: "graphql-hummingbird"),
    ]
)
```

## Usage

### Basic Example

```swift
import GraphQL
import GraphQLHummingbird
import Hummingbird

// Define your GraphQL schema
let schema = try GraphQLSchema(
    query: GraphQLObjectType(
        name: "Query",
        fields: [
            "hello": GraphQLField(
                type: GraphQLString,
                resolve: { _, _, _, _ in
                    "World"
                }
            )
        ]
    )
)

// Define your Context
struct GraphQLContext: Sendable {}

// Create router and register GraphQL
let router = Router()
router.graphql(schema: schema) { _, _ in
    return GraphQLContext()
}

// Create and run the application
let app = Application(
    router: router,
    configuration: .init(address: .hostname("127.0.0.1", port: 8080))
)
try await app.runService()
```

Now just run the application! You can view the GraphiQL IDE at `/graphql`, or query directly using `GET` or `POST`:

```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ hello }"}'
```

Response:
```json
{
  "data": {
    "hello": "World"
  }
}
```

See the `RouterMethods.graphql` function documentation for advanced configuration options.

To build a type-safe GraphQL schema, consider [`graphql-generator`](https://github.com/GraphQLSwift/graphql-generator) or
[`Graphiti`](https://github.com/GraphQLSwift/Graphiti)
