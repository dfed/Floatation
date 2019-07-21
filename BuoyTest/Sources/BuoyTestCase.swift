//  Created by Dan Federman on 8/17/18.
//  Copyright © 2018 Dan Federman.

import XCTest

@testable import Floatation

/// Subclass this class instead of XCTestCase for automated registry cleanup between tests.
open class BuoyTestCase: XCTestCase {
    
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

}
