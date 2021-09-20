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

    func configure(data: CellDateKakeiboData) {
        switch data.category {
        case .income(let category):
            categoryLabel.text = category.rawValue
        case .expense(let category):
            categoryLabel.text = category.rawValue
        }
        memoLabel.text = data.memo
        switch data.balance {
        case .income(let income):
            balanceImageView.image = UIImage(named: CalendarImageName.Income.rawValue)
            balanceLabel.text = NumberFormatterUtility.changeToCurrencyNotation(from: income) ?? "0円"
            balanceLabel.textColor = UIColor(named: CalendarColorName.CarolinaBlue.rawValue)
        case .expense(let expense):
            balanceImageView.image = UIImage(named: CalendarImageName.Expense.rawValue)
            balanceLabel.text = NumberFormatterUtility.changeToCurrencyNotation(from: expense) ?? "0円"
            balanceLabel.textColor = UIColor(named: CalendarColorName.SafetyOrangeBlazeOrange.rawValue)
        }
    }
}
