import XCTest
import RouterServiceInterface

@testable import RouterService

final class RouterServiceTests: XCTestCase {

    func test_routerService_automaticallyRegistersProtocolOfItself() {
        let service = RouterService()
        let storedInstance = service.store.get(RouterServiceProtocol.self)

        XCTAssertTrue(service === storedInstance as? RouterService)
    }

    func test_routerServiceRegister_callsStore() {
        let storeSpy = RouterServiceDoubles.StoreSpy()
        let service = RouterService(store: storeSpy)

        let dep = RouterServiceDoubles.MockConcreteDependency()
        let depFactory: DependencyFactory = { dep }
        service.register(dependencyFactory: depFactory, forType: RouterServiceDoubles.MockConcreteDependency.self)

        XCTAssertTrue(
            storeSpy.registerArgumentPassed?() === dep
        )

        XCTAssertNotNil(
            storeSpy.registerMetaTypePassed == RouterServiceDoubles.MockConcreteDependency.self
        )
    }

    func test_routerService_hasNoHandlerForRouteIfHandlerIsUnregistered() {
        let service = RouterService()

        let fooRoute = RouterServiceDoubles.MockRouteFromFooHandler()
        let anotherFooRoute = RouterServiceDoubles.AnotherMockRouteFromFooHandler()
        let barRoute = RouterServiceDoubles.MockRouteFromBarHandler()

        XCTAssertNil(service.handler(forRoute: fooRoute))
        XCTAssertNil(service.handler(forRoute: anotherFooRoute))
        XCTAssertNil(service.handler(forRoute: barRoute))
    }

    func test_routerService_hasHandlerForRouteIfHandlerIsRegistered() {
        let service = RouterService()

        let fooRoute = RouterServiceDoubles.MockRouteFromFooHandler()
        let anotherFooRoute = RouterServiceDoubles.AnotherMockRouteFromFooHandler()
        let barRoute = RouterServiceDoubles.MockRouteFromBarHandler()

        let fooHandler = RouterServiceDoubles.FooHandler()
        let barHandler = RouterServiceDoubles.BarHandler()

        service.register(routeHandler: fooHandler)
        service.register(routeHandler: barHandler)

        XCTAssertTrue(
            service.handler(forRoute: fooRoute) as? RouterServiceDoubles.FooHandler === fooHandler
        )
        XCTAssertTrue(
            service.handler(forRoute: anotherFooRoute) as? RouterServiceDoubles.FooHandler === fooHandler
        )
        XCTAssertTrue(
            service.handler(forRoute: barRoute) as? RouterServiceDoubles.BarHandler === barHandler
        )
    }

    func test_routerService_failsToRouteIfTheresNoHandler() {
        var didFail = false
        let service = RouterService(failureHandler: {
            didFail = true
        })

        let route = RouterServiceDoubles.MockRouteFromFooHandler()
        service.navigate(toRoute: route, fromView: UIViewController(), presentationStyle: Push(), animated: false)

        XCTAssertTrue(didFail)
    }

    func test_routerService_suceedsRoutingIfTheresHandler() {

        var didFail = false
        let service = RouterService(failureHandler: {
            didFail = true
        })

        let dep = RouterServiceDoubles.MockConcreteDependency()
        let depFactory: DependencyFactory = { dep }
        service.register(dependencyFactory: depFactory, forType: RouterServiceDoubles.MockConcreteDependency.self)
        service.register(dependencyFactory: depFactory, forType: MockDependencyProtocol.self)

        let fooHandler = RouterServiceDoubles.FooHandler()
        service.register(routeHandler: fooHandler)

        let vc = UIViewController(nibName: nil, bundle: nil)
        let navigation = UINavigationController(rootViewController: vc)

        let route = RouterServiceDoubles.MockRouteFromFooHandler()
        service.navigate(toRoute: route, fromView: vc, presentationStyle: Push(), animated: false)

        let pushedVC = navigation.viewControllers.last
        guard let featureVC = pushedVC as? RouterServiceDoubles.FeatureViewControllerSpy else {
            XCTFail()
            return
        }

        XCTAssertFalse(didFail)
        XCTAssertTrue(featureVC.routePassed is RouterServiceDoubles.MockRouteFromFooHandler)
    }

    func test_routerService_navigationControllerProvider() {
        let service = RouterService()

        let dep = RouterServiceDoubles.MockConcreteDependency()
        let depFactory: DependencyFactory = { dep }
        service.register(dependencyFactory: depFactory, forType: RouterServiceDoubles.MockConcreteDependency.self)
        service.register(dependencyFactory: depFactory, forType: MockDependencyProtocol.self)

        let feature = RouterServiceDoubles.FeatureSpyWithNoDependencies.self
        let nav = service.navigationController(withInitialFeature: feature)
        let viewController = nav.viewControllers.first as? RouterServiceDoubles.FeatureViewControllerSpy

        XCTAssertNotNil(viewController)
        XCTAssertNil(viewController?.routePassed)
        XCTAssertNotNil(viewController?.dependenciesPassed)
    }
}
