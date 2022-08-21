//
//  GraphCardCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/08/17.
//

import UIKit

protocol GraphCardCollectionViewCellDelegate: AnyObject {
    func segmentedControlValueChanged(selectedSegmentIndex: Int)
}

final class GraphCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var segmentedControlView: BalanceSegmentedControlView!
    @IBOutlet private weak var pieChartView: PieChartView!

    weak var delegate: GraphCardCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControlView.delegate = self
        setupCardLayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = CGPath(rect: self.bounds, transform: nil)
    }

    func configure(data: [GraphData], segmentIndex: Int) {
        pieChartView.isHidden = false
        pieChartView.setupPieChartView(setData: data)
        segmentedControlView.configureSelectedSegmentIndex(index: segmentIndex)
    }

    func hidePieChartView(segmentIndex: Int) {
        pieChartView.isHidden = true
        segmentedControlView.configureSelectedSegmentIndex(index: segmentIndex)
    }

    private func setupCardLayer() {
        layer.cornerRadius = 8
        layer.shadowColor = R.color.sD1D1D6()?.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 2, height: 2)
    }
}

// MARK: - BalanceSegmentedControlViewDelegate
extension GraphCardCollectionViewCell: BalanceSegmentedControlViewDelegate {
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        delegate?.segmentedControlValueChanged(selectedSegmentIndex: selectedSegmentIndex)
    }
}
