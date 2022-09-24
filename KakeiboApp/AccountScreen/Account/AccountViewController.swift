//
//  AccountViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import UIKit
import RxSwift
import RxCocoa

final class AccountViewController: UIViewController {
    @IBOutlet private weak var settingStackView: UIStackView!
    @IBOutlet private weak var appStackView: UIStackView!
    @IBOutlet private weak var passcodeSwitch: UISwitch!
    @IBOutlet private weak var categoryEditButton: BackgroundHighlightedButton!
    @IBOutlet private weak var howToUseButton: BackgroundHighlightedButton!
    @IBOutlet private weak var shareButton: BackgroundHighlightedButton!
    @IBOutlet private weak var reviewButton: BackgroundHighlightedButton!
    @IBOutlet private weak var accountStackView: UIStackView!
    @IBOutlet private weak var accountIconView: UIView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var accountEnterButton: UIButton!
    @IBOutlet private weak var authButton: UIButton!

    private let viewModel: AccountViewModelType
    private let disposeBag = DisposeBag()

    init(viewModel: AccountViewModelType = AccountViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        navigationItem.title = R.string.localizable.account()
        setupAccountStackViewSpace()
        setupCornerRadius()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.onViewWillAppear()
    }

    // swiftlint:disable:next function_body_length
    private func setupBinding() {
        accountEnterButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapAccountEnterButton)
            .disposed(by: disposeBag)

        authButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapAuthButton)
            .disposed(by: disposeBag)

        passcodeSwitch.rx.value
            .skip(1) // stateの値が流れるためスキップ
            .subscribe(onNext: viewModel.inputs.didValueChangedPasscodeSwitch)
            .disposed(by: disposeBag)

        categoryEditButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapCategoryEditButton)
            .disposed(by: disposeBag)

        howToUseButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapHowtoUseButton)
            .disposed(by: disposeBag)

        shareButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapShareButton)
            .disposed(by: disposeBag)

        reviewButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapReviewButton)
            .disposed(by: disposeBag)

        viewModel.outputs.userNameLabel
            .drive(userNameLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.accountEnterButtonTitle
            .drive(onNext: { [weak self] title in
                guard let strongSelf = self else { return }
                strongSelf.accountEnterButton.setTitle(title, for: .normal)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.authButtonTitle
            .drive(onNext: { [weak self] title in
                guard let strongSelf = self else { return }
                strongSelf.authButton.setTitle(title, for: .normal)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.isHiddenAuthButton
            .drive(authButton.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.isHiddenAccountEnterButton
            .drive(accountEnterButton.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.isOnPasscode
            .drive(passcodeSwitch.rx.value)
            .disposed(by: disposeBag)

        viewModel.outputs.isAnimatedIndicator
            .drive(onNext: animateActivityIndicatorView(isAnimated:))
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case .pushLogin:
                    strongSelf.pushAuthFormVC(viewModel: AuthFormViewModel(mode: .login))
                case .pushRegister:
                    strongSelf.pushAuthFormVC(viewModel: AuthFormViewModel(mode: .register))
                case .presentPasscodeVC:
                    strongSelf.presentPasscodeVC()
                case .pushCategoryEditVC:
                    strongSelf.pushCategoryEditVC()
                case .pushHowToVC:
                    strongSelf.pushHowToVC()
                case .presentActivityVC(let items):
                    strongSelf.presentActivityVC(items: items)
                case .applicationSharedOpen(let url):
                    strongSelf.applicationSharedOpen(url: url)
                case .showDestructiveAlert(title: let title, message: let message, destructiveTitle: let destructiveTitle, onDestructive: let onDestructive):
                    strongSelf.showDestructiveAlert(title: title, message: message, destructiveTitle: destructiveTitle, onDestructive: onDestructive)
                case .showAlert(title: let title, message: let message):
                    strongSelf.showAlert(title: title, messege: message)
                case .showErrorAlert:
                    strongSelf.showErrorAlert()
                }
            })
            .disposed(by: disposeBag)
    }

    private func animateActivityIndicatorView(isAnimated: Bool) {
        if isAnimated {
            showProgress()
        } else {
            hideProgress()
        }
    }

    private func pushAuthFormVC(viewModel: AuthFormViewModelType) {
        let authFormViewController = AuthFormViewController(viewModel: viewModel)
        authFormViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(authFormViewController, animated: true)
    }

    private func presentPasscodeVC() {
        let passcodeViewController = PasscodeViewController(
            viewModel: PasscodeViewModel(mode: .create(.first))
        )
        let navigationController = UINavigationController(rootViewController: passcodeViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    private func pushCategoryEditVC() {
        let categoryEditViewController = CategoryEditViewController()
        categoryEditViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(categoryEditViewController, animated: true)
    }

    private func pushHowToVC() {
        let howToViewController = HowToUseViewController()
        howToViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(howToViewController, animated: true)
    }

    private func presentActivityVC(items: [Any]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }

    private func applicationSharedOpen(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func setupAccountStackViewSpace() {
        accountStackView.setCustomSpacing(8, after: accountIconView)
        accountStackView.setCustomSpacing(20, after: userNameLabel)
    }

    private func setupCornerRadius() {
        // 入力ボタンをフィレット
        accountEnterButton.layer.cornerRadius = accountEnterButton.bounds.height / 2
        accountEnterButton.layer.masksToBounds = true

        // 設定Viewをフィレット
        settingStackView.layer.cornerRadius = 10
        settingStackView.layer.masksToBounds = true

        // アプリViewをフィレット
        appStackView.layer.cornerRadius = 10
        appStackView.layer.masksToBounds = true
    }

    // MARK: - viewDidLayoutSubviews()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAccountIconViewCornerRadius()
    }

    private func setupAccountIconViewCornerRadius() {
        // アカウントアイコンをフィレット
        accountIconView.layer.cornerRadius = accountIconView.bounds.height / 2
        accountIconView.layer.masksToBounds = true
    }
}
