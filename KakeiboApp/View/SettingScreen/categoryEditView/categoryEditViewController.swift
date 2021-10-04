//
//  categoryEditViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/04.
//

import UIKit

class categoryEditViewController: UIViewController, SegmentedControlViewDelegate {

    private var segmentedControlView: SegmentedControlView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func setupSegmentedControlView() {
        segmentedControlView = SegmentedControlView()
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlView.delegate = self
        view.addSubview(segmentedControlView)
        NSLayoutConstraint.activate([
            segmentedControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            segmentedControlView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
            segmentedControlView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            segmentedControlView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - SegmentedControlViewDelegate
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
    }
}
