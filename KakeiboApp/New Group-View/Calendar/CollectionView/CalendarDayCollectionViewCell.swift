//
//  CalendarDayCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/01.
//

import UIKit

class CalendarDayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        expensesLabel.frame = CGRect(x: contentView.center.x
                                        - contentView.bounds.width / 2,
                                     y: dayLabel.frame.maxY + 7,
                                     width: contentView.bounds.width,
                                     height: 17)
    }

    // ラベルのテキストを設定
    func configure(date: Date, expenses: Int, at index: Int, isDisplayedMonth: Bool) {

        dayLabel.text = date.string(dateFormat: "d")
        // 日付のテキストカラーを曜日毎に色分けしている
        switch index % 7 {
        case 0:
            dayLabel.textColor = UIColor.orangeRedCrayola
        case 6:
            dayLabel.textColor = UIColor.celadonBlue
        default:
            dayLabel.textColor = UIColor.spaceCadet
        }
        // 表示月でない時、日付のテキストカラーをグレーにする
        if !isDisplayedMonth { dayLabel.textColor = .gray }
        expensesLabel.text = expenses != 0 ?
            String.localizedStringWithFormat(
                "%d", expenses) + "円" : ""
        expensesLabel.textColor =
            expenses >= 0 ? UIColor.celadonBlue : UIColor.orangeRedCrayola
    }
}
