//
//  InputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit
import RxSwift
import RxCocoa

final class InputViewController: UIViewController {
    @IBOutlet private weak var saveBarButton: UIBarButtonItem!
    @IBOutlet private weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet private weak var dateTextField: DateTextField!
    @IBOutlet private weak var segmentedControlView: BalanceSegmentedControlView!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var balanceTextField: CurrencyTextField!
    @IBOutlet private weak var balanceCategoryCollectionView: UICollectionView!
    @IBOutlet private weak var memoTextView: BorderTextView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var buttomToolbar: UIToolbar!

    private let viewModel: InputViewModelType = InputViewModel()
    private let disposeBag = DisposeBag()
    private var balanceCategoryDataArray: [[CategoryData]] = []
    private var selectedIndexPath: IndexPath = [0, 0]
    private var mode: InputViewModel.Mode = .add(Date())
    private var isHiddenButtomToolbar: Bool = true

    func inject(mode: InputViewModel.Mode, isHiddenButtomToolbar: Bool = true) {
        self.mode = mode
        self.isHiddenButtomToolbar = isHiddenButtomToolbar
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        buttomToolbar.isHidden = isHiddenButtomToolbar
        segmentedControlView.delegate = self
        setupCategoryCollectionView()
        setupBinding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.setMode(mode: mode)
        switch mode {
        case .add(let date):
            dateTextField.setupDatePicker(date: date)
        case .edit(let kakeiboData, _):
            dateTextField.setupDatePicker(date: kakeiboData.date)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mode = .add(Date())
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
            .drive { [weak self] (balanceCategoryDataArray, selectedIndexPath) in
                self?.balanceCategoryDataArray = balanceCategoryDataArray
                self?.selectedIndexPath = selectedIndexPath
                self?.balanceCategoryCollectionView.reloadData()
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

        viewModel.outputs.isHiddenDeleteButton
            .drive { [weak self] isHidden in
                if isHidden {
                    self?.deleteBarButton.isEnabled = false
                    self?.deleteBarButton.tintColor = .clear
                } else {
                    self?.deleteBarButton.isEnabled = true
                    self?.deleteBarButton.tintColor = R.color.sFF9B00()
                }
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
        balanceCategoryCollectionView.register(
            BalanceCategoryCollectionViewCell.nib,
            forCellWithReuseIdentifier: BalanceCategoryCollectionViewCell.identifier
        )
        balanceCategoryCollectionView.delegate = self
        balanceCategoryCollectionView.dataSource = self
    }

    private func didTapSaveButton() {
        viewModel.inputs.didTapSaveButton(
            dateText: dateTextField.text!,
            segmentIndex: segmentedControlView.segmentedSegmentIndex,
            balanceText: balanceTextField.text!,
            categoryData: balanceCategoryDataArray[selectedIndexPath.section][selectedIndexPath.row],
            memo: memoTextView.text!
        )
    }
}

// MARK: - UICollectionViewDataSource
extension InputViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        balanceCategoryDataArray.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BalanceCategoryCollectionViewCell.identifier,
            for: indexPath
        ) as? BalanceCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let selectedIndex: Int
        if indexPath.row == selectedIndexPath.section {
            selectedIndex = selectedIndexPath.row
        } else {
            selectedIndex = 0
        }
        cell.configure(categoryDataArray: balanceCategoryDataArray[indexPath.row], selectedIndex: selectedIndex)
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension InputViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 215)
    }
}

extension InputViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let balanceCategoryCell = cell as? BalanceCategoryCollectionViewCell else {
            return
        }
        if selectedIndexPath.section == indexPath.row {
            balanceCategoryCell.selectedIndex = selectedIndexPath.row
        } else {
            balanceCategoryCell.selectedIndex = 0
        }
    }
}

// MARK: - UIScrollViewDelegate
extension InputViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexPath = balanceCategoryCollectionView.indexPathsForVisibleItems
        segmentedControlView.configureSelectedSegmentIndex(index: indexPath.first?.row ?? 0)
    }
}

// MARK: - BalanceSegmentedControlViewDelegate
extension InputViewController: BalanceSegmentedControlViewDelegate {
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        balanceCategoryCollectionView.scrollToItem(
            at: [0, selectedSegmentIndex],
            at: .centeredHorizontally,
            animated: true
        )
        // 収入・支出を切り替えた時に、カテゴリー選択を一番最初のcellにする
        if selectedIndexPath.section != selectedSegmentIndex {
            selectedIndexPath.row = 0
        }
        selectedIndexPath.section = selectedSegmentIndex
        if selectedSegmentIndex == 0 {
            balanceLabel.text = Balance.expenseName
        } else if selectedSegmentIndex == 1 {
            balanceLabel.text = Balance.incomeName
        }
    }
}

// MARK: - BalanceCategoryCollectionViewCellDelegate
extension InputViewController: BalanceCategoryCollectionViewCellDelegate {
    func didSelectItemAt(indexPath: IndexPath) {
        selectedIndexPath.row = indexPath.row
    }
}

// MARK: - extension Balance
extension Balance {
    static let incomeName = R.string.localizable.income()
    static let expenseName = R.string.localizable.expense()
}
