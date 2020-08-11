import UIKit

public protocol Feature {
    func build(
        fromRoute route: Route?
    ) -> UIViewController

    func resolve(withStore store: StoreInterface)

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
}
