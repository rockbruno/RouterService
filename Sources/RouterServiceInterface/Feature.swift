import UIKit

public protocol Feature {
    func build(fromRoute route: Route?) -> UIViewController
    func resolve(withStore store: StoreInterface)
    
    /// Returns whether or not a feature can be presented. 
    /// Implement this method if the availability of your feature should be controlled. (feature flag, user defaults, iOS version, etc)
    /// By default, this method returns `true` (enabled). Overwrite it to manually handle the presentation logic.
    /// If your feature can be disabled, you must also implement `fallback(_:)` to provide the alternate feature to be presented.
    ///
    /// - Returns: A boolean indicating if this feature can be presented by RouterService.
    func isEnabled() -> Bool
    
    /// Returns the feature that should be presented instead if this feature is disabled.
    /// If a feature can be disabled, it's mandatory to provide a fallback `Feature`.
    ///
    /// - Parameters:
    ///   - route: The `Route` that triggered this feature.
    /// - Returns: The fallback feature that should be presented when this feature is disabled.
    func fallback(forRoute route: Route?) -> Feature.Type?

    init()
}

extension Feature {
    public func resolve(withStore store: StoreInterface) {
        let mirror = Mirror(reflecting: self)
        for children in mirror.children {
            if let resolvable = children.value as? Resolvable {
                resolvable.resolve(withStore: store)
            }
        }
    }

    public func isEnabled() -> Bool { return true }
    public func fallback(forRoute route: Route?) -> Feature.Type? { return nil }
}
