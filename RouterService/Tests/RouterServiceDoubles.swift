import RouterServiceInterface
import UIKit

protocol MockDependencyProtocol: Dependency {}

enum RouterServiceDoubles {
    final class MockConcreteDependency: MockDependencyProtocol {}
    struct MockRoute: Route {}
}

extension RouterServiceDoubles {
    enum FeatureSpy: Feature {
        struct Dependencies {
            let concreteDep: MockConcreteDependency
            let protocolDep: MockDependencyProtocol
        }

        static func build(
            dependencies: FeatureSpy.Dependencies,
            fromRoute route: Route?,
            presentationStyle: PresentationStyle
        ) -> UIViewController {
            return FeatureViewControllerSpy(dependencies: dependencies, route: route)
        }

        static var dependenciesInitializer: AnyDependenciesInitializer {
            return AnyDependenciesInitializer(Dependencies.init)
        }
    }

    final class FeatureViewControllerSpy: UIViewController {

        private(set) var dependenciesPassed: Any?
        private(set) var routePassed: Route?

        init(dependencies: Any?, route: Route?) {
            self.dependenciesPassed = dependencies
            self.routePassed = route
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError()
        }
    }

    final class StoreSpy: StoreInterface {
        func get<T>(_ arg: T.Type) -> T? {
            return nil
        }

        var registerArgumentPassed: Dependency?
        var registerMetaTypePassed: AnyClass?

        func register<T>(_ arg: Dependency, forMetaType metaType: T.Type) {
            registerArgumentPassed = arg
            registerMetaTypePassed = metaType as? AnyClass
        }
    }
}

extension RouterServiceDoubles {

    struct MockRouteFromFooHandler: Route {}
    struct AnotherMockRouteFromFooHandler: Route {}

    final class FooHandler: RouteHandler {
        var routes: [Route.Type] {
            return [MockRouteFromFooHandler.self, AnotherMockRouteFromFooHandler.self]
        }

        func destination(
            forRoute route: Route,
            fromViewController viewController: UIViewController
        ) -> AnyFeature {
            return AnyFeature(FeatureSpy.self)
        }
    }

    struct MockRouteFromBarHandler: Route {}

    final class BarHandler: RouteHandler {
        var routes: [Route.Type] {
            return [MockRouteFromBarHandler.self]
        }

        func destination(
            forRoute route: Route,
            fromViewController viewController: UIViewController
        ) -> AnyFeature {
            return AnyFeature(FeatureSpy.self)
        }
    }
}

extension RouterServiceDoubles {
    enum FeatureSpyWithNoDependencies: Feature {
        struct Dependencies {}

        static func build(
            dependencies: FeatureSpyWithNoDependencies.Dependencies,
            fromRoute route: Route?,
            presentationStyle: PresentationStyle
        ) -> UIViewController {
            return FeatureViewControllerSpy(dependencies: dependencies, route: route)
        }

        static var dependenciesInitializer: AnyDependenciesInitializer {
            return AnyDependenciesInitializer(Dependencies.init)
        }
    }
}
