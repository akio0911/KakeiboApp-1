//
//  SettingViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import RxSwift
import RxCocoa

protocol SettingViewModelInput {
    func didValueChangedPasscodeSwitch(value: Bool)
    func didTapCategoryEditButton()
}

protocol SettingViewModelOutput {
    var isOnPasscode: Driver<Bool> { get }
    var event: Driver<SettingViewModel.Event> { get }
}

protocol SettingViewModelType {
    var inputs: SettingViewModelInput { get }
    var outputs: SettingViewModelOutput { get }
}

final class SettingViewModel: SettingViewModelInput, SettingViewModelOutput {
    enum Event {
        case presentPasscodeVC
        case pushCategoryEditVC
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
}

extension SettingViewModel: SettingViewModelType {
    var inputs: SettingViewModelInput {
        return self
    }

    var outputs: SettingViewModelOutput {
        return self
    }
}
