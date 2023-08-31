import RxSwift
import Kingfisher

protocol FeedViewCollectionViewType where Self: UICollectionView {
    var viewModel: FeedViewCollectionViewModelType! { get }
    var pullToRefresh: UIRefreshControl { get }
}

class FeedViewCollectionView: UICollectionView, FeedViewCollectionViewType {
    var viewModel: FeedViewCollectionViewModelType!

    let pullToRefresh = UIRefreshControl()

    private let disposeBag = DisposeBag()

    func configured() -> Self {
        register(cellWithClass: FeedViewCollectionViewCell.self)
        refreshControl = pullToRefresh

        showsVerticalScrollIndicator = false

        setupBindings()

        return self
    }
}

private extension FeedViewCollectionView {
    func setupBindings() {
        pullToRefresh.rx.controlEvent(.valueChanged)
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .map { FeedInputAction.refresh }
            .bind(to: viewModel.inputRequestState)
            .disposed(by: disposeBag)

        viewModel.onOutputRequestState
            .map { $0.isLoading }
            .drive(pullToRefresh.rx.isRefreshing)
            .disposed(by: disposeBag)

        viewModel.onOutputRequestState
            .compactMap { state -> [CollectionDataType]? in
                if let items = state.isResult?.advertisements { return items }
                else if state.isLoading { return AdvertisementPlaceHolder.placeholderSequence }
                else if state.isError { return AdvertisementError.errorSequence }
                return nil
            }
            .drive(self.rx.items(cellIdentifier: FeedViewCollectionViewCell.cellNameIdentifier, cellType: FeedViewCollectionViewCell.self)) { _, item, cell in
                switch item {
                case let item as Advertisement:
                    cell.configure()
                    cell.titleLabel.text = item.title
                    if let imageUrl = URL(string: item.imageURL) {
                        cell.iconView.kf.setImage(with: imageUrl)
                    }
                    cell.priceLabel.text = item.price
                    cell.locationLabel.text = item.location
                    cell.dateLabel.text = item.createdDate

                case is AdvertisementPlaceHolder:
                    cell.configureWithPlaceholder()

                case is AdvertisementError:
                    cell.configureWithError()

                default: break
                }

            }
            .disposed(by: disposeBag)

        self.rx.modelSelected(CollectionDataType.self)
            .withLatestFrom(viewModel.onOutputRequestState) { ($0, $1.isResult) }
            .filter { $0.1 != nil }
            .map { $0.0 as? Advertisement }
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .asSignal(onErrorJustReturn: nil)
            .compactMap { $0 }
            .emit(to: viewModel.select)
            .disposed(by: disposeBag)

        self.rx.itemSelected
            .subscribe(onNext: { [unowned self] in self.deselectItem(at: $0, animated: true) })
            .disposed(by: disposeBag)

        viewModel.onOutputRequestState
            .map { $0.isLoading ? 0.9 : 1 }
            .drive(self.rx.alpha)
            .disposed(by: disposeBag)
    }
}
