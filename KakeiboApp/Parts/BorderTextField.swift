//
//  BorderTextField.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/07/10.
//

import UIKit

final class BorderTextField: UITextField {
    enum BorderState {
        case notEditing
        case editing
        case error

        var borderWidth: Double {
            switch self {
            case .notEditing:
                return 1
            case .editing, .error:
                return 2
            }
        }

        var borderColor: CGColor? {
            switch self {
            case .notEditing:
                return R.color.s999999()?.cgColor
            case .editing:
                return R.color.s34C759()?.cgColor
            case .error:
                return R.color.sFF3B30()?.cgColor
            }
        }
    }

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
    }

    required init?(coder: NSCoder) {
        borderState = .notEditing
        super.init(coder: coder)
        setupCornerRadius()
    }

    private func setupCornerRadius() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }
}
