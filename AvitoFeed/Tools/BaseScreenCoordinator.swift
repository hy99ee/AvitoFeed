import UIKit
import RxSwift

class BaseScreenCoordinator<ResultType: Step>: Coordinator<ResultType> {
    enum TransitionType {
        case push
        case present
    }

    weak var rootViewController: UIViewController?

    init(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
    }

    func back(viewController: UIViewController? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        let viewController = viewController ?? rootViewController

        if let navigationController = viewController?.navigationController,
           navigationController.viewControllers.first != viewController {
            navigationController.popViewController(animated: animated)
            return
        }

        if let presentingController = viewController?.presentingViewController {
            presentingController.dismiss(animated: animated, completion: completion)
            return
        }

        viewController?.dismiss(animated: animated, completion: completion)
    }

    func openScene(
        with presentedViewController: UIViewController,
        in viewController: UIViewController? = nil,
        transition: TransitionType,
        animated: Bool = true
    ) {
        let presentingViewController = viewController ?? self.rootViewController

        switch presentingViewController {
        case let navigationViewController as UINavigationController:
            switch transition {
            case .push:
                presentedViewController.title = ""
                navigationViewController.pushViewController(presentedViewController, animated: animated)
            case .present:
                navigationViewController.present(presentedViewController, animated: animated)
            }

        default:
            presentingViewController?.present(presentedViewController, animated: animated)
        }
    }
}

