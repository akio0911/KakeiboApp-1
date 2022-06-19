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

    func configure(data: KakeiboData) {
        memoLabel.text = data.memo
        switch data.balance {
        case .income(let income):
            balanceLabel.text =
                NumberFormatterUtility.changeToCurrencyNotation(from: income) ?? "0円"
        case .expense(let expense):
            balanceLabel.text =
                NumberFormatterUtility.changeToCurrencyNotation(from: expense) ?? "0円"
        }
    }
}
