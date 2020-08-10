import UIKit

public protocol FlaggableFeature: Feature {
    func isEnabled() -> Bool
    
    func buildFallback(
        fromRoute route: Route?
    ) -> UIViewController
}
