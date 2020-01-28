import Foundation
import RouterServiceInterface
import UIKit

public final class RouterService: RouterServiceProtocol, RouterServiceRegistrationProtocol {

    let store: StoreInterface
    let failureHandler: () -> Void

    private(set) var registeredRoutes = [String: (AnyRouteType, RouteHandler)]()

    public init(
        store: StoreInterface? = nil,
        failureHandler: @escaping () -> Void = { preconditionFailure() }
    ) {
        self.store = store ?? Store()
        self.failureHandler = failureHandler
        register(dependency: self, forType: RouterServiceProtocol.self)
    }

    public func register<T>(dependency: Dependency, forType metaType: T.Type) {
        store.register(dependency, forMetaType: metaType)
    }

    public func register(routeHandler: RouteHandler) {
        routeHandler.routes.forEach {
            registeredRoutes[$0.identifier] = ($0.asAnyRouteType, routeHandler)
        }
    }

    public func navigationController<T: Feature>(
        withInitialFeature feature: T.Type
    ) -> UINavigationController {
        let rootViewController = AnyFeature(feature).build(store, nil)
        return UINavigationController(rootViewController: rootViewController)
    }

    public func navigate(
        toRoute route: Route,
        fromView viewController: UIViewController,
        presentationStyle: PresentationStyle,
        animated: Bool
    ) {
        guard let handler = handler(forRoute: route) else {
            failureHandler()
            return
        }
        let newVC = handler.destination(
            forRoute: route,
            fromViewController: viewController
        ).build(store, route)
        presentationStyle.present(
            viewController: newVC,
            fromViewController: viewController,
            animated: animated
        )
    }

    func handler(forRoute route: Route) -> RouteHandler? {
        let routeIdentifier = type(of: route).identifier
        return registeredRoutes[routeIdentifier]?.1
    }
}

extension RouterService: RouterServiceAnyRouteDecodingProtocol {
    public func decodeAnyRoute(fromDecoder decoder: Decoder) throws -> (Route, String) {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)

        guard let routeString = RouteString(fromString: identifier) else {
            throw RouteDecodingError.failedToParseRouteString
        }

        guard let routeType = registeredRoutes[routeString.scheme]?.0 else {
            throw RouteDecodingError.unregisteredRoute
        }

        do {
            let value = try routeType.decode(JSONDecoder(), routeString.parameterData)
            return (value, routeString.originalString)
        } catch {
            throw error
        }
    }

    public enum RouteDecodingError: Swift.Error {
        case unregisteredRoute
        case failedToParseRouteString
    }
}
