import Foundation
import RouterServiceInterface

public extension Route {
    static var identifier: String {
        return String(describing: self)
    }
}
