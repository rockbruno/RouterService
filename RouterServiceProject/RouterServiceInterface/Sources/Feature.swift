import UIKit

public protocol Feature {
    associatedtype Dependencies

    static var dependenciesInitializer: AnyDependenciesInitializer { get }

    static func build(
        dependencies: Dependencies,
        fromRoute route: Route?
    ) -> UIViewController
}
