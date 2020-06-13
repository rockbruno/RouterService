import Foundation
import RouterServiceInterface

public extension Route {
    static var asAnyRouteType: AnyRouteType {
        return AnyRouteType(self)
    }
}
