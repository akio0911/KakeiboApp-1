//
//  CategoryEditViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/04.
//

import UIKit
import RxSwift
import RxCocoa

class CategoryEditViewController: UIViewController,
                                  BalanceSegmentedControlViewDelegate,
                                  UITableViewDelegate,
                                  CategoryEditTableViewDataSourceDelegate {
    @IBOutlet private weak var categoryTableView: UITableView!

    private var segmentedControlView: BalanceSegmentedControlView!
    private let viewModel: CategoryEditViewModelType
    private let disposeBag = DisposeBag()
    private let categoryEditTableViewDataSource =
    CategoryEditTableViewDataSource()

    init(viewModel: CategoryEditViewModelType = CategoryEditViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControlView()
        setupCategoryTableView()
        setupBarButtonItem()
        setupBinding()
        categoryEditTableViewDataSource.delegate = self
        navigationItem.title  = "カテゴリー編集"
    }

    private func setupSegmentedControlView() {
        segmentedControlView = BalanceSegmentedControlView()
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

    private func setupBarButtonItem() {
        let addBarButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddBarButton)
        )
        navigationItem.rightBarButtonItem = addBarButton
    }

    private func setupBinding() {
        viewModel.outputs.categoryData
            .bind(
                to: categoryTableView.rx.items(dataSource: categoryEditTableViewDataSource)
            )
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                let categoryInputViewController = CategoryInputViewController(
                    viewModel: CategoryInputViewModel(
                        mode: CategoryInputViewModel.Mode(event: event),
                        categoryBalance: CategoryInputViewModel.CategoryBalance(event: event)
                    )
                )
                let navigationController = UINavigationController(rootViewController: categoryInputViewController)
                self.present(navigationController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
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

    // MARK: - @objc
    @objc private func didTapAddBarButton() {
        viewModel.inputs.didTapAddBarButton()
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.didSelectRowAt(index: indexPath)
    }

    // MARK: - BalanceSegmentedControlViewDelegate
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        viewModel.inputs.didChangeSegmentIndex(index: selectedSegmentIndex)
    }

    // MARK: - CategoryEditTableViewDataSourceDelegate
    // 自作delegate
    func didDeleteCell(index: IndexPath) {
        viewModel.inputs.didDeleateCell(index: index)
    }
}

// MARK: - extension CategoryInputViewModel.Mode
extension CategoryInputViewModel.Mode {
    init(event: CategoryEditViewModel.Event) {
        switch event {
        case .presentIncomeCategoryAdd, .presentExpenseCategoryAdd:
            self = .add
        case .presentIncomeCategoryEdit(let data), .presentExpenseCategoryEdit(let data):
            self = .edit(data)
        }
    }
}

// MARK: - extension CategoryInputViewModel.CategoryBalance
extension CategoryInputViewModel.CategoryBalance {
    init(event: CategoryEditViewModel.Event) {
        switch event {
        case .presentIncomeCategoryAdd, .presentIncomeCategoryEdit(_):
            self = .income
        case .presentExpenseCategoryAdd, .presentExpenseCategoryEdit(_):
            self = .expense
        }
    }
}
