//  Created by Dan Federman on 7/21/19.
//  Copyright © 2019 Dan Federman.

import Floatation
import XCTest

public class RegistryVerification {

    /// A method to test that all registries have had desired implementations set.
    /// Register all desired implementations before calling this method.
    public static func testRegistriesHaveDesiredImplementationsSet() {
        // Find all registries in the app via Objc runtime magic.
        let registries = BaseRegistry.🧪allRegistryClasses()

        // Make sure we have at least one registry.
        XCTAssertGreaterThan(
            registries.count,
            0,
            "Did not find any Registry implementation classes")

        // Test that every registry has a default implementation.
        for registry in registries {
            XCTAssertTrue(
                BaseRegistry.🧪desiredImplementationExists(for: registry),
                "No desired implementation found for registry type \(registry)")
        }

        // Sanity check that we found every registry that was set.
        // If this check fails but the above checks did not, then
        // our Objc runtime magic did not find every registry.
        XCTAssertEqual(
            BaseRegistry.🧪desiredImplementationCount,
            registries.count,
            "\(BaseRegistry.🧪desiredImplementationCount) "
                + "desired implementations have been set, but there are "
                + "\(registries.count) total registries")
    }

}
