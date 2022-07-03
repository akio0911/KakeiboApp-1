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
        case pushLogin
        case pushRegister
        case presentPasscodeVC
        case pushCategoryEditVC
        case pushHowToVC
        case presentActivityVC([Any])
        case applicationSharedOpen(URL)
    }

    private var settingsRepository: SettingsRepositoryProtocol
    private let authType: AuthTypeProtocol
    private let disposeBag = DisposeBag()
    private let userNameLabelRelay = PublishRelay<String>()
    private let accountEnterButtonTitleRelay = PublishRelay<String>()
    private let isHiddenSignupButtonRelay = PublishRelay<Bool>()
    private let isHiddenAccountEnterButtonRelay = PublishRelay<Bool>()
    private let isOnPasscodeRelay = PublishRelay<Bool>()
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
        guard let userInfo = authType.userInfo else { return }
        if userInfo.isAnonymous {
            //　匿名認証によるログイン中
            userNameLabelRelay.accept(R.string.localizable.userNameUnregistered())
            accountEnterButtonTitleRelay.accept(R.string.localizable.login())
            isHiddenSignupButtonRelay.accept(false)
            isHiddenAccountEnterButtonRelay.accept(false)
        } else {
            // メールとパスワードによるログイン中
            userNameLabelRelay.accept(userInfo.name ?? R.string.localizable.userNameUnset())
            isHiddenSignupButtonRelay.accept(true)
            isHiddenAccountEnterButtonRelay.accept(true)
        }
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

    func onViewWillAppear() {
        isOnPasscodeRelay.accept(settingsRepository.isOnPasscode)
        setupUserInfo()
    }

    func didTapAccountEnterButton() {
        eventRelay.accept(.pushLogin)
    }

    func didTapSignupButton() {
        eventRelay.accept(.pushRegister)
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
}

extension AccountViewModel: AccountViewModelType {
    var inputs: AccountViewModelInput {
        return self
    }

    var outputs: AccountViewModelOutput {
        return self
    }
}
