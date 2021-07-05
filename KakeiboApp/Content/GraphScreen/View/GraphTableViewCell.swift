//
//  GraphTableViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/03.
//

import UIKit

class GraphTableViewCell: UITableViewCell {

    @IBOutlet private weak var categoryColorView: UIView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(graphData: GraphData) {
        categoryColorView.backgroundColor = graphData.category.color
        categoryLabel.text = graphData.category.rawValue
        expensesLabel.text = String(graphData.expenses)
    }
}
