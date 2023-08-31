import RxCocoa
import RxSwift
import UIKit

protocol FeedViewType where Self: UIView {
    var collectionView: FeedViewCollectionViewType! { get }
}

class FeedView: UIView, FeedViewType {
    var collectionView: FeedViewCollectionViewType!
    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configured() -> Self {
        configure()

        return self
    }
}

// MARK: View
private extension FeedView {
    func configure() {
        configureCollectionView()

        setupBindings()
    }

    func configureCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalTo(safeAreaLayoutGuide) }
    }
}

// MARK: Bindings
extension FeedView {
    private func setupBindings() {
//        createButton.rx.tap
//            .map { _ -> CGFloat in 0.3 }
//            .bind(to: createButton.rx.alpha)
//            .disposed(by: disposeBag)
//
//        createButton.rx.tap
//            .delay(.milliseconds(250))
//            .map { _ -> CGFloat in 1 }
//            .emit(to: createButton.rx.alpha)
//            .disposed(by: disposeBag)
    }
}
