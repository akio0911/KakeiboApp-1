//
//  InputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit
import RxSwift
import RxCocoa

final class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, SegmentedControlViewDelegate {

    @IBOutlet private weak var baseScrollView: UIScrollView!
    @IBOutlet private weak var dateView: UIView!
    @IBOutlet private var mosaicView: [UIView]!
    @IBOutlet private weak var nextDayButton: UIButton!
    @IBOutlet private weak var lastDayButton: UIButton!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var dateTextField: UITextField!
    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private weak var balanceTextField: UITextField!
    @IBOutlet private weak var memoTextField: UITextField!
    @IBOutlet private weak var saveButton: UIButton!

    private var datePicker: UIDatePicker!
    private var expenseCategoryPickerView: UIPickerView!
    private var incomeCategoryPickerView: UIPickerView!
    private var segmentedControlView: SegmentedControlView!
    private let viewModel: InputViewModelType
    private let disposeBag = DisposeBag()
    private var selectedSegmentIndex: Int = 0
    private var editingTextField: UITextField?
    private var keyboardOverlap: CGFloat = 0
    private var incomeCategoryArray: [CategoryData] = []
    private var expenseCategoryArray: [CategoryData] = []

    init(viewModel: InputViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControlView() // segmentedControlViewを設定
        settingPickerKeybord() // pickerViewをキーボードに設定
        setupBinding()
        setupMode()
        setupBarButtonItem()
        setupTapGesture()
        setupScrollToShowKeyboard()
        configureSaveBtnLayer() // セーブボタンをフィレット
        configureMosaicViewLayer() // モザイク用のviewをフィレット
        navigationItem.title = "収支入力"
    }

    private func setupBinding() {
        nextDayButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapNextDayButton)
            .disposed(by: disposeBag)

        lastDayButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapLastDayButton)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(onNext: didTapSaveButton)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .dismiss:
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.date
            .drive(dateTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.category
            .drive(categoryTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.segmentIndex
            .drive(onNext: { [weak self] index in
                guard let self = self else { return }
                self.segmentedControlView.configureSelectedSegmentIndex(index: index)
                if index == 1 {
                    self.selectedSegmentIndex = index
                    self.balanceLabel.text = Balance.incomeName
                    self.categoryTextField.inputView = self.incomeCategoryPickerView
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.balance
            .drive(balanceTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.memo
            .drive(memoTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.incomeCategory
            .drive(onNext: { [weak self] incomeCategory in
                guard let strongSelf = self else { return }
                strongSelf.incomeCategoryArray = incomeCategory
            })
            .disposed(by: disposeBag)

        viewModel.outputs.expenseCategory
            .drive(onNext: { [weak self] expenseCategory in
                guard let strongSelf = self else { return }
                strongSelf.expenseCategoryArray = expenseCategory
            })
            .disposed(by: disposeBag)
    }

    private func setupMode() {
        switch viewModel.outputs.mode {
        case .add(let date):
            viewModel.inputs.addDate(date: date)
        case .edit(let kakeiboData):
            viewModel.inputs.editData(data: kakeiboData)
        }
    }

    private func setupBarButtonItem() {
        let saveBarButton = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(didTapSaveBarButton)
        )
        navigationItem.rightBarButtonItem = saveBarButton

        let cancelBarButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancelBarButton)
        )
        navigationItem.leftBarButtonItem = cancelBarButton
    }

    // キーボードの設定
    private func settingPickerKeybord() {
        // datePickerViewを設定
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date // 日付を月、日、年で表示
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels // ホイールピッカーとして表示
        }
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.addTarget(self,
                             action: #selector(datePickerValueChange(_:)),
                             for: .valueChanged)
        dateTextField.inputView = datePicker

        // ExpenseCategoryPickerViewを設定
        expenseCategoryPickerView = UIPickerView()
        expenseCategoryPickerView.delegate = self
        expenseCategoryPickerView.dataSource = self
        categoryTextField.inputView = expenseCategoryPickerView

        // IncomeCategoryPickerViewを設定
        incomeCategoryPickerView = UIPickerView()
        incomeCategoryPickerView.delegate = self
        incomeCategoryPickerView.dataSource = self
    }

    private func setupSegmentedControlView() {
        segmentedControlView = SegmentedControlView()
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlView.delegate = self
        view.addSubview(segmentedControlView)
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    // キーボードが隠れないようにスクロールする設定
    private func setupScrollToShowKeyboard() {
        let textFields = [
            dateTextField,
            categoryTextField,
            balanceTextField,
            memoTextField
        ]
        textFields.forEach {
            $0?.delegate = self
        }
        let notification = NotificationCenter.default
        notification.addObserver(self,
                                 selector: #selector(keyboardDidShow(_:)),
                                 name: UIResponder.keyboardDidShowNotification, object: nil)
        notification.addObserver(self,
                                 selector: #selector(keyboardWillHide(_:)),
                                 name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func didTapSaveButton() {
        guard balanceTextField.text != "" else {
            showBalanceAlert()
            return
        }
        let date = DateUtility.dateFromString(stringDate: dateTextField.text!, format: "YYYY年MM月dd日")
        var balance: Balance
        var categoryId: CategoryId
        switch selectedSegmentIndex {
        case 0:
            balance = Balance.expense(Int(balanceTextField.text!) ?? 0)
            categoryId = CategoryId.expense(
                expenseCategoryArray.first(where: { $0.name == categoryTextField.text! })!.id
            )
        case 1:
            balance = Balance.income(Int(balanceTextField.text!) ?? 0)
            categoryId = CategoryId.income(
                incomeCategoryArray.first(where: { $0.name == categoryTextField.text! })!.id
            )
        default:
            fatalError("想定していないsegmentIndex")
        }
        viewModel.inputs.didTapSaveButton(
            data: KakeiboData(date: date, categoryId: categoryId, balance: balance, memo: memoTextField.text!)
        )
    }

    // アラートを表示し、ボタンが押されたらexpensesTextFieldを起動する
    private func showBalanceAlert() {
        let alert = UIAlertController(
            title: "収支が未入力です。",
            message: "支出または収入を入力して下さい",
            preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                handler: { [weak self] _ in
                    self?.balanceTextField.becomeFirstResponder() }
            )
        )
        present(alert, animated: true, completion: nil)
    }

    // セーブボタンをフィレット
    private func configureSaveBtnLayer() {
        saveButton.layer.cornerRadius = 10
        saveButton.layer.masksToBounds = true
    }

    // モザイク用のveiwをフィレット
    private func configureMosaicViewLayer() {
        mosaicView.forEach {
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
        }
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            datePicker.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            expenseCategoryPickerView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            incomeCategoryPickerView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            segmentedControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            segmentedControlView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
            segmentedControlView.topAnchor.constraint(equalTo: dateView.bottomAnchor),
            segmentedControlView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - @objc
    @objc private func didTapCancelBarButton() {
        viewModel.inputs.didTapCancelButton()
    }

    @objc private func didTapSaveBarButton() {
        didTapSaveButton()
    }

    @objc func datePickerValueChange(_ sender: UIDatePicker) {
        viewModel.inputs.addDate(date: sender.date)
    }

    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc func keyboardDidShow(_ notification: Notification) {
        guard let editingTextField = editingTextField else { return }
        let userInfo = (notification as Notification).userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardFrameMinY = view.frame.size.height - keyboardFrame.height
        let textFieldFrame = view.convert(editingTextField.frame, from: editingTextField.superview)
        keyboardOverlap = textFieldFrame.maxY - keyboardFrameMinY + 8
        if keyboardOverlap > 0 {
            keyboardOverlap += baseScrollView.contentOffset.y
            baseScrollView.setContentOffset(CGPoint(x: 0, y: keyboardOverlap), animated: true)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        baseScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case incomeCategoryPickerView:
            return incomeCategoryArray.count
        case expenseCategoryPickerView:
            return expenseCategoryArray.count
        default:
            fatalError("想定していないpickerView")
        }
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case incomeCategoryPickerView:
            categoryTextField.text = incomeCategoryArray[row].name
        case expenseCategoryPickerView:
            categoryTextField.text = expenseCategoryArray[row].name
        default:
            fatalError("想定していないpickerView")
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case incomeCategoryPickerView:
            return incomeCategoryArray[row].name
        case expenseCategoryPickerView:
            return expenseCategoryArray[row].name
        default:
            fatalError("想定していないpickerView")
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        editingTextField = nil
    }

    // MARK: - SegmentedControlViewDelegate
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        self.selectedSegmentIndex = selectedSegmentIndex
        if selectedSegmentIndex == 0 {
            balanceLabel.text = Balance.expenseName
            categoryTextField.inputView = expenseCategoryPickerView
            categoryTextField.text = expenseCategoryArray.first?.name ?? ""
            categoryTextField.endEditing(true)
        } else if selectedSegmentIndex == 1 {
            balanceLabel.text = Balance.incomeName
            categoryTextField.inputView = incomeCategoryPickerView
            categoryTextField.text = incomeCategoryArray.first?.name ?? ""
            categoryTextField.endEditing(true)
        }
    }
}

// MARK: - extension Balance
extension Balance {
    static let incomeName = "収入"
    static let expenseName = "支出"
}
