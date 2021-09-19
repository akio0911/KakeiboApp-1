//
//  CategoryViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/18.
//

import UIKit
import RxSwift
import RxCocoa

class CategoryViewController: UIViewController, UITableViewDelegate {

    @IBOutlet private weak var categoryTableView: UITableView!

    private let viewModel: CategoryViewModelType
    private let disposeBag = DisposeBag()
    private let categoryTableViewDataSource = CategoryTableViewDataSource()
    private var headerDataArray: [HeaderDateCategoryData] = []

    init(viewModel: CategoryViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func setupBinding() {
        viewModel.outputs.cellDateDataObservable
            .bind(to: categoryTableView.rx.items(dataSource: categoryTableViewDataSource))
            .disposed(by: disposeBag)

        viewModel.outputs.headerDateDataObservable
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.headerDataArray = data
            })
            .disposed(by: disposeBag)

        viewModel.outputs.navigationTitle
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        categoryTableView.register(
            CalendarTableViewCell.nib,
            forCellReuseIdentifier: CalendarTableViewCell.identifier
        )
        categoryTableView.register(
            CalendarTableViewHeaderFooterView.nib,
            forHeaderFooterViewReuseIdentifier: CalendarTableViewHeaderFooterView.identifier
        )
        categoryTableView.sectionHeaderHeight = 17
        categoryTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }

    // MARK: - UITableViewDelegate
    // ヘッダーのタイトルを設定
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: CategoryTableViewHeaderView.identifier)
                as? CategoryTableViewHeaderView else { return nil }
        headerView.configure(data: headerDataArray[section])
        return headerView
    }
}
