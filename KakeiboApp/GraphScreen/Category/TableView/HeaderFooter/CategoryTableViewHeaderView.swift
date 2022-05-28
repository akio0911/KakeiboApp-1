//
//  CategoryTableViewHeaderView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/19.
//

import UIKit

class CategoryTableViewHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var totalBalanceLabel: UILabel!

    func configure(data: HeaderDateCategoryData) {
        dateLabel.text = DateUtility.stringFromDate(
            date: data.date,
            format: "yyyy年MM月d日"
        )
        totalBalanceLabel.text =
            NumberFormatterUtility.changeToCurrencyNotation(from: data.totalBalance) ?? "0円"
    }
}
