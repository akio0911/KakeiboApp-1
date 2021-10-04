//
//  CategoryEditViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/04.
//

import UIKit
import RxSwift
import RxCocoa

class CategoryEditViewController: UIViewController, SegmentedControlViewDelegate, UIScrollViewDelegate {

    @IBOutlet private weak var categoryTableView: UITableView!

    private var segmentedControlView: SegmentedControlView!

    private let disposeBag = DisposeBag()

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControlView()
        setupCategoryTableView()
        navigationItem.title  = "カテゴリー編集"
    }

    private func setupSegmentedControlView() {
        segmentedControlView = SegmentedControlView()
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlView.delegate = self
        view.addSubview(segmentedControlView)
    }

    private func setupCategoryTableView() {
        categoryTableView.register(CategoryEditTableViewCell.nib,
                                   forCellReuseIdentifier: CategoryEditTableViewCell.identifier)
        categoryTableView.rx.setDelegate(self).disposed(by: disposeBag)
        categoryTableView.layer.cornerRadius = 10
        categoryTableView.layer.masksToBounds = true
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupSegmentedControlViewConstraint()
    }

    private func setupSegmentedControlViewConstraint() {
        NSLayoutConstraint.activate([
            segmentedControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            segmentedControlView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
            segmentedControlView.topAnchor.constraint(
                equalTo: navigationController?.navigationBar.bottomAnchor ?? view.bottomAnchor, constant: 20),
            segmentedControlView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - UITableViewDelegate

    // MARK: - SegmentedControlViewDelegate
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
    }
}
