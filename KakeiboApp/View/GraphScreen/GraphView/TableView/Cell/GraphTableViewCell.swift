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
    @IBOutlet weak var balanceLabel: UILabel!

    func configure(data: GraphData) {
        categoryColorView.backgroundColor = data.categoryData.color
        categoryLabel.text = data.categoryData.name
        balanceLabel.text =
        NumberFormatterUtility.changeToCurrencyNotation(from: data.totalBalance) ?? "0円"
    }
}

//extension Category.Income {
//    var colorName: String {
//        switch self {
//        case .salary:
//            return GraphColorName.CadetBlue.rawValue
//        case .allowance:
//            return GraphColorName.Blush.rawValue
//        case .bonus:
//            return GraphColorName.ImperialRed.rawValue
//        case .sideJob:
//            return GraphColorName.LightCoral.rawValue
//        case .investment:
//            return GraphColorName.PinkLavender.rawValue
//        case .extraordinaryIncome:
//            return GraphColorName.PlumpPurple.rawValue
//        }
//    }
//}
//
//extension Category.Expense {
//    var colorName: String {
//        switch self {
//        case .consumption:
//            return GraphColorName.CadetBlue.rawValue
//        case .life:
//            return GraphColorName.Blush.rawValue
//        case .miscellaneous:
//            return GraphColorName.ImperialRed.rawValue
//        case .transpotation:
//            return GraphColorName.LightCoral.rawValue
//        case .medical:
//            return GraphColorName.PinkLavender.rawValue
//        case .communication:
//            return GraphColorName.PlumpPurple.rawValue
//        case .vehicleFee:
//            return GraphColorName.Popstar.rawValue
//        case .entertainment:
//            return GraphColorName.Sage.rawValue
//        case .other:
//            return GraphColorName.Tan.rawValue
//        }
//    }
//}
