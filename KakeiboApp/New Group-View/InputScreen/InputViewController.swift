//
//  InputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit
import RxSwift
import RxCocoa

final class InputViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

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

//    // 今日の日付を返す
//    private func getToday() -> Date {
//        let calendar = Calendar(identifier: .gregorian)
//        let component = calendar.dateComponents([.year, .month, .day], from: Date())
//        let today = calendar.date(
//            from: DateComponents(
//                year: component.year,
//                month: component.month,
//                day: component.day)
//        )
//        return today!
//    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupBarButtonItem()

        settingTextFieldDelegate() // textField.delegateを設定
        settingPickerKeybord() // pickerViewをキーボードに設定
        configureSaveBtnLayer() // セーブボタンをフィレット
        insertGradationLayer() // グラデーション設定
        settingHeightPicker() // pickerViewの高さ設定
        configureMosaicViewLayer() // モザイク用のviewをフィレット
//        settingKeyboardNotification() // Keyboardのnotification設定
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

    // textFieldDelegateの設定
    private func settingTextFieldDelegate() {
        dateTextField.delegate = self
        categoryTextField.delegate = self
        balanceTextField.delegate = self
        memoTextField.delegate = self
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

//    // Keyboardのnotificationの設定
//    private func settingKeyboardNotification() {
//        let notification = NotificationCenter.default
//        notification.addObserver(self,
//                                 selector: #selector(self.keyboardChangeFrame(_:)),
//                                 name: UIResponder.keyboardDidChangeFrameNotification,
//                                 object: nil)
//
//        notification.addObserver(self,
//                                 selector: #selector(self.keyboardWillShow(_:)),
//                                 name: UIResponder.keyboardWillShowNotification,
//                                 object: nil)
//
//        notification.addObserver(self,
//                                 selector: #selector(self.keyboardDidHide(_:)),
//                                 name: UIResponder.keyboardDidHideNotification,
//                                 object: nil)
//    }

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

//    // MARK: - viewDidLayoutSubviews
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        let contentSize = CGSize(width: view.frame.width
//                                    - view.safeAreaInsets.left
//                                    - view.safeAreaInsets.right,
//                                 height: view.frame.height
//                                    - view.safeAreaInsets.top
//                                    - view.safeAreaInsets.bottom)
//        baseScrollView.contentSize = contentSize // スクロールできなくするための設定
//    }

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

    private func didTapSaveButton() {
        guard let balanceText = balanceTextField.text else { return showBalanceAlert() }
        let dateText = dateTextField.text!
        let categoryText = categoryTextField.text!
        let segmentIndex = balanceSegmentControl.selectedSegmentIndex
        let memo = memoTextField.text!
        viewModel.inputs.didTapSaveButton(
            dateText: dateText, categoryText: categoryText,
            balanceText: balanceText, segmentIndex: segmentIndex, memo: memo
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

    // MARK: - TextFieldDelegate
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        editingField = textField
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        editingField = nil
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        view.endEditing(true)
//        return false
//    }

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

    // MARK: - notificationのSelector
//    @objc func keyboardChangeFrame(_ notification: Notification) {
//
//        var overlap: CGFloat = 0 // 重なっている高さ
//        guard let fld = editingField else { return }
//        // キーボードのframeを調べる
//        let userInfo = (notification as NSNotification).userInfo!
//        // swiftlint:disable:next force_cast
//        let keybordFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        // textFieldのframeをキーボードと同じ座標系にする
//        let fldFrame = view.convert(fld.frame, from: contentView)
//        // 編集中のtextFieldがキーボードと重なっていないか調べる
//        overlap = fldFrame.maxY - keybordFrame.minY + 18
//        if overlap > 0 {
//            // キーボードで隠れている分だけスクロールする
//            overlap += baseScrollView.contentOffset.y
//            baseScrollView.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
//        }
//    }
//
//    private var lastOffsetY: CGFloat = 0 // キーボードが表示される前のスクロール量(現時点不要)
//    // (現時点不要)
//    @objc func keyboardWillShow(_ notification: Notification) {
//        lastOffsetY = baseScrollView.contentOffset.y
//    }
//
//    @objc func keyboardDidHide(_ notification: Notification) {
//        let baseline: CGFloat = 0
//        lastOffsetY = min(baseline, lastOffsetY) // (現時点不要)
//        baseScrollView.setContentOffset(CGPoint(x: 0, y: lastOffsetY), animated: true)
//    }

    // MARK: - detePickerのSelector
    @objc func datePickerValueChange() {
//        let calendar = Calendar(identifier: .gregorian)
//        let dateComponent = calendar.dateComponents([.year, .month, .day], from: datePicker.date)
//        didSelectDate = calendar.date(
//            from: DateComponents(
//                year: dateComponent.year,
//                month: dateComponent.month,
//                day:dateComponent.day)
//        )!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY年MM月dd日"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }
}
