import RxCocoa
import RxSwift
import SnapKit
import UIKit
import MessageUI

final class DetailViewController: UIViewController {
    var viewModel: DetailViewModelType!
    private let detailView = DetailView()

    private let disposeBag = DisposeBag()

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        viewModel.steps.accept(DetailStep.close)
    }

    @discardableResult
    func configured() -> Self {
        self.view.backgroundColor = .systemBackground

        setupViewModelBindings()
        setupViewBindings()

        return self
    }

    override func viewDidAppear(_ animated: Bool) {
        detailView.onNavigationTitle
            .map {
                let label = UILabel()
                label.attributedText = $0

                return label
            }
            .drive(self.navigationController!.navigationBar.topItem!.rx.titleView)
            .disposed(by: disposeBag)
    }
}

// MARK: Bindings
private extension DetailViewController {
    func setupViewModelBindings() {
        viewModel.onOutputRequestState
            .map { $0 }
            .drive { [unowned self] newState in
                switch newState {
                case .error: changeViewWithTransition(view: DetailErrorView())
                case .loading: changeViewWithTransition(view: DetailPlaceholderView())
                case .loaded: changeViewWithTransition(view: detailView)
                }
            }
            .disposed(by: disposeBag)

        viewModel.onTitle
            .drive(detailView.titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.onPrice
            .drive(detailView.priceLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.onGeo
            .drive(detailView.geoLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.onImageUrl
            .compactMap { URL(string: $0) }
            .drive { [unowned self] in self.detailView.iconView.kf.setImage(with: $0) }
            .disposed(by: disposeBag)

        viewModel.onDescription
            .drive(detailView.descriptionLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.onAdvertisementDetailInfo
            .drive(detailView.advertisementDetailInfoLabel.rx.text)
            .disposed(by: disposeBag)
    }

    func setupViewBindings() {
        detailView.callButton.rx.tap
            .asDriver()
            .withLatestFrom(viewModel.onPhone)
            .drive { [weak self] in self?.callNumber(phoneNumber: $0) }
            .disposed(by: disposeBag)

        detailView.mailButton.rx.tap
            .asDriver()
            .withLatestFrom(viewModel.onEmail)
            .drive { [weak self] in self?.sendMail(email: $0) }
            .disposed(by: disposeBag)
    }

    func callNumber(phoneNumber: String) {
        if let phoneCallURL = URL(string: String("tel://\(phoneNumber)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {

        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            application.open(phoneCallURL, options: [:], completionHandler: nil)
        }
      }
    }

    func sendMail(email: String) {
        let viewController = MFMailComposeViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.setToRecipients([email])

        viewController.rx.didFinish
            .map { _ in }
            .do(onNext: { viewController.dismiss(animated: true) })
            .take(1)
            .subscribe()
            .disposed(by: self.disposeBag)

        self.navigationController?.present(viewController, animated: true)
    }

    func changeViewWithTransition(view: UIView) {
        self.view.removeSubviews()

        UIView.transition(
            with: self.view,
            duration: 0.22,
            options: [.curveEaseOut, .transitionCrossDissolve],
            animations: {
                self.view.addSubview(view)
                view.snp.makeConstraints { $0.edges.equalToSuperview() }
            },
            completion: { _ in

            }
        )
    }

}
