import UIKit

import RouterService
import RouterServiceInterface

import HTTPClient
import HTTPClientInterface

import FeatureFlag
import FeatureFlagInterface

import FeatureOne
import FeatureTwo

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let routerService = RouterService()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        routerService.register(dependencyFactory: {
            return HTTPClient()
        }, forType: HTTPClientProtocol.self)

        routerService.register(dependencyFactory: {
            return FeatureFlag()
        }, forType: FeatureFlagProtocol.self)

        routerService.register(routeHandler: FeatureTwoRouteHandler())

        let nav = routerService.navigationController(
            withInitialFeature: FeatureOne.self
        )

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}
