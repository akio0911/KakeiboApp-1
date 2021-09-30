//
//  PasscodeViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import UIKit

class PasscodeViewController: UIViewController, PasscodeInputButtonViewDelegate {

    @IBOutlet private weak var messageLable: UILabel!
    @IBOutlet private weak var firstKeyImageView: UIImageView!
    @IBOutlet private weak var secondKeyImageView: UIImageView!
    @IBOutlet private weak var thirdKeyImageView: UIImageView!
    @IBOutlet private weak var fourthKeyImageView: UIImageView!

    private var passcodeInputButtonView: PasscodeInputButtonView!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPasscodeInputButtonView()
    }

    private func setupPasscodeInputButtonView() {
        passcodeInputButtonView = PasscodeInputButtonView()
        passcodeInputButtonView.delegate = self
        passcodeInputButtonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passcodeInputButtonView)
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupPasscodeInputButtonViewConstraint()
    }

    private func setupPasscodeInputButtonViewConstraint() {
        NSLayoutConstraint.activate([
            passcodeInputButtonView.topAnchor.constraint(equalTo: messageLable.bottomAnchor, constant: 100),
            passcodeInputButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            passcodeInputButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            passcodeInputButtonView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            passcodeInputButtonView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -70)
        ])
    }

    // MARK: - PasscodeInputButtonViewDelegate
    func didTapNumberButton(title: String) {
    }

    func didTapDeleteButton() {
    }
}
