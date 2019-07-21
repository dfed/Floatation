//  Created by Dan Federman on 7/20/19.
//  Copyright © 2019 Dan Federman.

import BuoyTest
import XCTest

@testable import FloatationSampleApp

class AppDelegateTests: BuoyTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_applicationWillFinishLaunching_setsUpRegistries() {
        let appDelegate = AppDelegate()
        _ = appDelegate.application(UIApplication.shared, willFinishLaunchingWithOptions: nil)
        RegistryVerification.testRegistriesHaveDesiredImplementationsSet()
    }

}
