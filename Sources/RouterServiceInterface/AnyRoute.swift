import Foundation

/// A type-erased container for a `Route`, used for route decoding purposes.
public struct AnyRoute: Identifiable {
    public let value: Route
    public let routeString: String
    
    public var id: String { routeString }
}

extension AnyRoute: Decodable {
    static var contextUserInfoKey: CodingUserInfoKey {
        // swiftlint:disable:next force_unwrapping
        return CodingUserInfoKey(rawValue: "routerservice_anyroute_context")!
    }

    public init(from decoder: Decoder) throws {
        let ctx = decoder.userInfo[AnyRoute.contextUserInfoKey]

        guard let context = ctx as? RouterServiceAnyRouteDecodingProtocol else {
            preconditionFailure("TRIED TO DECODE ANYROUTE WITHOUT A CONTEXT!")
        }

        let data = try context.decodeAnyRoute(fromDecoder: decoder)

        self.value = data.0
        self.routeString = data.1
    }
}

public protocol RouterServiceAnyRouteDecodingProtocol {
    func decodeAnyRoute(fromDecoder decoder: Decoder) throws -> (Route, String)
}

extension RouterServiceAnyRouteDecodingProtocol {
    /// Injects contextual data in a `JSONDecoder`. This is necessary for decoding `AnyRoutes`s.
    public func injectContext(toDecoder decoder: JSONDecoder) {
        decoder.userInfo[AnyRoute.contextUserInfoKey] = self
    }
}
