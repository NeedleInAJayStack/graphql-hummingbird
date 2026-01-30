import GraphQL
import Hummingbird

extension GraphQLJSONEncoder: @retroactive ResponseEncoder {
    /// Extend GraphQLJSONEncoder to support generating a ``HummingbirdCore/Response``. Sets body and header values
    /// - Parameters:
    ///   - value: Value to encode
    ///   - request: Request used to generate response
    ///   - context: Request context
    public func encode(_ value: some Encodable, from _: Request, context _: some RequestContext) throws -> Response {
        let data = try encode(value)
        let buffer = ByteBuffer(bytes: data)
        return Response(
            status: .ok,
            headers: [
                .contentType: "\(MediaType.applicationJsonGraphQL); charset=utf-8",
                .contentLength: data.count.description,
            ],
            body: .init(byteBuffer: buffer)
        )
    }
}
