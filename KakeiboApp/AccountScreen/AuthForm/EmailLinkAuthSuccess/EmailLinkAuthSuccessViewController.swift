//
//  EmailLinkAuthSuccessViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/11/13.
//

import UIKit
import RxSwift
import RxCocoa

final class EmailLinkAuthSuccessViewController: UIViewController {
    @IBOutlet private weak var baseStackView: UIStackView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var emailResendButton: UIButton!
    @IBOutlet private weak var emailChangeButton: UIButton!

    private let viewModel: EmailLinkAuthSuccessViewModelType
    private let disposeBag = DisposeBag()

    init(viewModel: EmailLinkAuthSuccessViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCornerRadiusIconImageView()
        setupBaseStackViewSpacing()
        setupBinding()
        self.navigationItem.hidesBackButton = true
    }

    private func setupCornerRadiusIconImageView() {
        iconImageView.layer.cornerRadius = 10
        iconImageView.layer.masksToBounds = true
    }

    private func setupBaseStackViewSpacing() {
        baseStackView.setCustomSpacing(20, after: iconImageView)
        baseStackView.setCustomSpacing(20, after: emailLabel)
        baseStackView.setCustomSpacing(20, after: titleLabel)
        baseStackView.setCustomSpacing(80, after: messageLabel)
        baseStackView.setCustomSpacing(20, after: emailResendButton)
    }

    private func setupBinding() {
        emailResendButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapEmailResendButton)
            .disposed(by: disposeBag)

        emailChangeButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapEmailChangeButton)
            .disposed(by: disposeBag)

        viewModel.outputs.email
            .drive(emailLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case .popVC:
                    strongSelf.navigationController?.popViewController(animated: true)
                case .presentAlertView(alertTitle: let alertTitle, message: let message):
                    strongSelf.showAlert(title: alertTitle, messege: message)
                case .startAnimating:
                    strongSelf.showProgress()
                case .stopAnimating:
                    strongSelf.hideProgress()
                }
            })
            .disposed(by: disposeBag)
    }
}
