//  Created by Dan Federman on 8/17/18.
//  Copyright © 2018 Dan Federman.

import XCTest

@testable import Floatation

class FloatationTests: XCTestCase {

    // MARK: XCTestCase

    open override func setUp() {
        // Ensure that all stored Registry instances are reset before each test.
        BaseRegistry.resetAllSharedInstances()

        super.setUp()
    }

    open override func tearDown() {
        // Ensure that all stored Registry instances are reset after each test.
        BaseRegistry.resetAllSharedInstances()

        super.tearDown()
    }

    // MARK: Behavior Tests

    func test_shared_returnsMockIfNoDefaultImplementationSet() {
        XCTAssertTrue(TestRegistry.shared.mockableInstance.isMock)
    }

    func test_shared_returnsSameMockIfAccessedTwiceIfNoDefaultImplementationSet() {
        XCTAssertTrue(TestRegistry.shared === TestRegistry.shared)
    }

    func test_shared_returnsDefaultImplementationIfDefaultImplementationSet() {
        let defaultImplementation = TestRegistry(mockableInstance: DefaultMockableType())
        TestRegistry.assignDesiredImplementation(to: defaultImplementation)
        XCTAssertTrue(TestRegistry.shared === defaultImplementation)
    }

    func test_shared_returnsSameDefaultImplementationTwiceIfDefaultImplementationSet() {
        let defaultImplementation = TestRegistry(mockableInstance: DefaultMockableType())
        TestRegistry.assignDesiredImplementation(to: defaultImplementation)
        XCTAssertTrue(TestRegistry.shared === defaultImplementation)
        XCTAssertTrue(TestRegistry.shared === defaultImplementation)
    }

    func test_assignDesiredImplementation_onlyAllowsOneSet() {
        let defaultImplementation = TestRegistry(mockableInstance: DefaultMockableType())
        let mockImplementation = TestRegistry(mockableInstance: MockMockableType())
        TestRegistry.assignDesiredImplementation(to: defaultImplementation)
        TestRegistry.assignDesiredImplementation(to: mockImplementation)
        XCTAssertTrue(TestRegistry.shared === defaultImplementation)
    }

    func test_resetAllSharedInstances_resetsShared() {
        let mockShared = TestRegistry.shared
        XCTAssertTrue(mockShared === TestRegistry.shared)
        BaseRegistry.resetAllSharedInstances()
        XCTAssertFalse(mockShared === TestRegistry.shared)
    }

    func test_allRegistryClasses_findsAllTypes() {
        let allRegistryClassTypes = BaseRegistry.allRegistryClasses()
        XCTAssertEqual(allRegistryClassTypes.count, 1)
    }

    func test_allRegistryClasses_canFindDesiredImplementations() {
        TestRegistry.assignDesiredImplementation(to: TestRegistry(mockableInstance: DefaultMockableType()))
        let allRegistryClassTypes = BaseRegistry.allRegistryClasses()
        for registryClassType in allRegistryClassTypes {
            XCTAssertNotNil(BaseRegistry.desiredImplementation(for: registryClassType))
        }
    }

    func test_shared_createsAndRetainsObjectOnce() {
        weak var weakSharedObject: NSObject? = TestRegistry.shared.sharedObject
        XCTAssertTrue(weakSharedObject === TestRegistry.shared.sharedObject)
    }

    func test_weak_returnsObject() {
        XCTAssertNotNil(TestRegistry.shared.weakObject)
    }

    func test_weak_doesNotRetainObject() {
        weak var weakObject: NSObject? = TestRegistry.shared.weakObject
        XCTAssertNil(weakObject)
    }

}

final class TestRegistry: Registry {

    // MARK: Lifecycle

    required init(mockableInstance: MockableType) {
        self.mockableInstance = mockableInstance

        super.init()
    }

    // MARK: Registry

    static func createMockShared() -> TestRegistry {
        return TestRegistry(mockableInstance: MockMockableType())
    }

    // MARK: Internal

    let mockableInstance: MockableType

    var sharedObject: NSObject {
        return _sharedObject.instance
    }

    var weakObject: NSObject {
        return _weakObject.instance
    }

    private var _sharedObject = Lazy() { NSObject() }
    private var _weakObject = WeakLazy() { NSObject() }

}

protocol MockableType {

    var isMock: Bool { get }

}
class DefaultMockableType: MockableType {

    let isMock = false

}
class MockMockableType: MockableType {

    let isMock = true

}
