//
//  CalendarWeekdayCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/01.
//

import UIKit

class CalendarWeekdayCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var weekdayLabel: UILabel!

    // ラベルのテキストを設定
    func configure(weekday: String, at index: Int) {
        weekdayLabel.text = weekday
        switch index % 7 {
        case 0:
            weekdayLabel.textColor = R.color.sFF6800()
        case 6:
            weekdayLabel.textColor = R.color.s00A1E4()
        default:
            weekdayLabel.textColor = R.color.s333333()
        }
    }
}
