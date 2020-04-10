import Foundation

// swiftlint:disable force_unwrapping

private struct Injected<T> {
    let wrappedValue: T

    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    init(store: StoreInterface) {
        // If you get a crash here, then your instance was not registered
        // into the RouterService being used.
        self.wrappedValue = store.get(T.self)!
    }
}


public protocol StoreInterface {
    func get<T>(_ arg: T.Type) -> T?
    func register<T>(_ arg: @escaping DependencyFactory, forMetaType metaType: T.Type)
}

public final class AnyDependenciesInitializer {

    public let build: (StoreInterface) -> Any

    public init<A>(_ function: @escaping () -> A) {
        build = { _ in
            function()
        }
    }

    /// If your Dependencies struct only have one dependency, you need to use this special method.
    /// This is because the generics in this type are unconstrained, so naming it the same as the others
    /// would cause ambiguity errors.
    public init<A, Result>(singleDependencyStruct function: @escaping (A) -> Result) {
        build = { store in
            let a = Injected<A>(store: store)
            return function(
                a.wrappedValue
            )
        }
    }

    public init<A, B, Result>(_ function: @escaping (A, B) -> Result) {
        build = { store in
            let a = Injected<A>(store: store)
            let b = Injected<B>(store: store)
            return function(
                a.wrappedValue,
                b.wrappedValue
            )
        }
    }

    public init<A, B, C, Result>(_ function: @escaping (A, B, C) -> Result) {
        build = { store in
            let a = Injected<A>(store: store)
            let b = Injected<B>(store: store)
            let c = Injected<C>(store: store)
            return function(
                a.wrappedValue,
                b.wrappedValue,
                c.wrappedValue
            )
        }
    }

    public init<A, B, C, D, Result>(_ function: @escaping (A, B, C, D) -> Result) {
        build = { store in
            let a = Injected<A>(store: store)
            let b = Injected<B>(store: store)
            let c = Injected<C>(store: store)
            let d = Injected<D>(store: store)
            return function(
                a.wrappedValue,
                b.wrappedValue,
                c.wrappedValue,
                d.wrappedValue
            )
        }
    }

    public init<A, B, C, D, E, Result>(_ function: @escaping (A, B, C, D, E) -> Result) {
        build = { store in
            let a = Injected<A>(store: store)
            let b = Injected<B>(store: store)
            let c = Injected<C>(store: store)
            let d = Injected<D>(store: store)
            let e = Injected<E>(store: store)
            return function(
                a.wrappedValue,
                b.wrappedValue,
                c.wrappedValue,
                d.wrappedValue,
                e.wrappedValue
            )
        }
    }

    public init<A, B, C, D, E, F, Result>(_ function: @escaping (A, B, C, D, E, F) -> Result) {
        build = { store in
            let a = Injected<A>(store: store)
            let b = Injected<B>(store: store)
            let c = Injected<C>(store: store)
            let d = Injected<D>(store: store)
            let e = Injected<E>(store: store)
            let f = Injected<F>(store: store)
            return function(
                a.wrappedValue,
                b.wrappedValue,
                c.wrappedValue,
                d.wrappedValue,
                e.wrappedValue,
                f.wrappedValue
            )
        }
    }
}
