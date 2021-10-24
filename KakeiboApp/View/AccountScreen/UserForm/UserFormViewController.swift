//
//  UserFormViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/24.
//

import UIKit

class UserFormViewController: UIViewController {

    enum Mode {
        case login
        case create
        case forgotPassword
    }

    @IBOutlet private weak var userFormImageView: UIImageView!
    @IBOutlet private weak var userNameStackView: UIStackView!
    @IBOutlet private weak var mailStackView: UIStackView!
    @IBOutlet private weak var passwordStackView: UIStackView!
    @IBOutlet private weak var userNameTextField: UITextField!
    @IBOutlet private weak var mailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private var iconViews: [UIView]!
    @IBOutlet private weak var enterButton: UIButton!
    @IBOutlet private weak var forgotPasswordButton: UIButton!
    @IBOutlet private weak var passwordSecureTextButton: UIButton!

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCornerRadius()
    }

    private func setupCornerRadius() {
        // 各入力欄をフィレット
        let contentsStackView: [UIStackView] = [
        userNameStackView,
        mailStackView,
        passwordStackView
        ]
        contentsStackView.forEach {
            $0.layer.cornerRadius = $0.bounds.height / 2
            $0.layer.masksToBounds = true
        }

        // 各入力欄アイコンをフィレット
        iconViews.forEach {
            $0.layer.cornerRadius = $0.bounds.height / 2
            $0.layer.masksToBounds = true
        }

        // enterButtonをフィレット
        enterButton.layer.cornerRadius = enterButton.bounds.height / 2
        enterButton.layer.masksToBounds = true
    }

    // MARK: - viewDidLayoutSubviews()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUserFormImageViewCornerRadius()
    }

    private func setupUserFormImageViewCornerRadius() {
        // userFormImageViewをフィレット
        let cornerRadiusRate: CGFloat = 0.15
        userFormImageView.layer.cornerRadius = userFormImageView.bounds.height * cornerRadiusRate
        userFormImageView.layer.masksToBounds = true
    }
}
