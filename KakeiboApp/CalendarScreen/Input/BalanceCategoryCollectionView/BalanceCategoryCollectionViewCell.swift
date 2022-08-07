//
//  BalanceCategoryCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/08/06.
//

import UIKit

final class BalanceCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var categoryCollectionView: UICollectionView!

    weak var delegate: BalanceCategoryCollectionViewCellDelegate?

    private var categoryDataArray: [CategoryData] = []
    var selectedIndex: Int = 0 {
        didSet {
            categoryCollectionView.selectItem(at: [0, selectedIndex], animated: false, scrollPosition: .top)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }

    func configure(categoryDataArray: [CategoryData], selectedIndex: Int) {
        self.categoryDataArray = categoryDataArray
        self.selectedIndex = selectedIndex
        categoryCollectionView.reloadData()
    }

    private func setupCollectionView() {
        categoryCollectionView.register(
            CategoryCollectionViewCell.nib,
            forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier
        )
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
    }
}

// MARK: - BalanceCategoryCollectionViewCell
extension BalanceCategoryCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryDataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.identifier,
            for: indexPath
        ) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(categoryData: categoryDataArray[indexPath.row])
        if indexPath.row == selectedIndex {
            collectionView.selectItem(at: [0, selectedIndex], animated: false, scrollPosition: .top)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension BalanceCategoryCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpace: CGFloat = 10
        let itemWidth = (self.frame.width - itemSpace * 2) / 3
        return CGSize(width: itemWidth, height: 60)
        // TODO: collectionView.framが正しく取得できない理由を調べる
        // 一旦、selfのframeで正しい値が取れため、使用中
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - UICollectionViewDelegate
extension BalanceCategoryCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItemAt(indexPath: indexPath)
    }
}

// MARK: - BalanceCategoryCollectionViewCellDelegate
protocol BalanceCategoryCollectionViewCellDelegate: AnyObject {
    func didSelectItemAt(indexPath: IndexPath)
}
