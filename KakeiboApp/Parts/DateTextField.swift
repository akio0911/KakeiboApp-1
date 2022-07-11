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
    var datePicker: UIDatePicker = {
        var datePicker = UIDatePicker()
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .date
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.locale = .current
        return datePicker
    }()

    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        inputView = datePicker
        setupBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        inputView = datePicker
        setupBinding()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        inputView = datePicker
        setupBinding()
    }

    private func setupBinding() {
        datePicker.rx.value
            .subscribe { [weak self] date in
                self?.text = DateUtility.stringFromDate(date: date, format: "yyyy年MM月d日")
            }
            .disposed(by: disposeBag)
    }
}
