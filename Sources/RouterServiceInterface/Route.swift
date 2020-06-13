import Foundation

public protocol Route: Decodable {
    static var identifier: String { get }
}
