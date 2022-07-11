//
//  BorderTextField.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/07/10.
//

import UIKit
import RxSwift
import RxCocoa

final class BorderTextField: UITextField {
    enum BorderState {
        case notEditing
        case editing

        var borderWidth: CGFloat {
            switch self {
            case .notEditing:
                return 1
            case .editing:
                return 2
            }
        }

        var borderColor: CGColor? {
            switch self {
            case .notEditing:
                return R.color.s999999()?.cgColor
            case .editing:
                return R.color.sFF9B00()?.cgColor
            }
        }
    }

    private let disposeBag = DisposeBag()

    var borderState: BorderState {
        didSet {
            self.layer.borderWidth = borderState.borderWidth
            self.layer.borderColor = borderState.borderColor
        }
    }

    override init(frame: CGRect) {
        borderState = .notEditing
        super.init(frame: frame)
        setupCornerRadius()
        setupBinding()
    }

    required init?(coder: NSCoder) {
        borderState = .notEditing
        super.init(coder: coder)
        setupCornerRadius()
        setupBinding()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        borderState = .notEditing
        setupCornerRadius()
        setupBinding()
    }

    private func setupCornerRadius() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }

    private func setupBinding() {
        rx.controlEvent(.editingDidBegin)
            .subscribe { [weak self] _ in
                self?.borderState = .editing
            }
            .disposed(by: disposeBag)

        rx.controlEvent(.editingDidEnd)
            .subscribe { [weak self] _ in
                self?.borderState = .notEditing
            }
            .disposed(by: disposeBag)
    }
}
