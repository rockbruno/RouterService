import UIKit
import RouterServiceInterface

extension Feature {
    static func initialize(withStore store: StoreInterface) -> Feature {
        let feature = Self.init()
        feature.resolve(withStore: store)
        return feature
    }
}
