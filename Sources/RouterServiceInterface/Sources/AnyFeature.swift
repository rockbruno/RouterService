import UIKit

public final class AnyFeature {

    public let build: (StoreInterface, Route?) -> UIViewController

    public init<T: Feature>(_ feature: T.Type) {
        build = { store, route in
            // swiftlint:disable:next force_cast
            let dependencies = feature.dependenciesInitializer.build(store) as! T.Dependencies
            return feature.build(
                dependencies: dependencies,
                fromRoute: route
            )
        }
    }
}
