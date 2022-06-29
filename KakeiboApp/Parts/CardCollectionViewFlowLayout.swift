//
//  CardCollectionViewFlowLayout.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/06/24.
//

import UIKit

protocol CardCollectionViewFlowLayoutDelegate: AnyObject {
    func didSwipeCard(displayCardIndexPath: IndexPath)
}

final class CardCollectionViewFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: CardCollectionViewFlowLayoutDelegate?
    
    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = 16
        sectionInset = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 26)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var layoutAttributesForPaging: [UICollectionViewLayoutAttributes]?

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, let targetAttributes = layoutAttributesForPaging else { return proposedContentOffset }
        let nextAttributes: UICollectionViewLayoutAttributes?
        if velocity.x == 0 {
            // スワイプせずに指を離した場合は、画面中央から一番近い要素を取得する
            nextAttributes = layoutAttributesForNearbyCenterX(in: targetAttributes, collectionView: collectionView)
        } else if velocity.x > 0 {
            // 左スワイプの場合は、最後の要素を取得する
            nextAttributes = targetAttributes.last
        } else {
            // 右スワイプの場合は、先頭の要素を取得する
            nextAttributes = targetAttributes.first
        }
        guard let attributes = nextAttributes else { return proposedContentOffset }
        delegate?.didSwipeCard(displayCardIndexPath: attributes.indexPath)
        // 画面左端からセルのマージンを引いた座標を返して画面中央に表示されるようにする
        let cellLeftMargin = (collectionView.bounds.width - attributes.bounds.width) / 2
        return CGPoint(x: attributes.frame.minX - cellLeftMargin, y: collectionView.contentOffset.y)
    }

    // 画面中央に一番近いセルの attributes を取得する
    private func layoutAttributesForNearbyCenterX(in attributes: [UICollectionViewLayoutAttributes], collectionView: UICollectionView) -> UICollectionViewLayoutAttributes? {
        let intervalArray: [CGFloat] = attributes.map { abs($0.center.x - collectionView.contentOffset.x - collectionView.frame.width / 2) }
        let minimumInterval = intervalArray.min()
        let minIndex = intervalArray.firstIndex(of: minimumInterval!)!
        return attributes[minIndex]
    }

    // UIScrollViewDelegate scrollViewWillBeginDragging から呼ぶ
    func prepareForPaging() {
        // 1ページずつページングさせるために、あらかじめ表示されている attributes の配列を取得しておく
        guard let collectionView = collectionView else { return }
        // 表示領域の layoutAttributes を取得し、X座標でソートする
        // rectの範囲内に存在するアイテムのAttributesを返す(layoutAttributesForElements(in:))
        let expandedVisibleRect = CGRect(x: collectionView.contentOffset.x,
                                         y: collectionView.frame.minY,
                                         width: collectionView.bounds.width,
                                         height: collectionView.bounds.height)
        layoutAttributesForPaging = layoutAttributesForElements(in: expandedVisibleRect)?.sorted { $0.frame.minX < $1.frame.minX }
    }
}
