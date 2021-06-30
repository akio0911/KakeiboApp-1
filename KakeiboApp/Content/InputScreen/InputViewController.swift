//
//  InputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit

class InputViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    private var dataRepository = DataRepository()
    private let category = Category.allCases.map { $0.name }

    private var editingField: UITextField?

    @IBOutlet private weak var baseScrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private var mosaicView: [UIView]!
    @IBOutlet private weak var dateTextField: UITextField!
    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private weak var expensesTextField: UITextField!
    @IBOutlet private weak var memoTextField: UITextField!
    @IBOutlet private weak var expensesSegmentControl: UISegmentedControl!
    @IBOutlet private weak var saveBtn: UIButton!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var categoryPickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        dateTextField.delegate = self
        categoryTextField.delegate = self
        expensesTextField.delegate = self
        memoTextField.delegate = self
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        dateTextField.inputView = datePicker
        categoryTextField.inputView = categoryPickerView

        saveBtn.layer.cornerRadius = 10
        saveBtn.layer.masksToBounds = true

        let _:Gradation = {
            let gradation = Gradation()
            gradation.layer.frame = contentView.bounds
            contentView.layer.insertSublayer(gradation.layer, at: 0)
            return gradation
        }()

        NSLayoutConstraint.activate([
            datePicker.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            categoryPickerView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3)
        ])

        // モザイク用のviewをフィレット
        mosaicView.forEach {
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
        }

        let notification = NotificationCenter.default
        notification.addObserver(self,
                                 selector: #selector(self.keyboardChangeFrame(_:)),
                                 name: UIResponder.keyboardDidChangeFrameNotification,
                                 object: nil)

        notification.addObserver(self,
                                 selector: #selector(self.keyboardWillShow(_:)),
                                 name: UIResponder.keyboardWillShowNotification,
                                 object: nil)

        notification.addObserver(self,
                                 selector: #selector(self.keyboardDidHide(_:)),
                                 name: UIResponder.keyboardDidHideNotification,
                                 object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let today: Date? = {
            let calendar = Calendar(identifier: .gregorian)
            let component = calendar.dateComponents([.year, .month, .day], from: Date())
            let today = calendar.date(
                from: DateComponents(
                    year: component.year,
                    month: component.month,
                    day: component.day)
            )
            return today
        }()
        dateTextField.text = today?.string(dateFormat: "YYYY年MM月dd日")
        categoryTextField.text = category[0]
        expensesTextField.text = ""
        memoTextField.text = ""
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let contentSize = CGSize(width: view.frame.width
                                    - view.safeAreaInsets.left
                                    - view.safeAreaInsets.right,
                                 height: view.frame.height
                                    - view.safeAreaInsets.top
                                    - view.safeAreaInsets.bottom)
        baseScrollView.contentSize = contentSize // スクロールできなくするための設定
    }

    @IBAction private func tappedView(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction private func detePicker(_ sender: UIDatePicker) {
        dateTextField.text = sender.date.string(dateFormat: "YYYY年MM月dd日")
    }

    @IBAction private func tappedCancel(_ sender: Any) {
        let calendarViewController = tabBarController?.viewControllers?[0]
        tabBarController?.selectedViewController = calendarViewController // 画面遷移
    }

    @IBAction private func tappedSave(_ sender: Any) {
        guard "" != expensesTextField.text else {
            showExpensesAlert()
            return
        }
        let date = (dateTextField.text?.date(dateFormat: "YYYY年MM月dd日"))!
        let category = categoryTextField.text ?? ""
        let expenses: Int!
        switch expensesSegmentControl.selectedSegmentIndex {
        case 0:
            expenses = -(Int(expensesTextField.text!) ?? 0)
        default:
            expenses = Int(expensesTextField.text!) ?? 0
        }
        let memo = String(memoTextField.text ?? "")
        let incomeAndExpenditure = IncomeAndExpenditure(date: date, category: category, expenses: expenses, memo: memo)
        dataRepository.loadData() // UserDefaultのデータを上書きしないためにデータを読み込む
        dataRepository.saveData(incomeAndExpenditure: incomeAndExpenditure)

        let calendarViewController = tabBarController?.viewControllers?[0]
        tabBarController?.selectedViewController = calendarViewController // 画面遷移
    }

    // アラートを表示し、ボタンが押されたらexpensesTextFieldを起動する
    private func showExpensesAlert() {
        let alert = UIAlertController(
            title: "収支が未入力です。",
            message: "支出または収入を入力して下さい",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(
                            title: "OK",
                            style: .default,
                            handler: { [weak self] _ in
                                self?.expensesTextField.becomeFirstResponder() }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - TextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingField = textField
        switch textField {
        case dateTextField:
            datePicker.isHidden = false
        case categoryTextField:
            categoryPickerView.isHidden = false
        default:
            return
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        editingField = nil
        switch textField {
        case dateTextField:
            datePicker.isHidden = true
        case categoryTextField:
            categoryPickerView.isHidden = true
        default:
            return
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        category.count
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let category = category[row]
        categoryTextField.text = category
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        category[row]
    }

    // MARK: - Selector
    @objc func keyboardChangeFrame(_ notification: Notification) {

        var overlap: CGFloat = 0 // 重なっている高さ
        guard let fld = editingField else { return }
        // キーボードのframeを調べる
        let userInfo = (notification as NSNotification).userInfo!
        // swiftlint:disable:next force_cast
        let keybordFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        // textFieldのframeをキーボードと同じ座標系にする
        let fldFrame = view.convert(fld.frame, from: contentView)
        // 編集中のtextFieldがキーボードと重なっていないか調べる
        overlap = fldFrame.maxY - keybordFrame.minY + 18
        if overlap > 0 {
            // キーボードで隠れている分だけスクロールする
            overlap += baseScrollView.contentOffset.y
            baseScrollView.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
        }
    }

    private var lastOffsetY: CGFloat = 0 // キーボードが表示される前のスクロール量(現時点不要)
    // (現時点不要)
    @objc func keyboardWillShow(_ notification: Notification) {
        lastOffsetY = baseScrollView.contentOffset.y
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        let baseline: CGFloat = 0
        lastOffsetY = min(baseline, lastOffsetY) // (現時点不要)
        baseScrollView.setContentOffset(CGPoint(x: 0, y: lastOffsetY), animated: true)
    }
}
