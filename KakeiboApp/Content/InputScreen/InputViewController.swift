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
    
    var editingField: UITextField?
    var overlap: CGFloat = 0
    var lastOffsetY: CGFloat = 0
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var mosaicView: [UIView]!
    @IBOutlet var textField: [UITextField]!
    @IBOutlet weak var incomeAndExpenditure: UISegmentedControl!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    private let category = Category()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.frame = CGRect(x: 0, y: navigationBar.frame.maxY, width: view.frame.width, height: view.frame.height - navigationBar.frame.maxY)
        scrollView.contentSize = CGSize(width: view.frame.width, height: contentView.frame.height)
        
        calendarViewController = (tabBarController?.viewControllers![0] as! CalendarViewController)
        
        for fld in textField {
            fld.delegate = self
        }
        
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        textField[0].inputView = datePicker
        textField[1].inputView = categoryPickerView
        
        saveBtn.layer.cornerRadius = 10
        saveBtn.layer.masksToBounds = true
        gradation.gradientLayer.frame = contentView.bounds
        contentView.layer.insertSublayer(gradation.gradientLayer, at: 0)
        
        NSLayoutConstraint.activate([
            datePicker.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            categoryPickerView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3)
        ])
        
        for i in mosaicView {
            i.layer.cornerRadius = 8
            i.layer.masksToBounds = true
        }
        
        // アラートのボタンアクションを作る
        expenses.alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                            self?.textField[2].becomeFirstResponder() })
        )
        
        let notification = NotificationCenter.default
        notification.addObserver(self,
                                 selector: #selector(self.keyboardChangeFrame(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        
        notification.addObserver(self,
                                 selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        notification.addObserver(self,
                                 selector: #selector(self.keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let calendarDate = calendarViewController.calendarDate
        textField[0].text = calendarDate.today.string(dateFormat: "YYYY年MM月dd日")
        textField[1].text = category.category[0]
        textField[2].text = ""
        textField[3].text = ""
    }
    
    @IBAction func tappedView(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func detePicker(_ sender: UIDatePicker) {
        textField[0].text = sender.date.string(dateFormat: "YYYY年MM月dd日")
    }
    
    @IBAction func tappedCancel(_ sender: Any) {
        let calendarViewController = tabBarController?.viewControllers?[0]
        tabBarController?.selectedViewController = calendarViewController
    }
    
    @IBAction func tappedSave(_ sender: Any) {
        guard "" != textField[2].text else {
            present(expenses.alert, animated: true, completion: nil)
            return
        }
        let date = (textField[0].text?.date(dateFormat: "YYYY年MM月dd日"))!
        let category = textField[1].text ?? ""
        let expenses: Int!
        switch incomeAndExpenditure.selectedSegmentIndex {
        case 0:
            expenses = -(Int(textField[2].text!) ?? 0)
        default:
            expenses = Int(textField[2].text!) ?? 0
        }
        let memo = String(textField[3].text ?? "")
        let incomeAndExpenditure = IncomeAndExpenditure(date: date, category: category, expenses: expenses, memo: memo)
        let dataRepository = calendarViewController.dataRepository
        dataRepository.saveData(incomeAndExpenditure: incomeAndExpenditure)
        
        let calendarViewController = tabBarController?.viewControllers?[0]
        tabBarController?.selectedViewController = calendarViewController
    }
    
    // MARK: - TextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingField = textField
        switch textField {
        case self.textField[0]:
            datePicker.isHidden = false
        case self.textField[1]:
            categoryPickerView.isHidden = false
        default:
            return
        }
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
        category.category.count
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let category = category.category[row]
        textField[1].text = category
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        category.category[row]
    }
    
    // MARK: - Selector
    @objc func keyboardChangeFrame(_ notification: Notification) {
        
        guard let fld = editingField else {
            return
        }
        
        let userInfo = (notification as NSNotification).userInfo!
        let keybordFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let fldFrame = view.convert(fld.frame, from: contentView)
        overlap = fldFrame.maxY - keybordFrame.minY + 18
        if overlap > 0 {
            overlap += scrollView.contentOffset.y
            scrollView.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        lastOffsetY = scrollView.contentOffset.y
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        let baseline = contentView.bounds.height - scrollView.bounds.height
        lastOffsetY = min(baseline, lastOffsetY)
        scrollView.setContentOffset(CGPoint(x: 0, y: lastOffsetY), animated: true)
    }
}
