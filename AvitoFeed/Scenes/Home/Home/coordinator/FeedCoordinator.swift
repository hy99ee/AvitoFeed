import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum FeedStep: NeverCloseStep {
    case start

    case toUser(user: Advertisement)
    case toCloseCoordinator(id: UUID)
}

class FeedCoordinator: BaseScreenCoordinator<FeedStep> {
    init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    @discardableResult
    override func start() -> Observable<Step> {

        let viewController = FeedViewController()
        let viewModel = FeedViewModel()
        viewController.viewModel = viewModel

        let collectionViewModel = FeedViewCollectionViewModel()
        collectionViewModel.onSelect.emit(to: viewModel.selected).disposed(by: disposeBag)

        let collectionView = FeedViewCollectionView(frame: .zero, collectionViewLayout: viewController.collectionViewLayout)
        collectionView.delegate = viewController
        collectionView.viewModel = collectionViewModel

        let homeView = FeedView()
        homeView.collectionView = collectionView.configured()

        viewController.homeView = homeView.configured()
        viewController.view = homeView

        openScene(with: viewController, transition: .push)

        let onStep = viewController.viewModel.onStepper

        onStep
            .asObservable()
            .compactMap { step -> Advertisement? in
                if case let FeedStep.toUser(user) = step { return user }
                else { return nil }
            }
            .flatMap { [unowned self] user in
                self.coordinate(to: DetailCoordinator(userId: user.id, rootViewController: self.rootViewController))
            }
            .subscribe()
            .disposed(by: disposeBag)


        return onStep
            .filter { $0.isClose }
            .asObservable()
            .take(1)
            .do(onNext: { [weak self] _ in self?.back(viewController: viewController) })
    }


}
