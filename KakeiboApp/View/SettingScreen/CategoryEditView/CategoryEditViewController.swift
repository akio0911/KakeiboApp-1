//
//  CategoryEditViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/04.
//

import UIKit
import RxSwift
import RxCocoa

class CategoryEditViewController: UIViewController, SegmentedControlViewDelegate, UITableViewDelegate {

    @IBOutlet private weak var categoryTableView: UITableView!

    private var segmentedControlView: SegmentedControlView!
    private let viewModel: CategoryEditViewModelType
    private let disposeBag = DisposeBag()
    private let categoryEditTableViewDataSource =
        CategoryEditTableViewDataSource()

    init(viewModel:CategoryEditViewModelType = CategoryEditViewModel()) {
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
            .bind(to:
                    categoryTableView.rx.items(dataSource: categoryEditTableViewDataSource)
            )
            .disposed(by: disposeBag)

        // TODO: 後で削除しなければならない
        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                let categoryInputViewController = CategoryInputViewController()
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

    // MARK: - SegmentedControlViewDelegate
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        viewModel.inputs.didChangeSegmentIndex(index: selectedSegmentIndex)
    }
}
