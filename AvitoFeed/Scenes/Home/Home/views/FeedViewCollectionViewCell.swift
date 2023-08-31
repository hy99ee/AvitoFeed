import UIKit
import SnapKit

class FeedViewCollectionViewCell: UICollectionViewCell {
    let containerView: UIStackView = {
        let view = UIStackView()
//        view.distribution = .fill
        view.axis = .vertical
        view.spacing = 5

        return view
    }()

    let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 16)

        return label
    }()

    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)

        return label
    }()

    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray

        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        UIView.transition(
            with: containerView,
            duration: 0.3,
            options: [.curveEaseOut, .transitionCrossDissolve],
            animations: {
                self.contentView.addSubview(self.containerView)
                self.containerView.snp.makeConstraints { maker in
                    maker.top.leading.trailing.equalToSuperview()
                    maker.bottom.equalToSuperview().inset(10)
                }
            }
        )

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        containerView.removeSubviews()
        configureView()
    }

    func configureWithPlaceholder() {
        containerView.removeSubviews()
        configurePlaceholder()
        UIView.animate(withDuration: 0.3) {
            self.containerView.arrangedSubviews.forEach { $0.backgroundColor = .placeholderStyleColor }
        }
    }

    func configureWithError() {
        containerView.removeSubviews()
        configurePlaceholder()
        UIView.animate(withDuration: 0.15) {
            self.containerView.arrangedSubviews.forEach { $0.backgroundColor = .errorStyleColor }
        }
    }
}

// MARK: UI
private extension FeedViewCollectionViewCell {
    func configureView() {
        UIView.transition(
            with: containerView,
            duration: 0.3,
            options: [.curveEaseOut, .transitionCrossDissolve],
            animations: {
                self.containerView.addArrangedSubview(self.iconView)
                self.configureImageViewConstraints(self.iconView)

                self.containerView.addArrangedSubview(self.titleLabel)
                self.containerView.addArrangedSubview(self.priceLabel)
                self.containerView.addArrangedSubview(self.locationLabel)
                self.containerView.addArrangedSubview(self.dateLabel)
            }
        )
    }

    func configureImageViewConstraints(_ view: UIView) {
        view.snp.makeConstraints { maker in
            maker.height.equalTo(frame.width)
        }
    }

    func configurePlaceholder() {

        let iconView = UIView()
        iconView.backgroundColor = .placeholderStyleColor.withAlphaComponent(0.5)
        iconView.layer.cornerRadius = 10
        containerView.addArrangedSubview(iconView)
        configureImageViewConstraints(iconView)

        let detailView = UIView()
        detailView.layer.cornerRadius = 10
        detailView.backgroundColor = .placeholderStyleColor.withAlphaComponent(0.5)
        containerView.addArrangedSubview(detailView)

        UIView.transition(
            with: containerView,
            duration: 0.3,
            options: [.curveEaseOut, .showHideTransitionViews],
            animations: {
                self.containerView.addArrangedSubview(iconView)
                self.configureImageViewConstraints(iconView)
                self.containerView.addArrangedSubview(detailView)
            }
        )
    }
}
