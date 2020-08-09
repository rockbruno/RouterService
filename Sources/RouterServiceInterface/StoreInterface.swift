import Foundation

public protocol StoreInterface {
    func get<T>(_ arg: T.Type) -> T?
    func register<T>(_ arg: @escaping DependencyFactory, forMetaType metaType: T.Type)
}
