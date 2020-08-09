import UIKit

public protocol Feature {
    associatedtype Dependencies

    static var dependenciesInitializer: AnyDependenciesInitializer { get }

    static func build(
        dependencies: Dependencies,
        fromRoute route: Route?
    ) -> UIViewController
}

public protocol EXPR_Feature {
    func build(
        fromRoute route: Route?
    ) -> UIViewController

    func setup(withStore store: StoreInterface)
}
