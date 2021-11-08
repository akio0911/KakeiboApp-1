//
//  CategoryEditTableViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/04.
//

import UIKit

final class CategoryEditTableViewCell: UITableViewCell {
    @IBOutlet private weak var categoryColorView: UIView!
    @IBOutlet private weak var categoryLabel: UILabel!

    func configure(data: CategoryData) {
        categoryColorView.backgroundColor = data.color
        categoryLabel.text = data.name
    }
}
