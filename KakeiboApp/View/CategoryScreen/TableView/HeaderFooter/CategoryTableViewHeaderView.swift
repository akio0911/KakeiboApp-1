//
//  CategoryTableViewHeaderView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/19.
//

import UIKit

class CategoryTableViewHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalBalanceLabel: UILabel!

    func configure(data: HeaderDateCategoryData) {
        dateLabel.text = DateUtility.stringFromDate(
            date: data.date,
            format: "YYYY年MM月d日"
        )
        totalBalanceLabel.text = String.localizedStringWithFormat("%d", data.totalBalance) + "円"
    }
}
