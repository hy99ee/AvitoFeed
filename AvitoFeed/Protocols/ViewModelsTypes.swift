import RxCocoa
import RxSwift

// MARK: - Observable view model types
protocol Step {
    var isClose: Bool { get }
}
protocol NeverCloseStep: Step {}
extension NeverCloseStep {
    var isClose: Bool { false }
}

protocol Steppable {
    var onStepper: Signal<Step> { get }
}
protocol Stepper {
    var steps: PublishRelay<Step> { get }
}
extension Steppable {
    func bind(to stepper: Stepper) -> Disposable {
        self.onStepper
            .emit(to: stepper.steps)
    }
}
