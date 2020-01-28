import UIKit

public final class AnyFeature {

    public let build: (StoreInterface, Route?, PresentationStyle) -> UIViewController

    public init<T: Feature>(_ feature: T.Type) {
        build = { store, route, presentationStyle in
            // swiftlint:disable:next force_cast
            let dependencies = feature.dependenciesInitializer.build(store) as! T.Dependencies
            return feature.build(
                dependencies: dependencies,
                fromRoute: route,
                presentationStyle: presentationStyle
            )
        }
    }
}
