import FeatureFlagInterface
import RouterServiceInterface

public class FeatureFlag: FeatureFlagProtocol {
    public init() {}

    public func isEnabled() -> Bool { 
        return true
    }
}
