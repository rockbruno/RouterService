import XCTest
import RouterService
import RouterServiceInterface

final class AnyRouteTests: XCTestCase {

    private struct DummyDecoder: Decodable {
        let value: AnyRoute
    }

    func test_anyRouteDecoding_failsOnBadRouteString() {
        let context = RouterService()
        let decoder = JSONDecoder()
        context.injectContext(toDecoder: decoder)

        let data = """
        {
          "value": "///badActionString"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(DummyDecoder.self, from: data)) { error in
            XCTAssertEqual(error as? RouterService.RouteDecodingError, RouterService.RouteDecodingError.failedToParseRouteString)
        }
    }

    func test_anyActionDecoding_failsOnUnregisteredAction() {
        let context = RouterService()
        context.register(routeHandler: RouterServiceDoubles.FooHandler())
        let decoder = JSONDecoder()
        context.injectContext(toDecoder: decoder)

        let data = """
        {
          "value": "notTheExpectedAction|{}"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(DummyDecoder.self, from: data)) { error in
            XCTAssertEqual(error as? RouterService.RouteDecodingError, RouterService.RouteDecodingError.unregisteredRoute)
        }
    }

    func test_anyActionDecoding_failsOnWrongActionDecoding() {
        let context = RouterService()
        context.register(routeHandler: RouterServiceDoubles.FooHandler())
        let decoder = JSONDecoder()
        context.injectContext(toDecoder: decoder)

        let routeString = #"mockRouteFromFooHandlerWithParams|{}"#

        let data = """
        {
          "value": "\(routeString)"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(DummyDecoder.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }

    func test_anyActionDecoding_succeedsIfRegisteredAndIfTheActionStringIsCorrect() throws {
        let context = RouterService()
        context.register(routeHandler: RouterServiceDoubles.FooHandler())
        let decoder = JSONDecoder()
        context.injectContext(toDecoder: decoder)

        let routeString = #"mockRouteFromFooHandlerWithParams|{\"text\":\"correctParam\"}"#

        let data = """
        {
          "value": "\(routeString)"
        }
        """.data(using: .utf8)!

        let action = try decoder.decode(DummyDecoder.self, from: data)

        XCTAssertTrue(action.value.value is RouterServiceDoubles.MockRouteFromFooHandlerWithParams)
        XCTAssertEqual((action.value.value as? RouterServiceDoubles.MockRouteFromFooHandlerWithParams)?.text, "correctParam")
    }
}
