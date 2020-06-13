import XCTest
@testable import RouterService
import RouterServiceInterface

final class StoreTests: XCTestCase {

    typealias MockConcreteDependency = RouterServiceDoubles.MockConcreteDependency

    func test_store_failsIfClassIsUnregistered() {
        let store = Store()
        XCTAssertNil(store.get(MockConcreteDependency.self))
    }

    func test_store_succeedsIfClassIsRegistered() {
        let store = Store()
        let instance: RouterServiceDoubles.MockConcreteDependency = MockConcreteDependency()

        store.register({ instance }, forMetaType: MockConcreteDependency.self)

        XCTAssertTrue(instance === store.get(MockConcreteDependency.self))
    }

    func test_store_holdsValuesWeakly() {
        let store = Store()

        let factory: DependencyFactory = { MockConcreteDependency() }
        store.register(factory, forMetaType: MockConcreteDependency.self)

        autoreleasepool {

            var instance: MockConcreteDependency? = store.get(MockConcreteDependency.self)
            var sameInstance: MockConcreteDependency? = store.get(MockConcreteDependency.self)

            XCTAssertTrue(instance === sameInstance)

            XCTAssertEqual(instance?.aValue, 0)
            instance?.aValue = 1
            XCTAssertEqual(instance?.aValue, 1)

            instance = nil
            sameInstance = nil

        }

        let differentInstance = store.get(MockConcreteDependency.self)

        XCTAssertEqual(differentInstance?.aValue, 0)
    }

    func test_store_considersDifferentMetatypesAsDifferentInstances() {
        let store = Store()

        let concreteInstance = MockConcreteDependency()
        let protocolInstance = MockConcreteDependency()

        store.register({ concreteInstance }, forMetaType: MockConcreteDependency.self)
        store.register({ protocolInstance }, forMetaType: MockDependencyProtocol.self)

        XCTAssertTrue(concreteInstance === store.get(MockConcreteDependency.self))

        XCTAssertTrue(
            protocolInstance === store.get(MockDependencyProtocol.self) as? MockConcreteDependency
        )
    }
}
