import UIKit

public protocol Feature {
    func build(fromRoute route: Route?) -> UIViewController
    func resolve(withStore store: StoreInterface)
    
    /// Provides if feature is enabled to be presented, should be used when feature is controlled by toggle (feature flag, user defaults, etc)
    /// Overwrite this method to handle the logic for presentation because
    /// default value is always `true` (enabled)
    ///
    /// - Returns: Feature is enabled `true` or not `false`
    func isEnabled() -> Bool
    
    /// When feature is disabled, it's mandatory implement Fallback Feature
    ///
    /// - Parameters:
    ///   - route: Route to be used for fallback feature
    /// - Returns: Destination to be present when feature is disabled
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
