//
//  AccountViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

final class AccountViewController: UIViewController {

    @IBOutlet private weak var settingStackView: UIStackView!
    @IBOutlet private weak var appStackView: UIStackView!
    @IBOutlet private weak var passcodeSwitch: UISwitch!
    @IBOutlet private weak var categoryEditButton: BackgroundHighlightedButton!
    @IBOutlet private weak var howToUseButton: BackgroundHighlightedButton!
    @IBOutlet private weak var shareButton: BackgroundHighlightedButton!
    @IBOutlet private weak var reviewButton: BackgroundHighlightedButton!
    @IBOutlet private weak var accountIconView: UIView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var accountEnterButton: UIButton!
    @IBOutlet private weak var signupButton: UIButton!

    private let viewModel: AccountViewModelType
    private let disposeBag = DisposeBag()
    private var handle: AuthStateDidChangeListenerHandle?

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
        navigationItem.title = "アカウント"
        setupCornerRadius()
    }

    private func setupBinding() {
        accountEnterButton.rx.tap
            .subscribe(onNext: didTapAccountEnterButton)
            .disposed(by: disposeBag)

        signupButton.rx.tap
            .subscribe(onNext: didTapSignupButton)
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

        viewModel.outputs.isOnPasscode
            .drive(passcodeSwitch.rx.value)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .presentPasscodeVC:
                    let passcodeViewController = PasscodeViewController(
                        viewModel: PasscodeViewModel(mode: .create(.first))
                    )
                    let navigationController = UINavigationController(rootViewController: passcodeViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true, completion: nil)
                case .pushCategoryEditVC:
                    let categoryEditViewController = CategoryEditViewController()
                    categoryEditViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(categoryEditViewController, animated: true)
                case .pushHowToVC:
                    let howToViewController = HowToUseViewController()
                    howToViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(howToViewController, animated: true)
                case .presentActivityVC(let items):
                    let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    self.present(activityVC, animated: true, completion: nil)
                case .applicationSharedOpen(let url):
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func didTapAccountEnterButton() {
        let firebaseAuth = Auth.auth()
        if let currentUser = firebaseAuth.currentUser {
            // ログイン中
            if currentUser.displayName == nil {
                // ユーザー名がない(匿名認証によるログイン中)
                presentAuthFormVC(viewModel: AuthFormViewModel(mode: .login))
            } else {
                // ユーザー名がある(メールとパスワードによるログイン中)
                // ログアウト処理
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                    print("signOutError: \(signOutError.localizedDescription)")
                }
            }
        } else {
            // ログアウト中
            presentAuthFormVC(viewModel: AuthFormViewModel(mode: .login))
        }
    }

    private func didTapSignupButton() {
        presentAuthFormVC(viewModel: AuthFormViewModel(mode: .create))
    }

    private func presentAuthFormVC(viewModel: AuthFormViewModelType) {
        let authFormViewController = AuthFormViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: authFormViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
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

    // MARK: - viewWillApper(_:)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 認証状態をリッスン
        // ログイン状態が変わるたびに呼ばれる
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let strongSelf = self else { return }
            if user == nil {
                // ログアウト中
                strongSelf.userNameLabel.text = "ログアウト中"
                strongSelf.accountEnterButton.setTitle("ログイン", for: .normal)
                strongSelf.signupButton.isHidden = true
            } else {
                // ログイン中
                if let userName = user?.displayName {
                    // ユーザー名がある(メールとパスワードによるログイン中)
                    strongSelf.userNameLabel.text = userName
                    strongSelf.accountEnterButton.setTitle("ログアウト", for: .normal)
                    strongSelf.signupButton.isHidden = true
                } else {
                    // ユーザー名がない(匿名認証によるログイン中)
                    strongSelf.userNameLabel.text = "未登録"
                    strongSelf.accountEnterButton.setTitle("ログイン", for: .normal)
                    strongSelf.signupButton.isHidden = false
                }
            }
        }
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

    // MARK: - viewWillDIsappear(_:)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // リスナーをデタッチ
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}
