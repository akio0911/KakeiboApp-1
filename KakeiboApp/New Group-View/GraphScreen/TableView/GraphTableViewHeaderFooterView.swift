//
//  GraphTableViewHeaderFooterView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/05.
//

import UIKit

final class GraphTableViewHeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var incomeAndExpenditureLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!


    private let income = "収入"
    private let expenses = "支出"

    func configure(segmentIndex: Int, pieChartData: [GraphData], monthFirstDay: Date) {
        dateLabel.text = monthFirstDay.string(dateFormat: "YYYY年MM月")
        switch segmentIndex {
        case 0:
            incomeAndExpenditureLabel.text = expenses
            var totalExpenses = 0
            pieChartData.forEach {
                if $0.expenses != 0 { totalExpenses += $0.expenses}
            }
            switch totalExpenses {
            case 0:
                valueLabel.text = ""
            default:
                valueLabel.text =
                    String.localizedStringWithFormat(
                        "%d", totalExpenses) + "円"
            }
        default:
            incomeAndExpenditureLabel.text = income
            var totalIncome = 0
            pieChartData.forEach {
                if $0.income != 0 { totalIncome += $0.income}
            }
            switch totalIncome {
            case 0:
                valueLabel.text = ""
            default:
                valueLabel.text =
                    String.localizedStringWithFormat(
                        "%d", totalIncome) + "円"
            }
        }
    }
}
