//
//  CalendarTableViewHeaderFooterView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/24.
//

import UIKit

class CalendarTableViewHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleHeaderLabel: UILabel!
    @IBOutlet weak var balanceHeaderLabel: UILabel!

    func configure(data: HeaderDateKakeiboData) {
        titleHeaderLabel.text =
            DateUtility.stringFromDate(date: data.date, format: "YYYY年MM月d日")
        balanceHeaderLabel.text = String.localizedStringWithFormat("%d", data.totalBalance) + "円"
        if data.totalBalance >= 0 {
            balanceHeaderLabel.textColor =
                UIColor(named: CalendarColorName.CarolinaBlue.rawValue)
        } else {
            balanceHeaderLabel.textColor =
                UIColor(named: CalendarColorName.SafetyOrangeBlazeOrange.rawValue)
        }
    }
}
