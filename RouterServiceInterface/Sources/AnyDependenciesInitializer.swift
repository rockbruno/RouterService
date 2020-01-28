import Foundation

// swiftlint:disable force_unwrapping

public protocol StoreInterface {
    func get<T>(_ arg: T.Type) -> T?
    func register<T>(_ arg: Dependency, forMetaType metaType: T.Type)
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
    public init<A, B>(singleDependencyStruct function: @escaping (A) -> B) {
        build = { store in
            let a: A = store.get(A.self)!
            return function(a)
        }
    }

    public init<A, B, C>(_ function: @escaping (A, B) -> C) {
        build = { store in
            let a: A = store.get(A.self)!
            let b: B = store.get(B.self)!
            return function(a, b)
        }
    }

    public init<A, B, C, D>(_ function: @escaping (A, B, C) -> D) {
        build = { store in
            let a: A = store.get(A.self)!
            let b: B = store.get(B.self)!
            let c: C = store.get(C.self)!
            return function(a, b, c)
        }
    }

    public init<A, B, C, D, E>(_ function: @escaping (A, B, C, D) -> E) {
        build = { store in
            let a: A = store.get(A.self)!
            let b: B = store.get(B.self)!
            let c: C = store.get(C.self)!
            let d: D = store.get(D.self)!
            return function(a, b, c, d)
        }
    }

    public init<A, B, C, D, E, F>(_ function: @escaping (A, B, C, D, E) -> F) {
        build = { store in
            let a: A = store.get(A.self)!
            let b: B = store.get(B.self)!
            let c: C = store.get(C.self)!
            let d: D = store.get(D.self)!
            let e: E = store.get(E.self)!
            return function(a, b, c, d, e)
        }
    }

    public init<A, B, C, D, E, F, G>(_ function: @escaping (A, B, C, D, E, F) -> G) {
        build = { store in
            let a: A = store.get(A.self)!
            let b: B = store.get(B.self)!
            let c: C = store.get(C.self)!
            let d: D = store.get(D.self)!
            let e: E = store.get(E.self)!
            let f: F = store.get(F.self)!
            return function(a, b, c, d, e, f)
        }
    }
}
