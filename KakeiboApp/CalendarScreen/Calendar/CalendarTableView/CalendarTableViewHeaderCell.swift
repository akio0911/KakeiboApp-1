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
        dateLabel.text = DateUtility.stringFromDate(date: calendarItem.date, format: "yyyy年MM月dd日")
        totalLabel.text = NumberFormatterUtility.changeToCurrencyNotation(from: calendarItem.totalBalance) ?? "0円"
        if calendarItem.totalBalance >= 0 {
            totalLabel.textColor = R.color.s00A1E4()
        } else {
            totalLabel.textColor = R.color.sFF6800()
        }
    }
}
