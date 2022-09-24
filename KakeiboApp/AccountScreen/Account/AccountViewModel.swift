//
//  AccountViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import RxSwift
import RxCocoa

protocol AccountViewModelInput {
    func onViewWillAppear()
    func didTapAccountEnterButton()
    func didTapAuthButton()
    func didValueChangedPasscodeSwitch(value: Bool)
    func didTapCategoryEditButton()
    func didTapHowtoUseButton()
    func didTapShareButton()
    func didTapReviewButton()
}

protocol AccountViewModelOutput {
    var userNameLabel: Driver<String> { get }
    var accountEnterButtonTitle: Driver<String> { get }
    var authButtonTitle: Driver<String> { get }
    var isHiddenAuthButton: Driver<Bool> { get }
    var isHiddenAccountEnterButton: Driver<Bool> { get }
    var isOnPasscode: Driver<Bool> { get }
    var isAnimatedIndicator: Driver<Bool> { get }
    var event: Driver<AccountViewModel.Event> { get }
}

protocol AccountViewModelType {
    var inputs: AccountViewModelInput { get }
    var outputs: AccountViewModelOutput { get }
}

final class AccountViewModel: AccountViewModelInput, AccountViewModelOutput {
    enum Event {
        case pushLogin
        case pushRegister
        case presentPasscodeVC
        case pushCategoryEditVC
        case pushHowToVC
        case presentActivityVC([Any])
        case applicationSharedOpen(URL)
        case showDestructiveAlert(title: String, message: String?, destructiveTitle: String, onDestructive: (() -> Void)? = nil)
        case showAlert(title: String, message: String?)
        case showErrorAlert
    }

    private var settingsRepository: SettingsRepositoryProtocol
    private let authType: AuthTypeProtocol
    private let disposeBag = DisposeBag()
    private let userNameLabelRelay = PublishRelay<String>()
    private let accountEnterButtonTitleRelay = PublishRelay<String>()
    private let authButtonTitleRelay = PublishRelay<String>()
    private let isHiddenAuthButtonRelay = PublishRelay<Bool>()
    private let isHiddenAccountEnterButtonRelay = PublishRelay<Bool>()
    private let isOnPasscodeRelay = PublishRelay<Bool>()
    private let isAnimatedIndicatorRelay = PublishRelay<Bool>()
    private let eventRelay = PublishRelay<Event>()
    private let appId = "1571086397"

    init(settingsRepository: SettingsRepositoryProtocol = SettingsRepository(),
         authType: AuthTypeProtocol = ModelLocator.shared.authType) {
        self.settingsRepository = settingsRepository
        self.authType = authType
        setupBinding()
    }

    private func setupBinding() {
        EventBus.updatedUserInfo.asObservable()
            .subscribe { [weak self] _ in
                self?.setupUserInfo()
            }
            .disposed(by: disposeBag)
    }

    private func setupUserInfo() {
        guard let userInfo = authType.userInfo else {
            userNameLabelRelay.accept(R.string.localizable.userNameUnregistered())
            accountEnterButtonTitleRelay.accept(R.string.localizable.login())
            authButtonTitleRelay.accept(R.string.localizable.signup())
            isHiddenAuthButtonRelay.accept(false)
            isHiddenAccountEnterButtonRelay.accept(false)
            return
        }
        if userInfo.isAnonymous {
            //　匿名認証によるログイン中
            userNameLabelRelay.accept(R.string.localizable.userNameUnregistered())
            accountEnterButtonTitleRelay.accept(R.string.localizable.login())
            authButtonTitleRelay.accept(R.string.localizable.signup())
            isHiddenAuthButtonRelay.accept(false)
            isHiddenAccountEnterButtonRelay.accept(false)
        } else {
            // メールとパスワードによるログイン中
            userNameLabelRelay.accept(userInfo.name ?? R.string.localizable.userNameUnset())
            authButtonTitleRelay.accept(R.string.localizable.accountDelete())
            isHiddenAuthButtonRelay.accept(false)
            isHiddenAccountEnterButtonRelay.accept(true)
        }
    }

    var userNameLabel: Driver<String> {
        userNameLabelRelay.asDriver(onErrorDriveWith: .empty())
    }

    var accountEnterButtonTitle: Driver<String> {
        accountEnterButtonTitleRelay.asDriver(onErrorDriveWith: .empty())
    }

    var authButtonTitle: Driver<String> {
        authButtonTitleRelay.asDriver(onErrorDriveWith: .empty())
    }

    var isHiddenAuthButton: Driver<Bool> {
        isHiddenAuthButtonRelay.asDriver(onErrorDriveWith: .empty())
    }

    var isHiddenAccountEnterButton: Driver<Bool> {
        isHiddenAccountEnterButtonRelay.asDriver(onErrorDriveWith: .empty())
    }

    var isOnPasscode: Driver<Bool> {
        isOnPasscodeRelay.asDriver(onErrorDriveWith: .empty())
    }

    var isAnimatedIndicator: Driver<Bool> {
        isAnimatedIndicatorRelay.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func onViewWillAppear() {
        isOnPasscodeRelay.accept(settingsRepository.isOnPasscode)
        setupUserInfo()
    }

    func didTapAccountEnterButton() {
        eventRelay.accept(.pushLogin)
    }

    func didTapAuthButton() {
        guard let userInfo = authType.userInfo else { return }
        if userInfo.isAnonymous {
            //　匿名認証によるログイン中
            eventRelay.accept(.pushRegister)
        } else {
            // メールとパスワードによるログイン中
            eventRelay.accept(
                .showDestructiveAlert(
                    title: R.string.localizable.accountDeleteTitle(),
                    message: R.string.localizable.accountDeleteMessage(),
                    destructiveTitle: R.string.localizable.delete(),
                    onDestructive: { [weak self] in
                        self?.accountDelete()
                    }
                )
            )
        }
    }

    func didValueChangedPasscodeSwitch(value: Bool) {
        settingsRepository.isOnPasscode = value
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
        let shareText = R.string.localizable.myKakeibo()
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

    private func accountDelete() {
        isAnimatedIndicatorRelay.accept(true)
        authType.accountDelete { [weak self] error in
            self?.isAnimatedIndicatorRelay.accept(false)
            if error != nil {
                self?.eventRelay.accept(.showErrorAlert)
            } else {
                self?.eventRelay.accept(.showAlert(title: R.string.localizable.completeAccountDelete(), message: nil))
            }
        }
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
