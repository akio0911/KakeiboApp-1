//
//  CalendarDayCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/01.
//

import UIKit

class CalendarDayCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!

    override var isSelected: Bool {
        didSet {
            dayLabel.backgroundColor = isSelected ? R.color.sFFF2EB() : .clear
            dayLabel.font = isSelected ? .boldSystemFont(ofSize: 12) : .systemFont(ofSize: 12)
        }
    }

    // ラベルのテキストを設定
    func configure(calendarItem: CalendarItem, index: Int) {
        dayLabel.text = DateUtility.stringFromDate(date: calendarItem.date, format: "d")

        if calendarItem.totalBalance != 0 {
            if calendarItem.totalBalance > 0 {
                balanceLabel.text = String(calendarItem.totalBalance)
                balanceLabel.textColor = R.color.s00A1E4()
            } else {
                balanceLabel.text = String(-calendarItem.totalBalance)
                balanceLabel.textColor = R.color.sFF6800()
            }
        } else {
            balanceLabel.text = ""
        }

        // 日付のテキストカラーを曜日毎に色分けしている
        switch index % 7 {
        case 0:
            dayLabel.textColor = R.color.sFF6800()
        case 6:
            dayLabel.textColor = R.color.s00A1E4()
        default:
            dayLabel.textColor = R.color.s333333()
        }

        if !calendarItem.isCalendarMonth {
            dayLabel.textColor = R.color.sD1D1D6()
        }
    }
}
