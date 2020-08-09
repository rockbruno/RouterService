import Foundation

protocol Resolvable {
    func resolve(withStore store: StoreInterface)
}

public typealias FatalErrorClosure = (String) -> Void

@propertyWrapper
public final class Dependency<T>: Resolvable {

    let fatalError: FatalErrorClosure

    private(set) var resolvedValue: T!
    public var wrappedValue: T {
        if resolvedValue == nil {
            fatalError("Attempted to use \(type(of: self)) without resolving it first!")
        }
        return resolvedValue
    }

    public init(resolvedValue: T?, fatalError: @escaping FatalErrorClosure = { msg in preconditionFailure(msg) }) {
        self.resolvedValue = resolvedValue
        self.fatalError = fatalError
    }

    public convenience init() {
        self.init(resolvedValue: nil)
    }

    public func resolve(withStore store: StoreInterface) {
        guard resolvedValue == nil else {
            fatalError("Attempted to resolve \(type(of: self)) twice!")
            return
        }
        guard let value = store.get(T.self) else {
            fatalError("Attempted to resolve \(type(of: self)), but there's nothing registered for this type.")
            return
        }
        resolvedValue = value
    }
}
