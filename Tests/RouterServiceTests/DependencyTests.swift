import XCTest

@testable import RouterServiceInterface
@testable import RouterService

final class DependencyTests: XCTestCase {

    typealias MockConcreteDependency = RouterServiceDoubles.MockConcreteDependency

    func test_dependency_crashesIfNotRegistered() {
        let store = Store()

        var thrownMessage: String? = nil
        let failureHandler: FailureHandler = { msg in
            thrownMessage = msg
        }

        let dependency = Dependency<MockConcreteDependency>(resolvedValue: nil, failureHandler: failureHandler)

        dependency.resolve(withStore: store)
        XCTAssertEqual(thrownMessage, "Attempted to resolve Dependency<MockConcreteDependency>, but there's nothing registered for this type.")
    }

    func test_dependency_resolvesIfRegistered() {

        let concreteDep = MockConcreteDependency()

        let store = Store()
        store.register({ concreteDep }, forMetaType: MockConcreteDependency.self)

        let dependency = Dependency<MockConcreteDependency>(resolvedValue: nil)

        XCTAssertNil(dependency.resolvedValue)

        dependency.resolve(withStore: store)

        XCTAssertTrue(dependency.resolvedValue === concreteDep)
        XCTAssertTrue(dependency.wrappedValue === dependency.resolvedValue)
    }

    func test_dependency_crashesIfResolvedTwice() {
        let concreteDep = MockConcreteDependency()

        let store = Store()
        store.register({ concreteDep }, forMetaType: MockConcreteDependency.self)

        var thrownMessage: String? = nil
        let failureHandler: FailureHandler = { msg in
            thrownMessage = msg
        }

        let dependency = Dependency<MockConcreteDependency>(resolvedValue: nil, failureHandler: failureHandler)

        dependency.resolve(withStore: store)
        XCTAssertNil(thrownMessage)
        dependency.resolve(withStore: store)
        XCTAssertEqual(thrownMessage, "Attempted to resolve Dependency<MockConcreteDependency> twice!")
    }

    func test_dependency_convenienceInit() {
        let dep = Dependency<MockConcreteDependency>()
        XCTAssertNil(dep.resolvedValue)
    }
}
