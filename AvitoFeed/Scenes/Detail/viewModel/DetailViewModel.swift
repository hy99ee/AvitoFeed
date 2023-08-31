import RxCocoa
import RxSwift

enum DetailInputAction {
    case initialise(itemId: String)
    case refresh
}

protocol DetailViewModelType: Steppable, Stepper {
    var onOutputRequestState: Driver<DetailOutputState> { get }
    var inputRequestState: BehaviorRelay<DetailInputAction> { get }

    var onTitle: Driver<String> { get }
    var onPrice: Driver<String> { get }
    var onImageUrl: Driver<String> { get }
    var onPhone: Driver<String> { get }
    var onEmail: Driver<String> { get }
    var onGeo: Driver<String> { get }
    var onDescription: Driver<String> { get }
    var onAdvertisementDetailInfo: Driver<String> { get }
}
extension DetailViewModelType {
    typealias DetailOutputState = RequestOutputState<DetailItem>
}

class DetailViewModel: DetailViewModelType {
    let inputRequestState: BehaviorRelay<DetailInputAction>

    private let outputRequestState: BehaviorRelay<DetailOutputState>
    let onOutputRequestState: Driver<DetailOutputState>

    let steps: PublishRelay<Step>
    let onStepper: Signal<Step>
    
    private let title: BehaviorRelay<String>
    let onTitle: Driver<String>

    private let price: BehaviorRelay<String>
    let onPrice: Driver<String>

    private let imageUrl: BehaviorRelay<String>
    let onImageUrl: Driver<String>

    private let phone: BehaviorRelay<String>
    var onPhone: Driver<String>

    private let email: BehaviorRelay<String>
    var onEmail: Driver<String>

    private let geo: BehaviorRelay<String>
    var onGeo: Driver<String>

    private let description: BehaviorRelay<String>
    var onDescription: Driver<String>

    private let advertisementDetailInfo: BehaviorRelay<String>
    var onAdvertisementDetailInfo: Driver<String>

    private let itemId: String
    private let service = ApiDataRequest<DetailItem>()
    private let disposeBag = DisposeBag()

    init(itemId: String) {
        inputRequestState = .init(value: .initialise(itemId: itemId))
        self.itemId = itemId

        outputRequestState = .init(value: .loading)
        onOutputRequestState = outputRequestState.asDriver()

        steps = .init()
        onStepper = steps.asSignal()

        title = .init(value: "")
        onTitle = title.asDriver()

        price = .init(value: "")
        onPrice = price.asDriver()

        imageUrl = .init(value: "")
        onImageUrl = imageUrl.asDriver()

        phone = .init(value: "")
        onPhone = phone.asDriver()

        email = .init(value: "")
        onEmail = email.asDriver()

        geo = .init(value: "")
        onGeo = geo.asDriver()

        description = .init(value: "")
        onDescription = description.asDriver()

        advertisementDetailInfo = .init(value: "")
        onAdvertisementDetailInfo = advertisementDetailInfo.asDriver()

        setupBindings()
    }

    private func setupBindings() {
        inputRequestState
            .map { action in
                switch action {
                case .initialise, .refresh: return DetailOutputState.loading
                }
            }
            .bind(to: outputRequestState)
            .disposed(by: disposeBag)

        inputRequestState
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .asObservable()
            .flatMap {[weak self] input -> Single<ApiNetworkResult<DetailItem>> in
                guard let self else { return Single.never() }
                switch input {
                case let .initialise(itemId):
                    return service.call(ApiDataServiceTarget.detailItem(id: itemId))

                case .refresh:
                    return service.call(ApiDataServiceTarget.detailItem(id: self.itemId))
                }
            }
            .map { result in
                switch result {
                case ApiNetworkResult.success(let result):
                    return RequestOutputState.loaded(result)
                case ApiNetworkResult.failure(_):
                    return RequestOutputState.error
                }
            }
            .asDriver(onErrorJustReturn: RequestOutputState.error)
            .drive(outputRequestState)
            .disposed(by: disposeBag)

        let result = onOutputRequestState.compactMap { $0.isResult }

        result.map { $0.title }
            .drive(title)
            .disposed(by: disposeBag)

        result.map { $0.price }
            .drive(price)
            .disposed(by: disposeBag)

        result.map { $0.imageURL }
            .drive(imageUrl)
            .disposed(by: disposeBag)

        result.map { $0.phoneNumber }
            .drive(phone)
            .disposed(by: disposeBag)

        result.map { $0.email }
            .drive(email)
            .disposed(by: disposeBag)

        result.map { $0.address + "\n" + $0.location }
            .drive(geo)
            .disposed(by: disposeBag)

        result.map { $0.description }
            .drive(description)
            .disposed(by: disposeBag)

        result
            .map {
            """
            Объявление №\($0.id)
            Создано: \($0.createdDate)
            """
            }
            .drive(advertisementDetailInfo)
            .disposed(by: disposeBag)
    }
}
