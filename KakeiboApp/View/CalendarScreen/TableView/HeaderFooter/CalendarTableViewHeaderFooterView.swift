//
//  CalendarTableViewHeaderFooterView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/24.
//

import UIKit

class CalendarTableViewHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleHeaderLabel: UILabel!
    @IBOutlet weak var expensesHeaderLabel: UILabel!

    func configure(data: HeaderDateKakeiboData) {
        titleHeaderLabel.text = data.stringDate
        expensesHeaderLabel.text =
            data.stringTotalBalance
        expensesHeaderLabel.textColor =
            UIColor(named: data.totalBalanceColorName)
    }
}
