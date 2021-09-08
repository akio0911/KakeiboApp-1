//
//  GraphTableViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/03.
//

import UIKit

class GraphTableViewCell: UITableViewCell {

    @IBOutlet private weak var categoryColorView: UIView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    func configure(data: CellCategoryKakeiboData) {
        categoryColorView.backgroundColor = UIColor(named: data.viewColorName)
        categoryLabel.text = data.stringCategory
        balanceLabel.text = data.stringTotalBalance
    }
}
