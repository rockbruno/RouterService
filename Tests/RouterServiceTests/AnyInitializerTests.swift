import XCTest
import RouterServiceInterface

@testable import RouterService

final class AnyDependenciesInitializerTests: XCTestCase {

    func test_AnyDependenciesInitializer_withNoArguments() {
        struct MockStruct {}

        let erasure = AnyDependenciesInitializer(MockStruct.init)
        let store = Store()

        XCTAssertTrue(erasure.build(store) is MockStruct)
    }

    func test_AnyDependenciesInitializer_withTwoArguments() {
        class MockA: Dependency {}
        class MockB: Dependency {}
        struct MockStruct {
            let a: MockA
            let b: MockB
        }

        let erasure = AnyDependenciesInitializer(MockStruct.init)
        let store = Store()
        store.register({ MockA() }, forMetaType: MockA.self)
        store.register({ MockB() }, forMetaType: MockB.self)

        XCTAssertTrue(erasure.build(store) is MockStruct)
    }

    func test_AnyDependenciesInitializer_withThreeArguments() {
        class MockA: Dependency {}
        class MockB: Dependency {}
        class MockC: Dependency {}
        struct MockStruct {
            let a: MockA
            let b: MockB
            let c: MockC
        }

        let erasure = AnyDependenciesInitializer(MockStruct.init)
        let store = Store()
        store.register({ MockA() }, forMetaType: MockA.self)
        store.register({ MockB() }, forMetaType: MockB.self)
        store.register({ MockC() }, forMetaType: MockC.self)

        XCTAssertTrue(erasure.build(store) is MockStruct)
    }

    func test_AnyDependenciesInitializer_withFourArguments() {
        class MockA: Dependency {}
        class MockB: Dependency {}
        class MockC: Dependency {}
        class MockD: Dependency {}
        struct MockStruct {
            let a: MockA
            let b: MockB
            let c: MockC
            let d: MockD
        }

        let erasure = AnyDependenciesInitializer(MockStruct.init)
        let store = Store()

        store.register({ MockA() }, forMetaType: MockA.self)
        store.register({ MockB() }, forMetaType: MockB.self)
        store.register({ MockC() }, forMetaType: MockC.self)
        store.register({ MockD() }, forMetaType: MockD.self)

        XCTAssertTrue(erasure.build(store) is MockStruct)
    }

    func test_AnyDependenciesInitializer_withFiveArguments() {
        class MockA: Dependency {}
        class MockB: Dependency {}
        class MockC: Dependency {}
        class MockD: Dependency {}
        class MockE: Dependency {}
        struct MockStruct {
            let a: MockA
            let b: MockB
            let c: MockC
            let d: MockD
            let e: MockE
        }

        let erasure = AnyDependenciesInitializer(MockStruct.init)
        let store = Store()

        store.register({ MockA() }, forMetaType: MockA.self)
        store.register({ MockB() }, forMetaType: MockB.self)
        store.register({ MockC() }, forMetaType: MockC.self)
        store.register({ MockD() }, forMetaType: MockD.self)
        store.register({ MockE() }, forMetaType: MockE.self)

        XCTAssertTrue(erasure.build(store) is MockStruct)
    }

    func test_AnyDependenciesInitializer_withSixArguments() {
        class MockA: Dependency {}
        class MockB: Dependency {}
        class MockC: Dependency {}
        class MockD: Dependency {}
        class MockE: Dependency {}
        class MockF: Dependency {}
        struct MockStruct {
            let a: MockA
            let b: MockB
            let c: MockC
            let d: MockD
            let e: MockE
            let f: MockF
        }

        let erasure = AnyDependenciesInitializer(MockStruct.init)
        let store = Store()

        store.register({ MockA() }, forMetaType: MockA.self)
        store.register({ MockB() }, forMetaType: MockB.self)
        store.register({ MockC() }, forMetaType: MockC.self)
        store.register({ MockD() }, forMetaType: MockD.self)
        store.register({ MockE() }, forMetaType: MockE.self)
        store.register({ MockF() }, forMetaType: MockF.self)

        XCTAssertTrue(erasure.build(store) is MockStruct)
    }

}
