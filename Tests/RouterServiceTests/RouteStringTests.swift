import XCTest

@testable import RouterService

final class RouteStringTests: XCTestCase {
    func test_routeString_parsesStringWithNoParams() {
        let routeString = RouteString(fromString: "foo|{}")
        XCTAssertEqual(routeString?.scheme, "foo")
        XCTAssertEqual(routeString?.parameterDict.isEmpty, true)
    }

    func test_routeString_parsesStringWithSingleParameter() {
        let routeString = RouteString(fromString: #"bar|{"param": "yes"}"#)
        XCTAssertEqual(routeString?.scheme, "bar")
        XCTAssertEqual(routeString?.parameterDict.count, 1)
        XCTAssertEqual(routeString?.parameterDict["param"] as? String, "yes")
    }

    func test_routeString_parsesStringWithTwoParameters() {
        let routeString = RouteString(fromString: #"xyz|{"param": true, "otherParam": 2}"#)
        XCTAssertEqual(routeString?.scheme, "xyz")
        XCTAssertEqual(routeString?.parameterDict.count, 2)
        XCTAssertEqual(routeString?.parameterDict["param"] as? Bool, true)
        XCTAssertEqual(routeString?.parameterDict["otherParam"] as? Int, 2)
    }

    func test_routeString_parsesStringWithMultipleParameters() {
        let routeString = RouteString(fromString: #"aaaaa|{"param": true, "otherParam": 2, "another": "BlaBla"}"#)
        XCTAssertEqual(routeString?.scheme, "aaaaa")
        XCTAssertEqual(routeString?.parameterDict.count, 3)
        XCTAssertEqual(routeString?.parameterDict["param"] as? Bool, true)
        XCTAssertEqual(routeString?.parameterDict["otherParam"] as? Int, 2)
        XCTAssertEqual(routeString?.parameterDict["another"] as? String, "BlaBla")
    }

    func test_routeString_failsOnInvalidFormatting() {
        XCTAssertNil(RouteString(fromString: ""))
        XCTAssertNil(RouteString(fromString: "foo"))
        XCTAssertNil(RouteString(fromString: "foo|"))
        XCTAssertNil(RouteString(fromString: "|foo"))
        XCTAssertNil(RouteString(fromString: #"foo|"param": true"#))
        XCTAssertNil(RouteString(fromString: "|foo|{}"))
    }
}
