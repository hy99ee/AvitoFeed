import MessageUI
import RxCocoa
import RxSwift
import UIKit

extension Reactive {
    func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
        guard let returnValue = object as? T else {
            throw RxCocoaError.castingError(object: object, targetType: resultType)
        }

        return returnValue
    }
}

class RxMFMailComposeViewControllerDelegateProxy: DelegateProxy<MFMailComposeViewController, MFMailComposeViewControllerDelegate> {
    private(set) weak var controller: MFMailComposeViewController?

    init(controller: MFMailComposeViewController) {
        self.controller = controller

        super.init(parentObject: controller, delegateProxy: RxMFMailComposeViewControllerDelegateProxy.self)
    }
}

// MARK: DelegateProxyType
extension RxMFMailComposeViewControllerDelegateProxy: DelegateProxyType {
    static func registerKnownImplementations() {
        self.register { RxMFMailComposeViewControllerDelegateProxy(controller: $0) }
    }

    static func currentDelegate(for object: ParentObject) -> Delegate? {
        object.mailComposeDelegate
    }

    static func setCurrentDelegate(_ delegate: Delegate?, to object: ParentObject) {
        object.mailComposeDelegate = delegate
    }
}

// MARK: MFMailComposeViewControllerDelegate
extension RxMFMailComposeViewControllerDelegateProxy: MFMailComposeViewControllerDelegate {}


extension Reactive where Base: MFMailComposeViewController {
    var mailComposeDelegate: RxMFMailComposeViewControllerDelegateProxy { RxMFMailComposeViewControllerDelegateProxy.proxy(for: self.base) }
}

extension Reactive where Base: MFMailComposeViewController {
    var didFinish: ControlEvent<MFMailComposeResult> {
        ControlEvent<MFMailComposeResult>(
            events: self.mailComposeDelegate
                .methodInvoked(#selector(MFMailComposeViewControllerDelegate.mailComposeController(_:didFinishWith:error:)))
                .map { result -> MFMailComposeResult in
                    guard let rawValue = result[1] as? Int, let mailComposeResult = MFMailComposeResult(rawValue: rawValue) else {
                        return try self.castOrThrow(MFMailComposeResult.self, result[1])
                    }

                    return mailComposeResult
                }
        )
    }
}
