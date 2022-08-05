//
//  CurrencyTextField.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/07/12.
//

import UIKit
import RxSwift
import RxCocoa

final class CurrencyTextField: BorderTextField {
    private let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextFieldView()
        setupBinding()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextFieldView()
        setupBinding()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextFieldView()
        setupBinding()
    }

    private func setupTextFieldView() {
        tintColor = R.color.sFF9B00()
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 9, height: frame.height))
        leftViewMode = .always
        let yenLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 23, height: 30))
        yenLabel.text = R.string.localizable.yen()
        yenLabel.textColor = R.color.s333333()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: frame.height))
        view.isUserInteractionEnabled = false
        view.addSubview(yenLabel)
        NSLayoutConstraint.activate([
            yenLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: yenLabel.trailingAnchor, constant: 7)
        ])
        rightView = view
        rightViewMode = .always
    }

    private func setupBinding() {
        rx.text.orEmpty.asDriver()
            .drive(onNext: { [weak self] text in
                self?.formatCurrencyText(text: text)
            })
            .disposed(by: disposeBag)
    }

    private func formatCurrencyText(text: String) {
        let maxLength = 12
        var numberText = text.filter { Int(String($0)) != nil }
        // 12桁より大きい値は入力させない
        if numberText.count > maxLength {
            numberText = String(numberText.prefix(maxLength))
        }
        // カンマをつけてテキストフィールドに表示
        self.text = NumberFormatterUtility.changeToDecimal(
            from: Int(numberText) ?? 0
        )
    }
}
