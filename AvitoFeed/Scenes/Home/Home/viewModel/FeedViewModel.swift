import RxCocoa
import RxSwift

protocol FeedViewModelType: Steppable, Stepper {}

class FeedViewModel: FeedViewModelType {
    let selected: PublishRelay<Advertisement>
    private let onSelected: Signal<Advertisement>

    let steps: PublishRelay<Step>
    let onStepper: Signal<Step>

    let disposeBag = DisposeBag()

    init() {
        self.steps = .init()
        self.onStepper = steps.asSignal()

        self.selected = .init()
        self.onSelected = selected.asSignal()

        setupBindings()
    }
}

// MARK: Bindings
extension FeedViewModel {
    private func setupBindings() {
        onSelected
            .map { FeedStep.toUser(user: $0) }
            .emit(to: steps)
            .disposed(by: disposeBag)
    }
}
