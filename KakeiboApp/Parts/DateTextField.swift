//
//  DateTextField.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/07/11.
//

import UIKit
import RxSwift
import RxCocoa

final class DateTextField: BorderTextField {
    private var datePicker: UIDatePicker = {
        var datePicker = UIDatePicker()
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.locale = .current
        datePicker.tintColor = R.color.sFF9B00()
        return datePicker
    }()

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        inputView = datePicker
        setupBinding()
        setupTextFieldView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        inputView = datePicker
        setupBinding()
        setupTextFieldView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        inputView = datePicker
        setupBinding()
        setupTextFieldView()
    }

    func setupDatePicker(date: Date) {
        datePicker.date = date
    }

    private func setupTextFieldView() {
        tintColor = R.color.sFF9B00()
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: frame.height))
        leftViewMode = .always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: frame.height))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "calendar")?.withTintColor(R.color.sFF9B00()!, renderingMode: .alwaysOriginal)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: frame.height))
        view.isUserInteractionEnabled = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 7)
        ])
        rightView = view
        rightViewMode = .always
    }

    private func setupBinding() {
        datePicker.rx.value
            .subscribe { [weak self] date in
                self?.text = DateUtility.stringFromDate(date: date, format: "yyyy年MM月dd日")
            }
            .disposed(by: disposeBag)
    }
}
