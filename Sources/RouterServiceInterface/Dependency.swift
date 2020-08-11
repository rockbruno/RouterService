import Foundation

protocol Resolvable {
    func resolve(withStore store: StoreInterface)
}

public typealias FailureHandler = (String) -> Void

@propertyWrapper
public final class Dependency<T>: Resolvable {

    let failureHandler: FailureHandler

    private(set) var resolvedValue: T!
    public var wrappedValue: T {
        if resolvedValue == nil {
            failureHandler("Attempted to use \(type(of: self)) without resolving it first!")
        }
        return resolvedValue
    }

    public init(resolvedValue: T?, failureHandler: @escaping FailureHandler = { msg in preconditionFailure(msg) }) {
        self.resolvedValue = resolvedValue
        self.failureHandler = failureHandler
    }

    public convenience init() {
        self.init(resolvedValue: nil)
    }

    public func resolve(withStore store: StoreInterface) {
        guard resolvedValue == nil else {
            failureHandler("Attempted to resolve \(type(of: self)) twice!")
            return
        }
        guard let value = store.get(T.self) else {
            failureHandler("Attempted to resolve \(type(of: self)), but there's nothing registered for this type.")
            return
        }
        resolvedValue = value
    }
}
