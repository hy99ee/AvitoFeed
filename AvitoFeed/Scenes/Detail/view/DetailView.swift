import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

class DetailView: UIView {
    private let navigationTitle: BehaviorRelay<NSAttributedString>
    let onNavigationTitle: Driver<NSAttributedString>

    let titleLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 25)

        return label
    }()

    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)

        return label
    }()

    let geoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 0

        return label
    }()

    let advertisementDetailInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = .label

        return label
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset = .init(top: 0, left: 0, bottom: 300, right: 0)

        return scrollView
    }()

    let descriptionLabel: UILabel = {
        let descriptionView = UILabel()
        descriptionView.font = .systemFont(ofSize: 20)
        descriptionView.numberOfLines = 0
        

        return descriptionView
    }()

    let callButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen.withAlphaComponent(0.8)
        button.setTitle("Позвонить", for: .normal)
        button.setTitle("Позвонить", for: .selected)
        button.titleLabel?.font = .systemFont(ofSize: 19)

        button.layer.cornerRadius = 15

        return button
    }()

    let mailButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.8)
        button.setTitle("Написать", for: .normal)
        button.setTitle("Нaписать", for: .selected)
        button.titleLabel?.font = .systemFont(ofSize: 19)

        button.layer.cornerRadius = 15

        return button
    }()

    private let scrollViewContainer: UIStackView = {
        let view = UIStackView()

        view.axis = .vertical
        view.spacing = 16

        return view
    }()


    let iconView: UIImageView = {
        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let disposeBag = DisposeBag()

    init() {
        self.navigationTitle = .init(value: NSAttributedString())
        self.onNavigationTitle = navigationTitle.asDriver()

        super.init(frame: .zero)

        configure()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = .systemBackground

        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        scrollView.addSubview(iconView)
        iconView.snp.makeConstraints { maker in
            maker.top.leading.trailing.equalToSuperview()
            maker.height.equalTo(UIScreen.main.bounds.width)
        }

        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.snp.makeConstraints { maker in
            maker.top.equalTo(iconView.snp.bottom).offset(10)
            maker.leading.trailing.bottom.width.equalToSuperview()
        }

        let descriptionView = UIView()
        let headerDescription = UILabel()
        headerDescription.text = "Описание"
        headerDescription.font = .boldSystemFont(ofSize: 25)
        descriptionView.addSubview(headerDescription)
        headerDescription.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        descriptionView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(headerDescription.snp.bottom).offset(6)
            $0.bottom.leading.trailing.equalToSuperview()
        }


        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        buttonStack.snp.makeConstraints { $0.height.equalTo(45) }
        buttonStack.addArrangedSubview(mailButton)
        buttonStack.addArrangedSubview(callButton)

//        let userView = UIView()
        let userStackView = UIStackView()
        userStackView.axis = .vertical
        userStackView.spacing = 8
        let headerUser = UILabel()
        headerUser.text = "Пользователь"
        headerUser.font = .boldSystemFont(ofSize: 25)

        let headerUserDescription = UILabel()
        headerUserDescription.text = "Отвечает на сообщения за несколько часов"
        headerUserDescription.numberOfLines = 2
        headerUserDescription.font = .systemFont(ofSize: 17)
        headerUserDescription.textColor = .systemGray

        let mockHeaderUserStars = UILabel()
        let attributedStars = NSMutableAttributedString(string: "4,0 ★★★★☆")
        attributedStars.addAttribute(.foregroundColor, value: UIColor.systemYellow, range: attributedStars.mutableString.range(of: "★★★★"))

        mockHeaderUserStars.attributedText = attributedStars
        mockHeaderUserStars.font = .systemFont(ofSize: 18)

        userStackView.addArrangedSubview(headerUser)
        userStackView.addArrangedSubview(headerUserDescription)
        userStackView.addArrangedSubview(mockHeaderUserStars)
        userStackView.addArrangedSubview(buttonStack)

        scrollViewContainer.addArrangedSubview(priceLabel)
        scrollViewContainer.addArrangedSubview(titleLabel)
        scrollViewContainer.addArrangedSubview(userStackView)
        scrollViewContainer.addArrangedSubview(geoLabel)
        scrollViewContainer.addArrangedSubview(descriptionView)
        scrollViewContainer.addArrangedSubview(advertisementDetailInfoLabel)

        scrollViewContainer.arrangedSubviews.forEach { view in
            view.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(13)
                $0.trailing.equalToSuperview().inset(13)
            }
        }
    }

    private func setupBindings() {
        scrollView.rx.contentOffset
            .map { $0.y + self.safeAreaInsets.top }
            .map { [unowned self] offset in
                if offset > self.iconView.bounds.height {
                    let attributedText = NSMutableAttributedString(string: self.titleLabel.text!)

                    let alpha = (offset - self.iconView.bounds.height) / 80

                    attributedText.addAttribute(.foregroundColor, value: UIColor.label.withAlphaComponent(alpha), range: NSRange(location: 0, length: self.titleLabel.text!.count))

                    return attributedText
                }
                else { return NSAttributedString(string: "") }
            }
            .bind(to: navigationTitle)
            .disposed(by: disposeBag)
    }
}

class DetailPlaceholderView: UIView {
    init() {
        super.init(frame: .zero)

        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate let iconView = UIView()
    let scrollViewContainer = UIStackView()

    fileprivate func configure() {
        backgroundColor = .systemBackground

        let scrollView = UIScrollView()
        scrollView.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)

        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }


        iconView.backgroundColor = UIColor.placeholderStyleColor
        
        scrollView.addSubview(iconView)
        iconView.snp.makeConstraints { maker in
            maker.top.leading.trailing.equalToSuperview()
            maker.height.equalTo(UIScreen.main.bounds.width)
        }

        scrollViewContainer.axis = .vertical
        scrollViewContainer.spacing = 18

        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.snp.makeConstraints { maker in
            maker.top.equalTo(iconView.snp.bottom)
            maker.leading.trailing.bottom.width.equalToSuperview()
        }

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        buttonStack.snp.makeConstraints { $0.height.equalTo(50) }

        buttonStack.addArrangedSubview(UIView.makePlaceholderView())
        buttonStack.addArrangedSubview(UIView.makePlaceholderView())

        scrollViewContainer.addArrangedSubview(UIView.makePlaceholderView())
        scrollViewContainer.addArrangedSubview(
            UIView.makePlaceholderView(
                width: UIScreen.main.bounds.width / 2.2,
                height: 51
            )
        )
        scrollViewContainer.addArrangedSubview(UIView.makePlaceholderView(height: 45))
        scrollViewContainer.addArrangedSubview(
            UIView.makePlaceholderView(
                width: UIScreen.main.bounds.width / 1.5,
                height: 45
            )
        )
        scrollViewContainer.addArrangedSubview(buttonStack)
        scrollViewContainer.addArrangedSubview(
            UIView.makePlaceholderView(
                width: UIScreen.main.bounds.width / 2.5,
                height: 33
            )
        )
        scrollViewContainer.addArrangedSubview(UIView.makePlaceholderView(height: 200))

        scrollViewContainer.addArrangedSubview(
            UIView.makePlaceholderView(
                width: UIScreen.main.bounds.width / 3,
                height: 35
            )
        )

        scrollViewContainer.arrangedSubviews.forEach { view in
            view.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(13)
                $0.trailing.equalToSuperview().inset(13)
            }
        }
    }
}

class DetailErrorView: DetailPlaceholderView {
    override func configure() {
        super.configure()

        iconView.backgroundColor = UIColor.errorStyleColor
        scrollViewContainer.arrangedSubviews.forEach { view in
            if let stack = view as? UIStackView {
                stack.arrangedSubviews.forEach { secondaryView in
                    if secondaryView.backgroundColor == .clear { return }
                    secondaryView.backgroundColor = UIColor.errorStyleColor
                }
            } else {
                view.backgroundColor = UIColor.errorStyleColor
            }
        }
    }

}
