
import XCTest
@testable import MySportsSDK

class AvailabilityServiceTests: XCTestCase {
    var service: AvailabilityService!
    var mockHttpClient: MockHttpClient!

    override func setUp() {
        super.setUp()
        mockHttpClient = MockHttpClient()
        service = AvailabilityService(httpClient: mockHttpClient)
    }

    override func tearDown() {
        mockHttpClient.clear()
        super.tearDown()
    }

    func testAssertEqual() {
        XCTAssertEqual(1, 1)
        XCTAssertEqual(1, 1, "Not equal")
    }

    func testAssertTrue() {
        XCTAssertTrue(true)
        XCTAssertTrue(true, "Not true")
    }

    func testAssertFalse() {
        XCTAssertFalse(false)
        XCTAssertFalse(false, "Should not be true")
    }

    func testAssertNil() {
        XCTAssertNil(nil)
        XCTAssertNil(nil, "Should be nil")
    }

    func testAssertNotNil() {
        XCTAssertNotNil("")
        XCTAssertNotNil("", "Should not be nil")
    }

    func testMultipleStatements() {
        mockHttpClient.fileResponse = "empty"
        let result = service.search()
        let params = mockHttpClient.parameters

        XCTAssertTrue(mockHttpClient.method == "GET", "Expected get request")
        XCTAssertEqual(mockHttpClient.endpoint, "/api/v2/availability/search")
        XCTAssertNotNil(params, "Expected parameters")
        XCTAssertNil(promise.error, "Promise should not have error")
        XCTAssertNotNil(result)
    }

    func noTestMethod() {
        XCTAssertTrue(true)
    }

}

class TestWithInheritance: XCTestCase, SomeProtocol {
    func testMethodNotUnderXCTest() {
        XCTAssertTrue(true)
    }
}

class ClassWithNoTest: Other {

    override func setUp() {
        super.setUp()
        mockHttpClient = MockHttpClient()
        service = AvailabilityService(httpClient: mockHttpClient)
    }

    override func tearDown() {
        mockHttpClient.clear()
        super.tearDown()
    }

    func testMethodNotUnderXCTest() {
        XCTAssertTrue(true)
    }
}
