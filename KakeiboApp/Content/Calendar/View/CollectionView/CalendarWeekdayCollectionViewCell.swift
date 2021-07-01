//
//  CalendarWeekdayCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/01.
//

import UIKit

class CalendarWeekdayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var weekdayLabel: UILabel!

    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self),
                                  bundle: nil) }

    // ラベルのテキストを設定
    func configure(weekday: String, at index: Int) {
        weekdayLabel.text = weekday
        switch index % 7 {
        case 0:
            weekdayLabel.textColor = UIColor.orangeRedCrayola
        case 6:
            weekdayLabel.textColor = UIColor.celadonBlue
        default:
            weekdayLabel.textColor = UIColor.spaceCadet
        }
    }
}
