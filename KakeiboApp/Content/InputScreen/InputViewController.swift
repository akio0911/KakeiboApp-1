//
//  InputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit

final class InputViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    enum Mode {
            case add
            case edit
        }

    var mode: Mode = .add
    var editingIndexpath = IndexPath() // .editの際に使用する
    var editingFirstDay = Date() // .editの際に使用する

    private var dataRepository = DataRepository()
    private let categoryArray = Category.allCases
    private lazy var categoryString = categoryArray.map { $0.rawValue }
    private lazy var didSelectDate: Date = getToday()
    private var didSelectCategory: Category = .consumption

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

    private var datePicker: UIDatePicker!
    private var categoryPickerView: UIPickerView!

    // 今日の日付を返す
    private func getToday() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.dateComponents([.year, .month, .day], from: Date())
        let today = calendar.date(
            from: DateComponents(
                year: component.year,
                month: component.month,
                day: component.day)
        )
        return today!
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarButtonItem()
        
        settingTextFieldDelegate() // textField.delegateを設定
        settingPickerKeybord() // pickerViewをキーボードに設定
        configureSaveBtnLayer() // セーブボタンをフィレット
        insertGradationLayer() // グラデーション設定
        settingHeightPicker() // pickerViewの高さ設定
        configureMosaicViewLayer() // モザイク用のviewをフィレット
        settingKeyboardNotification() // Keyboardのnotification設定
    }

    private func setupBarButtonItem() {
        let saveBarButton = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(tappedSave)
        )
        navigationItem.rightBarButtonItem = saveBarButton

        let cancelBarButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(tappedCancel)
        )
        navigationItem.leftBarButtonItem = cancelBarButton
    }

    // textFieldDelegateの設定
    private func settingTextFieldDelegate() {
        dateTextField.delegate = self
        categoryTextField.delegate = self
        expensesTextField.delegate = self
        memoTextField.delegate = self
    }

    // セーブボタンをフィレット
    private func configureSaveBtnLayer() {
        saveBtn.layer.cornerRadius = 10
        saveBtn.layer.masksToBounds = true
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

    // Keyboardのnotificationの設定
    private func settingKeyboardNotification() {
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

    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch mode {
        case .add:
            expensesTextField.text = ""
            memoTextField.text = ""
        case .edit:
            let data = dataRepository.fetchDayData(monthFirstDay: editingFirstDay, at: editingIndexpath)
            didSelectDate = data.date
            didSelectCategory = data.category
            expensesTextField.text =
                data.expenses >= 0 ? String(data.expenses) : String(-data.expenses)
            memoTextField.text = data.memo
            expensesSegmentControl.selectedSegmentIndex =
                data.expenses < 0 ? 0 : 1
        }
        dateTextField.text = didSelectDate.string(dateFormat: "YYYY年MM月dd日")
        categoryTextField.text = didSelectCategory.rawValue
    }

    // MARK: - viewDidLayoutSubviews
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

    // MARK: - @IBAction
    @IBAction private func tappedView(_ sender: Any) {
        view.endEditing(true)
    }

    @objc private func tappedCancel() {
        mode = .add // 画面遷移する前に初期化
        let calendarViewController = tabBarController?.viewControllers?[0]
        tabBarController?.selectedViewController = calendarViewController // 画面遷移
    }

    @objc private func tappedSave() {
        guard "" != expensesTextField.text else {
            showExpensesAlert()
            return
        }
        let date = didSelectDate
        let category = didSelectCategory
        let expenses: Int!
        switch expensesSegmentControl.selectedSegmentIndex {
        case 0:
            expenses = -(Int(expensesTextField.text!) ?? 0)
        default:
            expenses = Int(expensesTextField.text!) ?? 0
        }
        let memo = String(memoTextField.text ?? "")
        let incomeAndExpenditure = IncomeAndExpenditure(date: date, category: category, expenses: expenses, memo: memo)
        switch mode {
        case .add:
            dataRepository.loadData() // UserDefaultのデータを上書きしないためにデータを読み込む
            dataRepository.saveData(incomeAndExpenditure: incomeAndExpenditure)
        case .edit:
            dataRepository.loadData() // UserDefaultのデータを読み込む
            dataRepository.saveEditData(monthFirstDay: editingFirstDay,
                                        at: editingIndexpath,
                                        saveData: incomeAndExpenditure)
        }

        mode = .add // 画面遷移する前に初期化
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
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        editingField = nil
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
        categoryArray.count
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let categoryString = categoryString[row]
        categoryTextField.text = categoryString
        didSelectCategory = categoryArray[row]
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        categoryString[row]
    }

    // MARK: - notificationのSelector
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

    // MARK: - detePickerのSelector
    @objc func datePickerValueChange() {
        let calendar = Calendar(identifier: .gregorian)
        let dateComponent = calendar.dateComponents([.year, .month, .day], from: datePicker.date)
        didSelectDate = calendar.date(
            from: DateComponents(
                year: dateComponent.year,
                month: dateComponent.month,
                day:dateComponent.day)
        )!
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY年MM月dd日"
        dateTextField.text = "\(formatter.string(from: datePicker.date))"
    }
}
