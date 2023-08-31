import UIKit

extension UIWindow {
    func setup(with rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.makeKeyAndVisible()
    }
}

extension UINavigationItem {
    internal func setAppearance(_ appearance: UINavigationBarAppearance) {
        self.standardAppearance = appearance
        self.compactAppearance = appearance
        self.scrollEdgeAppearance = appearance

        if #available(iOS 15.0, *) {
            self.compactScrollEdgeAppearance = appearance
        }
    }
}

extension UIView {
    func appendTo(_ array: inout [UIView]) -> Self {
        array.append(self)

        return self
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.cellNameIdentifier)
    }
}

extension UICollectionViewCell {
    static var cellNameIdentifier: String {
        String(describing: self)
    }
}

extension UIView {
    @objc
    func removeSubviews() {
        subviews.forEach { subview in
            subview.snp.removeConstraints()
            subview.removeFromSuperview()
        }
    }
}

extension UIStackView {
    @objc
    override func removeSubviews() {
        super.removeSubviews()

        arrangedSubviews.forEach { arrangedSubview in
            self.removeArrangedSubview(arrangedSubview)
            arrangedSubview.snp.removeConstraints()
            arrangedSubview.removeFromSuperview()
        }
    }
}

extension UIView {
    static func makePlaceholderView(height: CGFloat? = nil) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.placeholderStyleColor
        if let height { view.snp.makeConstraints { $0.height.equalTo(height) } }
        view.layer.cornerRadius = 10

        return view
    }

    static func makePlaceholderView(width: CGFloat, height: CGFloat) -> UIView {
        let buttonStack = UIStackView()
//        buttonStack.axis = .horizontal
        
//        buttonStack.distribution = .

        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.placeholderStyleColor

        let emptyView = UIView()
        emptyView.backgroundColor = .clear

        buttonStack.addArrangedSubview(view)
        view.snp.makeConstraints { $0.width.equalTo(width) }

        buttonStack.addArrangedSubview(emptyView)

        buttonStack.snp.makeConstraints { maker in
            maker.height.equalTo(height)
        }

        return buttonStack
    }
}

extension UIView {
    static func makePlaceholderLabel(ofSize size: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: size)
        label.text = " "
        label.backgroundColor = UIColor.placeholderStyleColor

        return label
    }
}


extension UIColor {
    static let errorStyleColor = UIColor(red: 1, green: 75 / 255, blue: 75 / 255, alpha: 0.8)
    static let placeholderStyleColor = UIColor.lightGray.withAlphaComponent(0.3)
}


