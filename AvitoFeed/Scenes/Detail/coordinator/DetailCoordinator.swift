import UIKit
import RxSwift
import SnapKit

enum DetailStep: Step, Equatable {
    case start(id: String)
    case openMail
    case close

    var isClose: Bool { self == .close }
}

class DetailCoordinator: BaseScreenCoordinator<DetailStep> {
    private var userId: String

    init(userId: String, rootViewController: UIViewController?) {
        self.userId = userId
        super.init(rootViewController: rootViewController)
    }


    @discardableResult
    override func start() -> Observable<Step> {
        let viewController = createViewController(openItemId: userId)

        self.openScene(with: viewController, transition: .push)

        return viewController.viewModel.onStepper
            .asObservable()
            .filter { $0.isClose }
            .take(1)
    }
}

private extension DetailCoordinator {
    func createViewController(openItemId itemId: String) -> DetailViewController {
        let viewController = DetailViewController()
        let viewModel = DetailViewModel(itemId: itemId)

        viewController.viewModel = viewModel

        return viewController.configured()
    }
}
