//
//  BalanceSegmentedControlView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/15.
//

import UIKit

protocol BalanceSegmentedControlViewDelegate: AnyObject {
    func segmentedControlValueChanged(selectedSegmentIndex: Int)
}

final class BalanceSegmentedControlView: UIView {
    weak var delegate: BalanceSegmentedControlViewDelegate?

    private var segmentedControl: UISegmentedControl!
    private var bottomBar: UIView!

    // MARK: - init(frame:)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSegmentedControl()
        setupBottomBar()
    }

    private func setupSegmentedControl() {
        segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: R.string.localizable.expense(), at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: R.string.localizable.income(), at: 1, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        let clearColorImage = UIImage(color: .clear, size: CGSize(width: 1, height: 1))
        segmentedControl.setBackgroundImage(clearColorImage, for: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(clearColorImage,
                                         forLeftSegmentState: .normal,
                                         rightSegmentState: .normal,
                                         barMetrics: .default)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: R.color.s999999()!
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: R.color.sFF9B00()!
        ], for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        addSubview(segmentedControl)
    }

    private func setupBottomBar() {
        bottomBar = UIView()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .orange
        addSubview(bottomBar)
    }

    // MARK: - init?(coder:)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSegmentedControl()
        setupBottomBar()
    }

    // MARK: - layoutSubviews()
    override func layoutSubviews() {
        super.layoutSubviews()
        setupSegmentedControlConstraint()
        setupBottomBarConstraint()
        bottomBar.frame.origin.x =
        (segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments))
        * CGFloat(segmentedControl.selectedSegmentIndex)
    }

    private func setupSegmentedControlConstraint() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: super.topAnchor),
            segmentedControl.widthAnchor.constraint(equalTo: super.widthAnchor),
            segmentedControl.heightAnchor.constraint(equalTo: super.heightAnchor, constant: -3),
            segmentedControl.centerXAnchor.constraint(equalTo: super.centerXAnchor)
        ])
    }

    private func setupBottomBarConstraint() {
        NSLayoutConstraint.activate([
            bottomBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 3),
            bottomBar.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor),
            bottomBar.widthAnchor.constraint(
                equalTo: segmentedControl.widthAnchor,
                multiplier: 1 / CGFloat(segmentedControl.numberOfSegments)
            )
        ])
    }

    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
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
