//
//  GraphCardCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/08/17.
//

import UIKit

class GraphCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var segmentedControlView: BalanceSegmentedControlView!
    @IBOutlet private weak var pieChartView: PieChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
