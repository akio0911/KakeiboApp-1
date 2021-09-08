//
//  CalendarDayCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/01.
//

import UIKit

class CalendarDayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        balanceLabel.frame = CGRect(x: contentView.center.x
                                        - contentView.bounds.width / 2,
                                     y: dayLabel.frame.maxY + 7,
                                     width: contentView.bounds.width,
                                     height: 17)
    }

    // ラベルのテキストを設定
    func configure(data: DayItemData, index: Int) {
        dayLabel.text = data.stringDay
        balanceLabel.text = data.stringTotalBalance

        // 日付のテキストカラーを曜日毎に色分けしている
        switch index % 7 {
        case 0:
            dayLabel.textColor = UIColor(named: CalendarColorName.OrangeRedCrayola.rawValue)
        case 6:
            dayLabel.textColor = UIColor(named: CalendarColorName.CeladonBlue.rawValue)
        default:
            dayLabel.textColor = UIColor(named: CalendarColorName.SpaceCadet.rawValue)
        }
//        // 表示月でない時、日付のテキストカラーをグレーにする
//        if !isDisplayedMonth { dayLabel.textColor = .gray }
//        expensesLabel.text = expenses != 0 ?
//            String.localizedStringWithFormat(
//                "%d", expenses) + "円" : ""
//        expensesLabel.textColor =
//            expenses >= 0 ? UIColor.celadonBlue : UIColor.orangeRedCrayola
    }
}
