import Foundation

enum ApiDataServiceTarget {
    case feed
    case detailItem(id: String)
}

// MARK: ApiRequestType
extension ApiDataServiceTarget: ApiRequestTargetType {
    var baseUrl: String {
        "https://www.avito.st/s/interns-ios"
    }

    var path: String {
        switch self {
        case .feed:
            return "/main-page.json"
        case .detailItem(let id):
            return "/details/\(id).json"
        }
    }

    var retryCount: Int { 3 }
}
