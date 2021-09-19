//
//  CategoryTableViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/19.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var memoLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!

    func configure(data: CellDateCategoryData) {
        memoLabel.text = data.memo
        switch data.balance {
        case .income(let income):
            balanceLabel.text = String.localizedStringWithFormat("%d", income) + "円"
        case .expense(let expense):
            balanceLabel.text = String.localizedStringWithFormat("%d", expense) + "円"
        }
    }
}
