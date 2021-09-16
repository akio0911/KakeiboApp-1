//
//  InputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit
import RxSwift
import RxCocoa

final class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, SegmentedControlViewDelegate {

    private let stringExpenseCategoryArray = Category.Expense.allCases.map { $0.rawValue }
    private let stringIncomeCategoryArray = Category.Income.allCases.map { $0.rawValue }

    @IBOutlet private weak var baseScrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
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
        categoryTextField.text = "飲食費"
        setupBinding()
        setupMode()
        setupBarButtonItem()
        configureSaveBtnLayer() // セーブボタンをフィレット
        insertGradationLayer() // グラデーション設定
        settingHeightPicker() // pickerViewの高さ設定
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

    // セーブボタンをフィレット
    private func configureSaveBtnLayer() {
        saveButton.layer.cornerRadius = 10
        saveButton.layer.masksToBounds = true
    }

    // グラデーションを設定
    private func insertGradationLayer() {
        let gradation = Gradation()
        gradation.layer.frame = contentView.bounds
        contentView.layer.insertSublayer(gradation.layer, at: 0)
    }

    // pickerViewの高さ設定
    private func settingHeightPicker() {
        NSLayoutConstraint.activate([
            datePicker.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            expenseCategoryPickerView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            incomeCategoryPickerView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3)
        ])
    }

    // モザイク用のveiwをフィレット
    private func configureMosaicViewLayer() {
        mosaicView.forEach {
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
        }
    }

    // キーボードの設定
    private func settingPickerKeybord() {
        // datePickerViewを設定
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date // 日付を月、日、年で表示
        datePicker.preferredDatePickerStyle = .wheels // ホイールピッカーとして表示
        datePicker.timeZone = .autoupdatingCurrent // システムが現在使用しているタイムゾーン
        datePicker.locale = .autoupdatingCurrent  // ユーザーの現在の設定を追跡するロケール
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
        segmentedControlView = SegmentedControlView(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0)
        )
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlView.delegate = self
        view.addSubview(segmentedControlView)
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let scrollView: UIScrollView = view.subviews.first(where: { $0 is UIScrollView }) as! UIScrollView
        let contentView: UIView = scrollView.subviews
            .filter { $0.restorationIdentifier == "ContentView"}.first!
        let dateView: UIView = contentView.subviews
            .filter { $0.restorationIdentifier == "DateView"}.first!
        NSLayoutConstraint.activate([
            segmentedControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControlView.rightAnchor.constraint(equalTo: view.rightAnchor),
            segmentedControlView.topAnchor.constraint(equalTo: dateView.bottomAnchor),
            segmentedControlView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // MARK: - @IBAction
    //    @IBAction private func tappedView(_ sender: Any) {
    //        view.endEditing(true)
    //    }

    @objc private func didTapCancelBarButton() {
        viewModel.inputs.didTapCancelButton()
    }

    @objc private func didTapSaveBarButton() {
        didTapSaveButton()
    }

    // TODO: save機能を要実装
    private func didTapSaveButton() {
        guard categoryTextField.text != "" else { return }
        guard balanceTextField.text != "" else { return }
        let date = DateUtility.dateFromString(stringDate: dateTextField.text!, format: "YYYY年MM月dd日")
        var balance: Balance
        var category: Category
        switch selectedSegmentIndex {
        case 0:
            balance = Balance.expense(Int(balanceTextField.text!) ?? 0)
            category = Category.expense(Category.Expense(rawValue: categoryTextField.text!)!)
        case 1:
            balance = Balance.income(Int(balanceTextField.text!) ?? 0)
            category = Category.income(Category.Income(rawValue: categoryTextField.text!)!)
        default:
            fatalError("想定していないsegmentIndex")
        }
        viewModel.inputs.didTapSaveButton(
            data: KakeiboData(date: date, category: category, balance: balance, memo: memoTextField.text!)
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

    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case incomeCategoryPickerView:
            return stringIncomeCategoryArray.count
        case expenseCategoryPickerView:
            return stringExpenseCategoryArray.count
        default:
            fatalError("想定していないpickerView")
        }
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case incomeCategoryPickerView:
            categoryTextField.text = stringIncomeCategoryArray[row]
        case expenseCategoryPickerView:
            categoryTextField.text = stringExpenseCategoryArray[row]
        default:
            fatalError("想定していないpickerView")
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case incomeCategoryPickerView:
            return stringIncomeCategoryArray[row]
        case expenseCategoryPickerView:
            return stringExpenseCategoryArray[row]
        default:
            fatalError("想定していないpickerView")
        }
    }

    // MARK: - detePickerのSelector
    @objc func datePickerValueChange(_ sender: UIDatePicker) {
        viewModel.inputs.addDate(date: sender.date)
    }

    // MARK: - SegmentedControlViewDelegate
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        self.selectedSegmentIndex = selectedSegmentIndex
        if selectedSegmentIndex == 0 {
            balanceLabel.text = Balance.expenseName
            categoryTextField.inputView = expenseCategoryPickerView
            categoryTextField.text = "飲食費"
            categoryTextField.endEditing(true)
        } else if selectedSegmentIndex == 1 {
            balanceLabel.text = Balance.incomeName
            categoryTextField.inputView = incomeCategoryPickerView
            categoryTextField.text = "給料"
            categoryTextField.endEditing(true)
        }
    }
}

extension Balance {
    static let incomeName = "収入"
    static let expenseName = "支出"
}
