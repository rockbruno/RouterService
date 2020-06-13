import Foundation
import RouterServiceInterface

public struct RouteString {

    public let scheme: String
    public let parameterDict: [String: Any]
    public let parameterData: Data
    public let originalString: String

    public init?(fromString routeString: String) {

        self.originalString = routeString

        var schemeString = ""
        var runnerIndex = routeString.startIndex

        while runnerIndex != routeString.endIndex && routeString[runnerIndex] != "|" {
            schemeString.append(routeString[runnerIndex])
            runnerIndex = routeString.index(after: runnerIndex)
        }

        if runnerIndex == routeString.endIndex || routeString[runnerIndex] != "|" {
            return nil
        }

        self.scheme = schemeString

        runnerIndex = routeString.index(after: runnerIndex)

        if runnerIndex == routeString.endIndex {
            return nil
        }

        let parameterString = routeString[runnerIndex...]

        guard let parameterData = parameterString.data(using: .utf8) else {
            return nil
        }

        do {
            let json = try JSONSerialization.jsonObject(with: parameterData, options: [])
            guard let parameterDict = json as? [String: Any] else {
                return nil
            }
            self.parameterDict = parameterDict
            self.parameterData = parameterData
        } catch {
            return nil
        }
    }
}

extension RouteString: Hashable {
    public static func == (lhs: RouteString, rhs: RouteString) -> Bool {
        return lhs.originalString == rhs.originalString
    }

    public func hash(into hasher: inout Hasher) {
        originalString.hash(into: &hasher)
    }
}

