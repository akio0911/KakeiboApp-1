//
//  InputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit
import RxSwift
import RxCocoa

final class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private let stringCategoryArray = Category.allCases.map { $0.rawValue }

    @IBOutlet private weak var baseScrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private var mosaicView: [UIView]!
    @IBOutlet private weak var dateTextField: UITextField!
    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private weak var balanceTextField: UITextField!
    @IBOutlet private weak var memoTextField: UITextField!
    @IBOutlet private weak var balanceSegmentControl: UISegmentedControl!
    @IBOutlet private weak var saveButton: UIButton!

    private var datePicker: UIDatePicker!
    private var categoryPickerView: UIPickerView!
    private let viewModel: InputViewModelType
    private let disposeBag = DisposeBag()

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
        setupBinding()
        setupMode()
        setupBarButtonItem()
        settingPickerKeybord() // pickerViewをキーボードに設定
        configureSaveBtnLayer() // セーブボタンをフィレット
        insertGradationLayer() // グラデーション設定
        settingHeightPicker() // pickerViewの高さ設定
        configureMosaicViewLayer() // モザイク用のviewをフィレット
    }

    private func setupBinding() {
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
            .drive(balanceSegmentControl.rx.selectedSegmentIndex)
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
        case .add:
            break
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
            categoryPickerView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3)
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
                             action: #selector(datePickerValueChange),
                             for: .valueChanged)
        dateTextField.inputView = datePicker

        // categoryPickerViewを設定
        categoryPickerView = UIPickerView()
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        categoryTextField.inputView = categoryPickerView
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
        guard dateTextField.text != "" else { return }
        guard categoryTextField.text != "" else { return }
        guard balanceTextField.text != "" else { return }
        guard memoTextField.text != "" else { return }
        let date = DateUtility.dateFromString(stringDate: dateTextField.text!, format: "YYYY年MM月dd日")
        let category = Category(rawValue: categoryTextField.text!)!
        var balance: Balance
        switch balanceSegmentControl.selectedSegmentIndex {
        case 0:
            balance = Balance.expense(Int(balanceTextField.text!) ?? 0)
        case 1:
            balance = Balance.income(Int(balanceTextField.text!) ?? 0)
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
        stringCategoryArray.count
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let stringCategory = stringCategoryArray[row]
        categoryTextField.text = stringCategory
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        stringCategoryArray[row]
    }

    // MARK: - detePickerのSelector
    @objc func datePickerValueChange() {
        dateTextField.text = DateUtility.stringFromDate(
            date: datePicker.date, format: "YYYY年MM月dd日"
        )
    }
}
