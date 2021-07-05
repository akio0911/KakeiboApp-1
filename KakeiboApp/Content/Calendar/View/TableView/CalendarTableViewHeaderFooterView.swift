//
//  CalendarTableViewHeaderFooterView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/24.
//

import UIKit

class CalendarTableViewHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleHeaderLabel: UILabel!
    @IBOutlet weak var expensesHeaderLabel: UILabel!

    func setObject(title: String, expenses: Int) {
        titleHeaderLabel.text = title
        expensesHeaderLabel.text = String(expenses)
        expensesHeaderLabel.textColor =
            expenses >= 0 ? UIColor.celadonBlue : UIColor.orangeRedCrayola
    }
}
