//
//  AccountViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import RxSwift
import RxCocoa

protocol AccountViewModelInput {
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
    var isHiddenAccountEnterButton: Driver<Bool> { get }
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
    private let authType: AuthTypeProtocol
    private let disposeBag = DisposeBag()
    private let userNameLabelRelay = BehaviorRelay<String>(value: "")
    private let accountEnterButtonTitleRelay = BehaviorRelay<String>(value: "")
    private let isHiddenSignupButtonRelay = BehaviorRelay<Bool>(value: false)
    private let isHiddenAccountEnterButtonRelay = BehaviorRelay<Bool>(value: false)
    private let isOnPasscodeRelay = BehaviorRelay<Bool>(value: false)
    private let eventRelay = PublishRelay<Event>()
    private var userInfo: UserInfo?
    private let appId = "1571086397"

    init(passcodeRepository: IsOnPasscodeRepositoryProtocol = PasscodeRepository(),
         authType: AuthTypeProtocol = ModelLocator.shared.authType) {
        self.passcodeRepository = passcodeRepository
        self.authType = authType
        setupBinding()
        isOnPasscodeRelay.accept(passcodeRepository.loadIsOnPasscode())
        setupPasscodeObserver()
    }

    private func setupBinding() {
        authType.userInfo
            .subscribe(onNext: { [weak self] userInfo in
                guard let strongSelf = self else { return }
                strongSelf.userInfo = userInfo
                strongSelf.setupUserInfo()
            })
            .disposed(by: disposeBag)
    }

    private func setupUserInfo() {
        guard let userInfo = userInfo else { return }
        if let userName = userInfo.name {
            // ユーザー名がある(メールとパスワードによるログイン中)
            userNameLabelRelay.accept(userName)
            isHiddenSignupButtonRelay.accept(true)
            isHiddenAccountEnterButtonRelay.accept(true)
        } else {
            // ユーザー名がない(匿名認証によるログイン中)
            userNameLabelRelay.accept("未登録")
            accountEnterButtonTitleRelay.accept("ログイン")
            isHiddenSignupButtonRelay.accept(false)
            isHiddenAccountEnterButtonRelay.accept(false)
        }
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

    var isHiddenAccountEnterButton: Driver<Bool> {
        isHiddenAccountEnterButtonRelay.asDriver(onErrorDriveWith: .empty())
    }

    var isOnPasscode: Driver<Bool> {
        isOnPasscodeRelay.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapAccountEnterButton() {
        eventRelay.accept(.presentLogin)
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
        let shareText = "私の家計簿！"
        guard let shareUrl = NSURL(string: "https://apps.apple.com/jp/app/apple-store/id\(appId)") else { return }
        let activityItems = [shareText, shareUrl] as [Any]
        eventRelay.accept(.presentActivityVC(activityItems))
    }

    func didTapReviewButton() {
        guard let url =
                URL(string: "https://apps.apple.com/jp/app/apple-store/id\(appId)?action=write-review")
        else { return }
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
