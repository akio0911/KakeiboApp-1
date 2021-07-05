//
//  CalendarTableViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/24.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet private weak var expensesImageView: UIImageView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var expensesLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCellObject(data: IncomeAndExpenditure) {
        categoryLabel.text = data.category.rawValue
        memoLabel.text = data.memo
        expensesLabel.text = String(data.expenses)
        expensesLabel.textColor =
            data.expenses >= 0 ? UIColor.celadonBlue : UIColor.orangeRedCrayola
        expensesImageView.image =
            data.expenses >= 0 ? UIImage(named: "Income") : UIImage(named: "Expense")
    }
}
