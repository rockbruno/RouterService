import UIKit
import RouterService
import RouterServiceInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let routerService = RouterService()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        window = UIWindow(windowScene: windowScene)

        routerService.register(
            dependencyFactory: { HTTPClient() },
            forType: HTTPClientProtocol.self
        )
        routerService.register(routeHandler: MainRouteHandler())

        let nav = routerService.navigationController(withInitialFeature: MainFeature.self
        )

        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}

protocol HTTPClientProtocol: Dependency {}
class HTTPClient: HTTPClientProtocol {}

class MainRouteHandler: RouteHandler {
    var routes: [Route.Type] {
        return [MainRoute.self]
    }

    func destination(forRoute route: Route, fromViewController viewController: UIViewController) -> AnyFeature {
        return AnyFeature(MainFeature.self)
    }
}

struct MainRoute: Route {
    static var identifier: String {
        return "main"
    }

    let backgroundColorHex: String
}
