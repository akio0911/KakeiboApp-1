//
//  CategoryEditViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/04.
//

import UIKit

class CategoryEditViewController: UIViewController, SegmentedControlViewDelegate {

    private var segmentedControlView: SegmentedControlView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControlView()
    }

    private func setupSegmentedControlView() {
        segmentedControlView = SegmentedControlView()
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlView.delegate = self
        view.addSubview(segmentedControlView)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            segmentedControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            segmentedControlView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
            segmentedControlView.topAnchor.constraint(
                equalTo: navigationController?.navigationBar.bottomAnchor ?? view.bottomAnchor, constant: 20),
            segmentedControlView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - SegmentedControlViewDelegate
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
    }
}
