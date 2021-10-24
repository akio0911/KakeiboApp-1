//
//  AccountViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import RxSwift
import RxCocoa

protocol AccountViewModelInput {
    func didValueChangedPasscodeSwitch(value: Bool)
    func didTapCategoryEditButton()
    func didTapHowtoUseButton()
    func didTapShareButton()
    func didTapReviewButton()
}

protocol AccountViewModelOutput {
    var isOnPasscode: Driver<Bool> { get }
    var event: Driver<AccountViewModel.Event> { get }
}

protocol AccountViewModelType {
    var inputs: AccountViewModelInput { get }
    var outputs: AccountViewModelOutput { get }
}

final class AccountViewModel: AccountViewModelInput, AccountViewModelOutput {
    enum Event {
        case presentPasscodeVC
        case pushCategoryEditVC
        case pushHowToVC
        case presentActivityVC([Any])
        case applicationSharedOpen(URL)
    }

    private let passcodeRepository: IsOnPasscodeRepositoryProtocol
    private let isOnPasscodeRelay = BehaviorRelay<Bool>(value: false)
    private let eventRelay = PublishRelay<Event>()

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

    var isOnPasscode: Driver<Bool> {
        isOnPasscodeRelay.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
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
