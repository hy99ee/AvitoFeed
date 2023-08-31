import Foundation
import RxSwift

class Coordinator<ResultType: Step> {
    typealias CoordinationResult = ResultType

    let disposeBag = DisposeBag()

    private let identifier = UUID()
    private var childCoordinators = [UUID: Any]()

    @discardableResult
    func start() -> Observable<Step> {
        fatalError("start() has not been implemented")
    }

    @discardableResult
    func coordinate<T: Step>(to coordinator: Coordinator<T>) -> Observable<Step> {
        coordinator.start()
            .do(
                onNext: { [unowned self] in if $0.isClose { self.release(coordinator: coordinator) } },
                onSubscribe: { [unowned self] in self.store(coordinator: coordinator) }
            )
    }

    private func store<T>(coordinator: Coordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    private func release<T>(coordinator: Coordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }
}
