//
//  CalendarTableViewHeaderFooterView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/24.
//

import UIKit

class CalendarTableViewHeaderFooterView: UITableViewHeaderFooterView {
    @IBOutlet private weak var titleHeaderLabel: UILabel!
    @IBOutlet private weak var balanceHeaderLabel: UILabel!

    func configure(data: HeaderDateKakeiboData) {
        titleHeaderLabel.text =
            DateUtility.stringFromDate(date: data.date, format: "YYYY年MM月d日")
        balanceHeaderLabel.text =
            NumberFormatterUtility.changeToCurrencyNotation(from: data.totalBalance) ?? "0円"
        if data.totalBalance >= 0 {
            balanceHeaderLabel.textColor =
                UIColor(named: CalendarColorName.carolinaBlue.rawValue)
        } else {
            balanceHeaderLabel.textColor =
                UIColor(named: CalendarColorName.safetyOrangeBlazeOrange.rawValue)
        }
    }
}
