import RxSwift
import UIKit

enum AppStep: NeverCloseStep {
    case start
}

class AppCoordinator: Coordinator<AppStep> {
    private let window: UIWindow
    let navigationController: UINavigationController

    init(window: UIWindow) {
        self.navigationController = UINavigationController()
        navigationController.navigationBar.tintColor = .label

        self.window = window

        super.init()
    }

    @discardableResult
    override func start() -> Observable<Step> {
        window.setup(with: navigationController)

        return self.coordinate(to: FeedCoordinator(rootViewController: navigationController))

    }
}
