import Foundation
import RouterServiceInterface
import UIKit

public final class RouterService: RouterServiceProtocol {

    let store: StoreInterface
    let failureHandler: () -> Void

    var handlersForRoutes = [String: RouteHandler]()

    public init(
        store: StoreInterface? = nil,
        failureHandler: @escaping () -> Void = { fatalError() }
    ) {
        self.store = store ?? Store()
        self.failureHandler = failureHandler
        register(dependency: self, forType: RouterServiceNavigationProtocol.self)
    }

    public func register<T>(dependency: Dependency, forType metaType: T.Type) {
        store.register(dependency, forMetaType: metaType)
    }

    public func register(routeHandler: RouteHandler) {
        routeHandler.routes.forEach {
            handlersForRoutes[$0.identifier] = routeHandler
        }
    }

    public func navigationController<T: Feature>(
        withInitialFeature feature: T.Type
    ) -> UINavigationController {
        let rootViewController = AnyFeature(feature).build(store, nil, .push)
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
        ).build(store, route, presentationStyle)
        switch presentationStyle {
        case .push:
            viewController.navigationController?.pushViewController(newVC, animated: animated)
        case .defaultModal:
            viewController.present(newVC, animated: animated, completion: nil)
        case .customModal(let modalStyle):
            viewController.modalPresentationStyle = modalStyle
            viewController.present(newVC, animated: animated, completion: nil)
        }
    }

    func handler(forRoute route: Route) -> RouteHandler? {
        let routeIdentifier = type(of: route).identifier
        return handlersForRoutes[routeIdentifier]
    }
}
