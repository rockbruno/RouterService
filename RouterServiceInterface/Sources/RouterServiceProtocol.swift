import Foundation
import UIKit

public typealias RouterServiceProtocol = RouterServiceNavigationProtocol & RouterServiceRegistrationProtocol

public protocol RouterServiceNavigationProtocol: Dependency {
    func navigate(
        toRoute route: Route,
        fromView viewController: UIViewController,
        presentationStyle: PresentationStyle,
        animated: Bool
    )
}

public protocol RouterServiceRegistrationProtocol {
    func register<T>(dependency: Dependency, forType metaType: T.Type)
    func register(routeHandler: RouteHandler)
}
