//
//  CalendarTableViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/24.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {
    @IBOutlet private weak var balanceImageView: UIImageView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var memoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(data: (CategoryData, KakeiboData)) {
        categoryLabel.text = data.0.name
        memoLabel.text = data.1.memo
        switch data.1.balance {
        case .income(let income):
            balanceImageView.image = UIImage(named: CalendarImageName.income.rawValue)
            balanceLabel.text = NumberFormatterUtility.changeToCurrencyNotation(from: income) ?? "0円"
            balanceLabel.textColor = UIColor(named: CalendarColorName.carolinaBlue.rawValue)
        case .expense(let expense):
            balanceImageView.image = UIImage(named: CalendarImageName.expense.rawValue)
            balanceLabel.text = NumberFormatterUtility.changeToCurrencyNotation(from: expense) ?? "0円"
            balanceLabel.textColor = UIColor(named: CalendarColorName.safetyOrangeBlazeOrange.rawValue)
        }
    }
}
