//
//  InputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit
import RxSwift
import RxCocoa

// TODO: deleteBarButtonの表示・非表示の実装
final class InputViewController: UIViewController {
    @IBOutlet private weak var saveBarButton: UIBarButtonItem!
    @IBOutlet private weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet private weak var dateTextField: DateTextField!
    @IBOutlet private weak var segmentedControlView: BalanceSegmentedControlView!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var balanceTextField: CurrencyTextField!
    @IBOutlet private weak var categoryCollectionView: UICollectionView!
    @IBOutlet private weak var memoTextView: BorderTextView!
    @IBOutlet private weak var saveButton: UIButton!

    private let viewModel: InputViewModelType = InputViewModel(mode: .add(Date()))
    private let disposeBag = DisposeBag()
    private var categoryDataArray: [CategoryData] = []
    private var selectedIndex: Int = 0

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControlView.delegate = self
        setupCategoryCollectionView()
        setupBinding()
        viewModel.inputs.onViewDidLoad()
    }

    // swiftlint:disable:next function_body_length
    private func setupBinding() {
        saveBarButton.rx.tap
            .subscribe(onNext: didTapSaveButton)
            .disposed(by: disposeBag)

        deleteBarButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapDeleteButton)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(onNext: didTapSaveButton)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case .dismiss:
                    strongSelf.dismiss(animated: true, completion: nil)
                case .showDismissAlert(let alertTitle, let message):
                    strongSelf.showAlert(title: alertTitle, messege: message) { [weak self] in
                        self?.dismiss(animated: true)
                    }
                case .showErrorAlert:
                    strongSelf.showErrorAlert()
                case .showAlert(let alertTitle, let message):
                    strongSelf.showAlert(title: alertTitle, messege: message)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.category
            .drive { [weak self] (categoryDataArray, selectedIndex) in
                self?.categoryDataArray = categoryDataArray
                self?.selectedIndex = selectedIndex
                self?.categoryCollectionView.reloadData()
            }
            .disposed(by: disposeBag)

        viewModel.outputs.date
            .drive(dateTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.segmentIndex
            .drive(onNext: segmentedControlView.configureSelectedSegmentIndex(index:))
            .disposed(by: disposeBag)

        viewModel.outputs.balance
            .drive(balanceTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.memo
            .drive(memoTextView.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.isAnimatedIndicator
            .drive { [weak self] isAnimated in
                isAnimated ? self?.showProgress() : self?.hideProgress()
            }
            .disposed(by: disposeBag)

        let viewTapGesture = UITapGestureRecognizer()
        viewTapGesture.cancelsTouchesInView = false
        viewTapGesture.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        view.addGestureRecognizer(viewTapGesture)
    }

    private func setupCategoryCollectionView() {
        categoryCollectionView.register(
            CategoryCollectionViewCell.nib,
            forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier
        )
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
    }

    private func didTapSaveButton() {
        viewModel.inputs.didTapSaveButton(
            dateText: dateTextField.text!,
            balanceText: balanceTextField.text!,
            categoryData: categoryDataArray[selectedIndex],
            memo: memoTextView.text!
        )
    }
}

// MARK: - UICollectionViewDataSource
extension InputViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryDataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.identifier,
            for: indexPath
        ) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(categoryData: categoryDataArray[indexPath.row])
        return cell
    }
}

extension InputViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: 75)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - BalanceSegmentedControlViewDelegate
extension InputViewController: BalanceSegmentedControlViewDelegate {
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        viewModel.inputs.didChangeSegmentControl(index: selectedSegmentIndex)
        if selectedSegmentIndex == 0 {
            balanceLabel.text = Balance.expenseName
        } else if selectedSegmentIndex == 1 {
            balanceLabel.text = Balance.incomeName
        }
    }
}

// MARK: - extension Balance
extension Balance {
    static let incomeName = R.string.localizable.income()
    static let expenseName = R.string.localizable.expense()
}
