import Foundation
import RxSwift

final class ApiDataRequest<T> where T: ApiNetworkDataType {
    typealias TargetResultType = T

    func call(_ target: ApiRequestTargetType, session: URLSession = URLSession.shared) -> Single<ApiNetworkResult<TargetResultType>>  {
        URLRequest(
            url: URLComponents(
                target: target
            ).url!
        )
        .run(on: session)
        .timeout(.seconds(3), scheduler: MainScheduler.instance)
        .flatMap { response -> Observable<ApiNetworkResult<T>> in
            switch response.response.statusCode {
            case 200:
                return Observable.just(response.data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .map { $0.validate() ? .success($0) : .failure(.unvalidate) }

            case 404:
                return Observable.just(.failure(.notFound))

            default:
                return  Observable.just(.failure(.undefined))
            }
        }
        .retry(target.retryCount)
        .asSingle()
    }
}

protocol ApiValidateResponseType {
    func validate() -> Bool
}
extension ApiValidateResponseType {
    func validate() -> Bool { true }
}

protocol ApiRequestTargetType {
    var baseUrl: String { get }
    var path: String { get }
    var retryCount: Int { get }
}

extension ApiRequestTargetType {
    func makeURL() -> URL {
        URL(string: baseUrl + path)!
    }
}

protocol ApiNetworkDataType: Decodable, ApiValidateResponseType {}
enum ApiNetworkError: Error {
    case notFound
    case undefined
    case unvalidate
}
enum ApiNetworkResult<ApiResponse: ApiNetworkDataType> {
    case success(ApiResponse)
    case failure(ApiNetworkError)
}

// MARK: Networking
extension URLRequest {
    func run(on session: URLSession) -> Observable<(response: HTTPURLResponse, data: Data)> {
        session.rx.response(request: self)
    }
}
extension URLComponents {
    init(target: ApiRequestTargetType) {
        self.init(url: target.makeURL(), resolvingAgainstBaseURL: true)!
    }
}

