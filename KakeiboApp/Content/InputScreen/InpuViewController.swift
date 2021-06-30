//
//  InputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit

class InputViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var calendarViewController: CalendarViewController!
    let gradation = Gradation()
    let expenses = ExpensesAlert()

    @IBOutlet var contentsView: [UIView]!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var incomeAndExpenditure: UISegmentedControl!
    @IBOutlet weak var expensesTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    private let category = Category()

    override func viewDidLoad() {
        super.viewDidLoad()
        // swiftlint:disable:next force_cast
        calendarViewController = (tabBarController?.viewControllers![0] as! CalendarViewController)
        dateTextField.delegate = self
        memoTextField.delegate = self
        categoryTextField.delegate = self
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        dateTextField.inputView = datePicker
        categoryTextField.inputView = categoryPickerView

        saveBtn.layer.cornerRadius = 10
        saveBtn.layer.masksToBounds = true
        gradation.gradientLayer.frame = view.viewWithTag(1)!.bounds
        view.viewWithTag(1)!.layer.insertSublayer(gradation.gradientLayer, at: 0)

        NSLayoutConstraint.activate([
            datePicker.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            categoryPickerView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3)
        ])

        for view in contentsView {
            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true
        }

        expenses.alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                            self?.expensesTextField.becomeFirstResponder() })
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let calendarDate = calendarViewController.calendarDate
        dateTextField.text = calendarDate.today.string(dateFormat: "yyyy/MM/dd")
        expensesTextField.text = ""
        memoTextField.text = ""
        categoryTextField.text = category.category[0]
    }

    @IBAction func tappedView(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction func detePicker(_ sender: UIDatePicker) {
        dateTextField.text = sender.date.string(dateFormat: "yyyy/MM/dd")
    }

    @IBAction func tappedCancel(_ sender: Any) {
        let calendarViewController = tabBarController?.viewControllers?[0]
        tabBarController?.selectedViewController = calendarViewController
    }

    @IBAction func tappedSave(_ sender: Any) {
        guard "" != expensesTextField.text else {
            present(expenses.alert, animated: true, completion: nil)
            return
        }
        let date = (dateTextField.text?.date(dateFormat: "yyyy/MM/dd"))!
        let category = categoryTextField.text ?? ""
        let expenses: Int!
        switch incomeAndExpenditure.selectedSegmentIndex {
        case 0:
            expenses = -(Int(expensesTextField.text!) ?? 0)
        default:
            expenses = Int(expensesTextField.text!) ?? 0
        }
        let memo = String(memoTextField.text ?? "")
        let incomeAndExpenditure = IncomeAndExpenditure(date: date, category: category, expenses: expenses, memo: memo)
        let dataRepository = calendarViewController.dataRepository
        dataRepository.saveData(incomeAndExpenditure: incomeAndExpenditure)

        let calendarViewController = tabBarController?.viewControllers?[0]
        tabBarController?.selectedViewController = calendarViewController
    }

    // MARK: - TextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case dateTextField:
            datePicker.isHidden = false
        default:
            categoryPickerView.isHidden = false
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
        category.category.count
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let category = category.category[row]
        categoryTextField.text = category
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        category.category[row]
    }
}
