import Foundation
import UIKit

public protocol RouterServiceProtocol: Dependency, RouterServiceAnyRouteDecodingProtocol {
    func navigate(
        toRoute route: Route,
        fromView viewController: UIViewController,
        presentationStyle: PresentationStyle,
        animated: Bool
    )
}

public typealias DependencyFactory = () -> Dependency

public protocol RouterServiceRegistrationProtocol {
    func register<T>(dependencyFactory: @escaping DependencyFactory, forType metaType: T.Type)
    func register(routeHandler: RouteHandler)
}

public protocol RouterServiceScopeProtocol {
    func register(scope: String)
    func enter(scope: String)
    func leave(scope: String)
}
