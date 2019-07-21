//  Created by Dan Federman on 8/4/18.
//  Copyright © 2018 Dan Federman.

import Foundation

public typealias Registry = BaseRegistry & MockVendingRegistry

public protocol MockVendingRegistry: class {
    
    /// The value for `shared` if no default implementation has been set on the registry.
    /// Do not access this method directly.
    static func createMockShared() -> Self
    
}

open class BaseRegistry {
    
    // MARK: Lifecycle
    
    public init() {}
    
    // MARK: Internal Static

    /// Returns the previously registered desired implementation for a registry type.
    internal static func desiredImplementation<T>(for registryType: T.Type) -> T? where T: BaseRegistry {
        return selfIdentifierToDesiredImplementationMap[registryType.selfIdentifier] as? T
    }
    
    /// Returns the memoized mock implementation of a registry type.
    internal static func memoizedMockImplementation<T>(for registryType: T.Type) -> T? where T: BaseRegistry {
        return selfIdentifierToMemoizedMockImplementationMap[registryType.selfIdentifier] as? T
    }
    
    internal static var desiredImplementationCount: Int {
        return selfIdentifierToDesiredImplementationMap.count
    }
    
    /// A unit-testing helper method that resets all shared instances.
    /// WARNING: Do not call this method in production.
    internal static func resetAllSharedInstances() {
        selfIdentifierToMemoizedMockImplementationMap = [ObjectIdentifier: BaseRegistry]()
        selfIdentifierToDesiredImplementationMap = [ObjectIdentifier: BaseRegistry]()
    }
    
    internal static func allRegistryClasses() -> [BaseRegistry.Type] {
        var registryClasses = [BaseRegistry.Type]()
        let classesCount = objc_getClassList(nil, 0)
        
        guard classesCount > 0 else {
            return registryClasses
        }
        
        let registryClassDescription = NSStringFromClass(BaseRegistry.self)
        let classes = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(classesCount))
        for classIndex in 0..<objc_getClassList(AutoreleasingUnsafeMutablePointer(classes), classesCount) {
            if let currentClass = classes[Int(classIndex)],
                let superclass = class_getSuperclass(currentClass),
                NSStringFromClass(superclass) == registryClassDescription
            {
                registryClasses.append(currentClass as! BaseRegistry.Type)
            }
        }
        
        return registryClasses
    }

    // MARK: Fileprivate Static
    
    fileprivate static func setDesiredImplementation<T>(
        _ registry: T,
        for registryType: T.Type)
        where T: BaseRegistry
    {
        selfIdentifierToDesiredImplementationMap[registryType.selfIdentifier] = registry
    }

    fileprivate static func memoizeMockImplementation<T>(
        _ registry: T,
        for registryType: T.Type)
        where T: BaseRegistry
    {
        selfIdentifierToMemoizedMockImplementationMap[registryType.selfIdentifier] = registry
    }

    // MARK: Private Static

    private static var selfIdentifier: ObjectIdentifier {
        return ObjectIdentifier(self)
    }

    private static var selfIdentifierToMemoizedMockImplementationMap = [ObjectIdentifier: BaseRegistry]()
    private static var selfIdentifierToDesiredImplementationMap = [ObjectIdentifier: BaseRegistry]()
    
}

extension MockVendingRegistry where Self: BaseRegistry {
    
    // MARK: Public
    
    /// The shared registry.
    public static var shared: Self {
        let sharedInstance: Self
        if let shared = desiredImplementation(for: self) {
            sharedInstance = shared
            
        } else {
            if let memoizedMockShared = memoizedMockImplementation(for: self) {
                sharedInstance = memoizedMockShared
            } else {
                sharedInstance = createMockShared()
                memoizeMockImplementation(sharedInstance, for: self)
            }

            #if FLOATATION_SHOULD_ASSERT_WHEN_VENDING_MOCK_IMPLEMENTATION
            #if DEBUG
            // Make sure we aren't in a unit test environment.
            guard NSClassFromString("XCTestCase") == nil else {
                // We might be specifically testing this behavior. Return early and don't assert.
                return sharedInstance
            }
            #endif
            assertionFailure("No desired implementation set for \(self)")
            #endif
        }
        
        return sharedInstance
    }
    
    /// Used to set default (non-mock) implementations on the shared registry.
    public static func assignDesiredImplementation(to shared: Self) {
        guard desiredImplementation(for: self) == nil else {
            // We've already set shared. First set wins.
            return
        }
        
        setDesiredImplementation(shared, for: self)
    }
    
}
