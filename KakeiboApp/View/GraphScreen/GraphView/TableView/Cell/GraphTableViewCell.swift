//
//  GraphTableViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/03.
//

import UIKit

final class GraphTableViewCell: UITableViewCell {
    @IBOutlet private weak var categoryColorView: UIView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var balanceLabel: UILabel!

    func configure(data: GraphData) {
        categoryColorView.backgroundColor = data.categoryData.color
        categoryLabel.text = data.categoryData.name
        balanceLabel.text =
        NumberFormatterUtility.changeToCurrencyNotation(from: data.totalBalance) ?? "0円"
    }
}
