import RxCocoa
import RxSwift

enum FeedInputAction {
    case initialise
    case refresh
}

protocol FeedViewCollectionViewModelType {
    var onOutputRequestState: Driver<RequestOutputState<Item>> { get }
    var inputRequestState: BehaviorRelay<FeedInputAction> { get }

    var select: PublishRelay<Advertisement> { get }
}

final class FeedViewCollectionViewModel: FeedViewCollectionViewModelType {
    typealias FeedRequestOutputState = RequestOutputState<Item>

    let inputRequestState: BehaviorRelay<FeedInputAction>

    private let outputRequestState: BehaviorRelay<FeedRequestOutputState>
    let onOutputRequestState: Driver<FeedRequestOutputState>

    let onSelect: Signal<Advertisement>
    let select: PublishRelay<Advertisement>

    private let service = ApiDataRequest<Item>()
    private let disposeBag = DisposeBag()

    init() {
        inputRequestState = .init(value: .initialise)

        outputRequestState = .init(value: .loading)
        onOutputRequestState = outputRequestState.asDriver()

        select = .init()
        onSelect = select.asSignal()

        setupBindings()
    }

    func setupBindings() {
        inputRequestState
            .asDriver()
            .map { action in
                switch action {
                case .initialise, .refresh: return FeedRequestOutputState.loading
                }
            }
            .drive(outputRequestState)
            .disposed(by: disposeBag)


        inputRequestState
            .asDriver()
            .debounce(.milliseconds(500))
            .drive(onNext: { [unowned self] in
                Single.just($0)
                    .flatMap {[weak self] input -> Single<ApiNetworkResult<Item>> in
                        guard let self else { return Single.never() }
                        switch input {
                        case .initialise, .refresh:
                            return service.call(ApiDataServiceTarget.feed)
                                .timeout(.seconds(6), scheduler: MainScheduler.instance)
                        }
                    }
                    .asSignal(onErrorJustReturn: .failure(.undefined))
                    .map { result in
                        switch result {
                        case ApiNetworkResult.success(let result):
                            return RequestOutputState.loaded(result)
                        case ApiNetworkResult.failure(_):
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            return RequestOutputState.error
                        }
                    }
                    .emit(to: outputRequestState)
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
