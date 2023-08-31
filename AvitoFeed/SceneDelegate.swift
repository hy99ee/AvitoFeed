import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let disposeBag = DisposeBag()
    private var appCoordinator: AppCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        self.openInitialScreen(windowScene: windowScene)
    }

    func openInitialScreen(windowScene: UIWindowScene) {
        self.window = UIWindow(windowScene: windowScene)

        self.appCoordinator = AppCoordinator(window: self.window!)
        self.appCoordinator.start()
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
