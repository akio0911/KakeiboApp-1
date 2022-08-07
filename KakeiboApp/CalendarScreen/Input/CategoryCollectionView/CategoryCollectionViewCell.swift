//
//  CategoryCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/07/18.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 2 : 1
        }
    }

    func configure(categoryData: CategoryData) {
        nameLabel.text = categoryData.name
    }
}
