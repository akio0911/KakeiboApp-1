//
//  CalendarTableViewHeaderCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/06/29.
//

import UIKit

class CalendarTableViewHeaderCell: UITableViewCell {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!

    func configure(calendarItem: CalendarItem) {
        dateLabel.text = DateUtility.stringFromDate(date: calendarItem.date, format: "yyyy年MM月d日")
        totalLabel.text = NumberFormatterUtility.changeToCurrencyNotation(from: calendarItem.totalBalance) ?? "0円"
        if calendarItem.totalBalance >= 0 {
            totalLabel.textColor =
                UIColor(named: CalendarColorName.carolinaBlue.rawValue)
        } else {
            totalLabel.textColor =
                UIColor(named: CalendarColorName.safetyOrangeBlazeOrange.rawValue)
        }
    }
}
