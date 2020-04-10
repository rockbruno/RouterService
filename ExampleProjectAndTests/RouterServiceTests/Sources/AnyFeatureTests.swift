import XCTest
import RouterServiceInterface

@testable import RouterService

final class AnyFeatureTests: XCTestCase {

    typealias MockConcreteDependency = RouterServiceDoubles.MockConcreteDependency

    func test_anyFeature_buildsFeatureWithCorrectDepsAndRoutes() {

        let concreteDep = MockConcreteDependency()
        let protocolDep = MockConcreteDependency()

        let store = Store()
        store.register({ concreteDep }, forMetaType: MockConcreteDependency.self)
        store.register({ protocolDep }, forMetaType: MockDependencyProtocol.self)

        let erasure = AnyFeature(RouterServiceDoubles.FeatureSpy.self)
        let route = RouterServiceDoubles.MockRoute()

        let feature = erasure.build(store, route) as! RouterServiceDoubles.FeatureViewControllerSpy
        let dependenciesPassed = feature.dependenciesPassed as? RouterServiceDoubles.FeatureSpy.Dependencies

        XCTAssertTrue(dependenciesPassed?.concreteDep === concreteDep)
        XCTAssertTrue(
            dependenciesPassed?.protocolDep as? MockConcreteDependency === protocolDep
        )
        XCTAssertNotNil(feature.routePassed)
        XCTAssertTrue(feature.routePassed is RouterServiceDoubles.MockRoute)
    }

}
