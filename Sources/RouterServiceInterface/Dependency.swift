import Foundation

public protocol Dependency: AnyObject {}

@propertyWrapper
public final class EXP_Dependency<T> {
    private var __resolvedValue: T!
    public var wrappedValue: T {
        guard let value = __resolvedValue else {
            preconditionFailure("Attempted to use \(type(of: self)) without resolving it first!")
        }
        return value
    }

    public init(wrappedValue: T) {
        self.__resolvedValue = wrappedValue
    }

    public init() {}

    public func resolve(withStore store: StoreInterface) {
        guard __resolvedValue == nil else {
            preconditionFailure("Attempted to resolve \(type(of: self)) twice!")
        }
        guard let value = store.get(T.self) else {
            preconditionFailure("Attempted to resolve \(type(of: self)), but there's nothing registered for this type.")
        }
        __resolvedValue = value
    }
}
