import RouterServiceInterface

public protocol FeatureFlagProtocol {
    func isEnabled() -> Bool
}
