import Foundation
import UIKit

public protocol RouterServiceProtocol: Dependency {
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
