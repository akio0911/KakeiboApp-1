//
//  SegmentedControlView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/15.
//

import UIKit

protocol SegmentedControlViewDelegate: AnyObject {
    func segmentedControlValueChanged(selectedSegmentIndex: Int)
}

final class SegmentedControlView: UIView {

    weak var delegate: SegmentedControlViewDelegate?

    private var segmentedControl: UISegmentedControl!
    private var bottomBar: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "支出", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "収入", at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        let clearColorImage = UIImage(color: .clear, size: CGSize(width: 1, height: 1))
        segmentedControl.setBackgroundImage(clearColorImage, for: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(clearColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor.orange
        ], for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        addSubview(segmentedControl)
        bottomBar = UIView()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .orange
        addSubview(bottomBar)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: super.topAnchor),
            segmentedControl.widthAnchor.constraint(equalTo: super.widthAnchor),
            segmentedControl.heightAnchor.constraint(equalTo: super.heightAnchor, constant: -3),
            bottomBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 3),
            bottomBar.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            bottomBar.widthAnchor.constraint(
                equalTo: segmentedControl.widthAnchor,
                multiplier: 1 / CGFloat(segmentedControl.numberOfSegments)
            )
        ])
        bottomBar.frame.origin.x = (segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)) * CGFloat(segmentedControl.selectedSegmentIndex)
    }

    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.05) { [weak self] in
            guard let self = self else { return }
            self.bottomBar.frame.origin.x =
            (sender.frame.width / CGFloat(sender.numberOfSegments)) * CGFloat(sender.selectedSegmentIndex)
        }
        delegate?.segmentedControlValueChanged(selectedSegmentIndex: sender.selectedSegmentIndex)
    }

    func configureSelectedSegmentIndex(index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }
}
