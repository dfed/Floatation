//___FILEHEADER___

import Floatation
import Foundation

public final class ___FILEBASENAME___: Registry {

    // MARK: Lifecycle

    public init(
        <#T##propertyName#>: <#T##PropertyType#>)
    {
        self.<#T##propertyName#> = <#T##propertyName#>

        super.init()
    }

    // MARK: Registry

    public static func createMockShared() -> ___FILEBASENAME___ {
        return ___FILEBASENAME___(
            <#T##propertyName#>: Mock<#T##PropertyType#>())
    }

    // MARK: Public

    public let <#T##propertyName#>: <#T##PropertyType#>
}
