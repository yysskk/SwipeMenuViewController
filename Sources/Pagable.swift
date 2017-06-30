
import Foundation

protocol Pagable {
    var currentPage: Int { get }
    var previousPage: Int { get }
    var nextPage: Int { get }
    func update(currentPage page: Int)
}

extension Pagable {
    func update(currentPage page: Int) {}
}
