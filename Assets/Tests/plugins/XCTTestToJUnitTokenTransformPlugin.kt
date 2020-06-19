import org.junit.*
import org.junit.Assert.*

internal class AvailabilityServiceTests {
    lateinit internal var service: AvailabilityService
    lateinit internal var mockHttpClient: MockHttpClient
    
    @Before
    internal fun setUp() {
        mockHttpClient = MockHttpClient()
        service = AvailabilityService(httpClient = mockHttpClient)
    }
    
    @After
    internal fun tearDown() {
        mockHttpClient.clear()
    }
    
    @Test
    internal fun testAssertEqual() {
        assertEquals(1, 1)
        assertEquals("Not equal", 1, 1)
    }
    
    @Test
    internal fun testAssertTrue() {
        assertTrue(true)
        assertTrue("Not true", true)
    }
    
    @Test
    internal fun testAssertFalse() {
        assertFalse(false)
        assertFalse("Should not be true", false)
    }
    
    @Test
    internal fun testAssertNil() {
        assertNull(null)
        assertNull("Should be nil", null)
    }
    
    @Test
    internal fun testAssertNotNil() {
        assertNotNull("")
        assertNotNull("Should not be nil", "")
    }
    
    @Test
    internal fun testMultipleStatements() {
        mockHttpClient.fileResponse = "empty"
        val result = service.search()
        val params = mockHttpClient.parameters
        assertTrue("Expected get request", mockHttpClient.method == "GET")
        assertEquals(mockHttpClient.endpoint, "/api/v2/availability/search")
        assertNotNull("Expected parameters", params)
        assertNull("Promise should not have error", promise.error)
        assertNotNull(result)
    }
    
    internal fun noTestMethod() {
        assertTrue(true)
    }
}

internal class TestWithInheritance: SomeProtocol {
    
    @Test
    internal fun testMethodNotUnderXCTest() {
        assertTrue(true)
    }
}

internal class ClassWithNoTest: Other {
    
    internal override fun setUp() {
        super.setUp()
        mockHttpClient = MockHttpClient()
        service = AvailabilityService(httpClient = mockHttpClient)
    }
    
    internal override fun tearDown() {
        mockHttpClient.clear()
        super.tearDown()
    }
    
    internal fun testMethodNotUnderXCTest() {
        assertTrue(true)
    }
}
