//
//  CalendarWeekdayCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/01.
//

import UIKit

class CalendarWeekdayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var weekdayLabel: UILabel!

    // ラベルのテキストを設定
    func configure(weekday: String, at index: Int) {
        weekdayLabel.text = weekday
        switch index % 7 {
        case 0:
            weekdayLabel.textColor = UIColor(named: CalendarColorName.SafetyOrangeBlazeOrange.rawValue)
        case 6:
            weekdayLabel.textColor = UIColor(named: CalendarColorName.CarolinaBlue.rawValue)
        default:
            weekdayLabel.textColor = UIColor(named: CalendarColorName.SpaceCadet.rawValue)
        }
    }
}
