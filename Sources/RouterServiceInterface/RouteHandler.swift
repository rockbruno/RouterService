import UIKit

public protocol RouteHandler {
    var routes: [Route.Type] { get }

    func destination(
        forRoute route: Route,
        fromViewController viewController: UIViewController
    ) -> Feature.Type
}
