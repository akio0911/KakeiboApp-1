//
//  AccountViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import RxSwift
import RxCocoa
import FirebaseAuth

protocol AccountViewModelInput {
    func viewWillAppear()
    func viewWillDisappear()
    func didTapAccountEnterButton()
    func didTapSignupButton()
    func didValueChangedPasscodeSwitch(value: Bool)
    func didTapCategoryEditButton()
    func didTapHowtoUseButton()
    func didTapShareButton()
    func didTapReviewButton()
}

protocol AccountViewModelOutput {
    var userNameLabel: Driver<String> { get }
    var accountEnterButtonTitle: Driver<String> { get }
    var isHiddenSignupButton: Driver<Bool> { get }
    var isOnPasscode: Driver<Bool> { get }
    var event: Driver<AccountViewModel.Event> { get }
}

protocol AccountViewModelType {
    var inputs: AccountViewModelInput { get }
    var outputs: AccountViewModelOutput { get }
}

final class AccountViewModel: AccountViewModelInput, AccountViewModelOutput {
    enum Event {
        case presentLogin
        case presentCreate
        case presentPasscodeVC
        case pushCategoryEditVC
        case pushHowToVC
        case presentActivityVC([Any])
        case applicationSharedOpen(URL)
    }
    
    private let passcodeRepository: IsOnPasscodeRepositoryProtocol
    private let userNameLabelRelay = BehaviorRelay<String>(value: "")
    private let accountEnterButtonTitleRelay = BehaviorRelay<String>(value: "")
    private let isHiddenSignupButtonRelay = BehaviorRelay<Bool>(value: false)
    private let isOnPasscodeRelay = BehaviorRelay<Bool>(value: false)
    private let eventRelay = PublishRelay<Event>()
    private var handle: AuthStateDidChangeListenerHandle?
    
    init(passcodeRepository: IsOnPasscodeRepositoryProtocol = PasscodeRepository()) {
        self.passcodeRepository = passcodeRepository
        isOnPasscodeRelay.accept(passcodeRepository.loadIsOnPasscode())
        setupPasscodeObserver()
    }
    
    private func setupPasscodeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(passcodeViewDidTapCancelButton(_:)),
            name: PasscodePoster.passcodeViewDidTapCancelButton,
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func passcodeViewDidTapCancelButton(_ notification: Notification) {
        passcodeRepository.saveIsOnPasscode(isOnPasscode: false)
        isOnPasscodeRelay.accept(false)
    }
    
    var userNameLabel: Driver<String> {
        userNameLabelRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var accountEnterButtonTitle: Driver<String> {
        accountEnterButtonTitleRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var isHiddenSignupButton: Driver<Bool> {
        isHiddenSignupButtonRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var isOnPasscode: Driver<Bool> {
        isOnPasscodeRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    func viewWillAppear() {
        // 認証状態をリッスン
        // ログイン状態が変わるたびに呼ばれる
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let strongSelf = self else { return }
            if user == nil {
                // ログアウト中
                strongSelf.userNameLabelRelay.accept("ログアウト中")
                strongSelf.accountEnterButtonTitleRelay.accept("ログイン")
                strongSelf.isHiddenSignupButtonRelay.accept(true)
            } else {
                // ログイン中
                if let userName = user?.displayName {
                    // ユーザー名がある(メールとパスワードによるログイン中)
                    strongSelf.userNameLabelRelay.accept(userName)
                    strongSelf.accountEnterButtonTitleRelay.accept("ログアウト")
                    strongSelf.isHiddenSignupButtonRelay.accept(true)
                } else {
                    // ユーザー名がない(匿名認証によるログイン中)
                    strongSelf.userNameLabelRelay.accept("未登録")
                    strongSelf.accountEnterButtonTitleRelay.accept("ログイン")
                    strongSelf.isHiddenSignupButtonRelay.accept(false)
                }
            }
        }
    }
    
    func viewWillDisappear() {
        // リスナーをデタッチ
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func didTapAccountEnterButton() {
        let firebaseAuth = Auth.auth()
        if let currentUser = firebaseAuth.currentUser {
            // ログイン中
            if currentUser.displayName == nil {
                // ユーザー名がない(匿名認証によるログイン中)
                eventRelay.accept(.presentLogin)
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
            eventRelay.accept(.presentLogin)
        }
    }
    
    func didTapSignupButton() {
        eventRelay.accept(.presentCreate)
    }
    
    func didValueChangedPasscodeSwitch(value: Bool) {
        passcodeRepository.saveIsOnPasscode(isOnPasscode: value)
        if value {
            eventRelay.accept(.presentPasscodeVC)
        }
    }
    
    func didTapCategoryEditButton() {
        eventRelay.accept(.pushCategoryEditVC)
    }
    
    func didTapHowtoUseButton() {
        eventRelay.accept(.pushHowToVC)
    }
    
    func didTapShareButton() {
        let shareText = "Sample"
        guard let shareUrl = NSURL(string: "https://www.apple.com/") else { return }
        let activityItems = [shareText, shareUrl] as [Any]
        eventRelay.accept(.presentActivityVC(activityItems))
    }
    
    func didTapReviewButton() {
        let appId = "375380948"
        guard let url = URL(string: "https://apps.apple.com/jp/app/apple-store/id\(appId)?action=write-review") else { return }
        eventRelay.accept(.applicationSharedOpen(url))
    }
}

extension AccountViewModel: AccountViewModelType {
    var inputs: AccountViewModelInput {
        return self
    }
    
    var outputs: AccountViewModelOutput {
        return self
    }
}
