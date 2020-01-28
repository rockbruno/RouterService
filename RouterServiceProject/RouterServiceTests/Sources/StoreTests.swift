import XCTest

@testable import RouterService

final class StoreTests: XCTestCase {

    typealias MockConcreteDependency = RouterServiceDoubles.MockConcreteDependency

    func test_store_failsIfClassIsUnregistered() {
        let store = Store()
        XCTAssertNil(store.get(MockConcreteDependency.self))
    }

    func test_store_succeedsIfClassIsRegistered() {
        let store = Store()
        let instance = MockConcreteDependency()

        store.register(instance, forMetaType: MockConcreteDependency.self)

        XCTAssertTrue(instance === store.get(MockConcreteDependency.self))
    }

    func test_store_considersDifferentMetatypesAsDifferentInstances() {
        let store = Store()

        let concreteInstance = MockConcreteDependency()
        let protocolInstance = MockConcreteDependency()

        store.register(concreteInstance, forMetaType: MockConcreteDependency.self)
        store.register(protocolInstance, forMetaType: MockDependencyProtocol.self)

        XCTAssertTrue(concreteInstance === store.get(MockConcreteDependency.self))

        XCTAssertTrue(
            protocolInstance === store.get(MockDependencyProtocol.self) as? MockConcreteDependency
        )
    }
}
