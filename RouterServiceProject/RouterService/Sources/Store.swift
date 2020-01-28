import Foundation
import RouterServiceInterface

final class Store: StoreInterface {
    var dependencies = [String: Any]()

    func get<T>(_ arg: T.Type) -> T? {
        let name = String(describing: arg)
        return dependencies[name] as? T
    }

    func register<T>(_ arg: Dependency, forMetaType metaType: T.Type) {
        let name = String(describing: metaType)
        dependencies[name] = arg
    }
}
