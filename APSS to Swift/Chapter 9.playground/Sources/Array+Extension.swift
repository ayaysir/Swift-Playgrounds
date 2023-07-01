import Foundation

public extension Array where Element == Double {
    func logarithmize() -> [Double] {
        map { log($0) }
    }
}
