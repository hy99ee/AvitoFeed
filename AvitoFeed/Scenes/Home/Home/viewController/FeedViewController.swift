import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class FeedViewController: UIViewController {
    var homeView: FeedViewType!
    var viewModel: FeedViewModelType!

    private let disposeBag = DisposeBag()
}

// MARK: UICollectionView
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    private var itemsInRow: Int { 2 }
    private var collectionSectionInset: UIEdgeInsets { UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) }
    private var collectionLineSpacing: CGFloat { 10 }
    private var collectionItemSpacing: CGFloat { 10 }

    var collectionViewLayout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = self.collectionSectionInset
        layout.scrollDirection = .vertical

        return layout
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let widthPadding = collectionSectionInset.left + collectionSectionInset.right + collectionItemSpacing * (CGFloat(itemsInRow) - 1)
        let screenWidth = UIScreen.main.bounds.width

        let rectangleSide = (screenWidth - widthPadding) / CGFloat(itemsInRow)

        return CGSize(width: rectangleSide, height: rectangleSide + 115)
    }
}
