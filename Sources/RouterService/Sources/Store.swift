import Foundation
import RouterServiceInterface

final class Store: StoreInterface {

    var dependencies = NSMapTable<NSString, AnyObject>(
        keyOptions: .strongMemory,
        valueOptions: .weakMemory
    )

    var dependencyCreators = [String: DependencyFactory]()

    func get<T>(_ arg: T.Type) -> T? {
        let name = String(describing: arg)
        let object = dependencies.object(forKey: name as NSString)
        if object == nil {
            let factory = dependencyCreators[name]
            let newInstance = factory?()
            dependencies.setObject(newInstance as AnyObject?, forKey: name as NSString)
            return newInstance as? T
        } else {
            return object as? T
        }
    }

    func register<T>(_ arg: @escaping DependencyFactory, forMetaType metaType: T.Type) {
        let name = String(describing: metaType)
        dependencyCreators[name] = arg
    }
}