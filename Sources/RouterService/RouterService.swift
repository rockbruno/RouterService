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
        register(dependencyFactory: { [unowned self] in
            self
        }, forType: RouterServiceProtocol.self)
    }

    public func register<T>(
        dependencyFactory: @escaping DependencyFactory,
        forType metaType: T.Type
    ) {
        store.register(dependencyFactory, forMetaType: metaType)
    }

    public func register(routeHandler: RouteHandler) {
        routeHandler.routes.forEach {
            registeredRoutes[$0.identifier] = ($0.asAnyRouteType, routeHandler)
        }
    }

    public func navigationController(
        withInitialFeature feature: Feature.Type
    ) -> UINavigationController {
        let instance = feature.initialize(withStore: store)
        let rootViewController = instance.build(fromRoute: nil)
        return UINavigationController(rootViewController: rootViewController)
    }

    public func navigate(
        toRoute route: Route,
        fromView viewController: UIViewController,
        presentationStyle: PresentationStyle,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        guard let handler = handler(forRoute: route) else {
            failureHandler()
            return
        }
        let destinationFeatureType = handler.destination(
            forRoute: route,
            fromViewController: viewController
        )
        let destinationFeature = destinationFeatureType.initialize(withStore: store)
        let destinationViewController: UIViewController
        
        if destinationFeature.isEnabled() {
            destinationViewController = destinationFeature.build(fromRoute: route)
        } else {
            let fallbackFeatureType = destinationFeature.fallback(forRoute: route)
            guard let fallbackDestinationFeature = fallbackFeatureType?.initialize(withStore: store) else {
                failureHandler()
                return
            }
            
            destinationViewController = fallbackDestinationFeature.build(fromRoute: route)
        }
        
        presentationStyle.present(
            viewController: destinationViewController,
            fromViewController: viewController,
            animated: animated,
            completion: completion
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
