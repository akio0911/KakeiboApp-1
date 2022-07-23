//
//  CategoryCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/07/18.
//

import UIKit

// TODO: cell選択時に枠線を太くする
final class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    func configure(categoryData: CategoryData) {
        nameLabel.text = categoryData.name
    }
}
