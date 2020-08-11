import RouterServiceInterface
import UIKit

protocol MockDependencyProtocol {}

enum RouterServiceDoubles {
    final class MockConcreteDependency: MockDependencyProtocol {
        var aValue: Int = 0
    }
    struct MockRoute: Route {
        public static let identifier: String = "mockRoute"
    }
}

extension RouterServiceDoubles {
    struct FeatureSpy: Feature {

        @Dependency var concreteDep: MockConcreteDependency
        @Dependency var protocolDep: MockDependencyProtocol

        struct _Dependencies {
            let concreteDep: MockConcreteDependency
            let protocolDep: MockDependencyProtocol
        }

        func build(fromRoute route: Route?) -> UIViewController {
            let dep = _Dependencies(concreteDep: concreteDep, protocolDep: protocolDep)
            return FeatureViewControllerSpy(dependencies: dep, route: route)
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

        var registerArgumentPassed: DependencyFactory?
        var registerMetaTypePassed: AnyClass?

        func register<T>(_ arg: @escaping DependencyFactory, forMetaType metaType: T.Type) {
            registerArgumentPassed = arg
            registerMetaTypePassed = metaType as? AnyClass
        }
    }
}

extension RouterServiceDoubles {

    struct MockRouteFromFooHandler: Route {
        static let identifier: String = "mockRouteFromFooHandler"
    }
    struct AnotherMockRouteFromFooHandler: Route {
        static let identifier: String = "anotherMockRouteFromFooHandler"
    }
    struct MockRouteFromFooHandlerWithParams: Route {
        static let identifier: String = "mockRouteFromFooHandlerWithParams"
        let text: String
    }

    final class FooHandler: RouteHandler {
        var routes: [Route.Type] {
            return [MockRouteFromFooHandler.self, AnotherMockRouteFromFooHandler.self, MockRouteFromFooHandlerWithParams.self]
        }
        
        var featureTypeToBeReturned: Feature.Type?

        func destination(
            forRoute route: Route,
            fromViewController viewController: UIViewController
        ) -> Feature.Type {
            return featureTypeToBeReturned ?? FeatureSpy.self
        }
    }

    struct MockRouteFromBarHandler: Route {
        public static let identifier: String = "mockRouteFromBarHandler"
    }

    final class BarHandler: RouteHandler {
        var routes: [Route.Type] {
            return [MockRouteFromBarHandler.self]
        }

        func destination(
            forRoute route: Route,
            fromViewController viewController: UIViewController
        ) -> Feature.Type {
            return FeatureSpy.self
        }
    }
}

extension RouterServiceDoubles {
    struct FeatureSpyWithNoDependencies: Feature {

        struct _Dependencies {}

        func build(fromRoute route: Route?) -> UIViewController {
            return FeatureViewControllerSpy(dependencies: _Dependencies(), route: route)
        }
    }
}

extension RouterServiceDoubles {
    final class FeatureSpyDisabled: Feature {
        struct _Dependencies {}
        
        init() {}
        
        func build(fromRoute route: Route?) -> UIViewController {
            let dep = _Dependencies()
            return FeatureDisabledViewControllerSpy(dependencies: dep, route: route)
        }
        
        func isEnabled() -> Bool {
            return false
        }
        
        func fallback(forRoute route: Route?) -> Feature.Type? {
            return FeatureSpy.self
        }
    }
    
    final class FeatureSpyDisabledWithouFallback: Feature {
        struct _Dependencies {}
        
        init() {}
        
        func build(fromRoute route: Route?) -> UIViewController {
            let dep = _Dependencies()
            return FeatureDisabledViewControllerSpy(dependencies: dep, route: route)
        }
        
        func isEnabled() -> Bool {
            return false
        }
    }
    
    final class FeatureDisabledViewControllerSpy: UIViewController {

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
}
