import Foundation

enum RequestOutputState<T: Equatable>: Equatable {
    case loading
    case loaded(T)
    case error

    var isLoading: Bool {
        self == .loading
    }

    var isResult: T? {
        if case Self.loaded(let result) = self { return result }
        else { return nil }
    }

    var isError: Bool {
        self == .error
    }
}
