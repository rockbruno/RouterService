import XCTest
import RouterServiceInterface

@testable import RouterService

final class RouteTests: XCTestCase {
    func test_routeIdentifier() {
        struct RouteA: Route {}
        struct RouteB: Route {}

        XCTAssertEqual(RouteA.identifier, String(describing: RouteA.self))
        XCTAssertEqual(RouteB.identifier, String(describing: RouteB.self))
    }
}
