import org.junit.*
import org.junit.Assert.*

class AvailabilityServiceTests {
    lateinit var service: AvailabilityService
    lateinit var mockHttpClient: MockHttpClient
    
    @Before
    fun setUp() {
        mockHttpClient = MockHttpClient()
        service = AvailabilityService(httpClient = mockHttpClient)
    }
    
    @After
    fun tearDown() {
        mockHttpClient.clear()
    }
    
    @Test
    fun testAssertEqual() {
        assertEquals(1, 1)
        assertEquals("Not equal", 1, 1)
    }
    
    @Test
    fun testAssertTrue() {
        assertTrue(true)
        assertTrue("Not true", true)
    }
    
    @Test
    fun testAssertFalse() {
        assertFalse(false)
        assertFalse("Should not be true", false)
    }
    
    @Test
    fun testAssertNil() {
        assertNull(null)
        assertNull("Should be nil", null)
    }
    
    @Test
    fun testAssertNotNil() {
        assertNotNull("")
        assertNotNull("Should not be nil", "")
    }
    
    @Test
    fun testMultipleStatements() {
        mockHttpClient.fileResponse = "empty"
        val result = service.search()
        val params = mockHttpClient.parameters
        assertTrue("Expected get request", mockHttpClient.method == "GET")
        assertEquals(mockHttpClient.endpoint, "/api/v2/availability/search")
        assertNotNull("Expected parameters", params)
        assertNull("Promise should not have error", promise.error)
        assertNotNull(result)
    }
    
    fun noTestMethod() {
        assertTrue(true)
    }
}

class TestWithInheritance: SomeProtocol {
    
    @Test
    fun testMethodNotUnderXCTest() {
        assertTrue(true)
    }
}

class ClassWithNoTest: Other {
    
    override fun setUp() {
        super.setUp()
        mockHttpClient = MockHttpClient()
        service = AvailabilityService(httpClient = mockHttpClient)
    }
    
    override fun tearDown() {
        mockHttpClient.clear()
        super.tearDown()
    }
    
    fun testMethodNotUnderXCTest() {
        assertTrue(true)
    }
}
