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

    // ラベルのテキストを設定
    func configure(data: DayItemData, index: Int) {
        dayLabel.text = DateUtility.stringFromDate(date: data.date, format: "d")

        if data.totalBalance != 0 {
            if data.totalBalance > 0 {
                balanceLabel.text = String(data.totalBalance)
                balanceLabel.textColor = UIColor(named: CalendarColorName.carolinaBlue.rawValue)
            } else {
                balanceLabel.text = String(-data.totalBalance)
                balanceLabel.textColor = UIColor(named: CalendarColorName.safetyOrangeBlazeOrange.rawValue)
            }
        } else {
            balanceLabel.text = ""
        }

        // 日付のテキストカラーを曜日毎に色分けしている
        switch index % 7 {
        case 0:
            dayLabel.textColor = UIColor(named: CalendarColorName.safetyOrangeBlazeOrange.rawValue)
        case 6:
            dayLabel.textColor = UIColor(named: CalendarColorName.carolinaBlue.rawValue)
        default:
            dayLabel.textColor = UIColor(named: CalendarColorName.spaceCadet.rawValue)
        }
    }
}
