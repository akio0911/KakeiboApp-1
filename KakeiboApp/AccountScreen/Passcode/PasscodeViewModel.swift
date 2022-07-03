//
//  PasscodeViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/30.
//

import RxSwift
import RxCocoa

protocol PasscodeViewModelInput {
    func onViewDidLoad()
    func didTapNumberButton(tapNumber: String)
    func didTapDeleteButton()
    func didTapCancelButton()
}

protocol PasscodeViewModelOutput {
    var navigationTitle: Driver<String> { get }
    var isSetupCancelBarButton: Driver<Bool> { get }
    var messageLabelText: Driver<String> { get }
    var firstKeyAlpha: Driver<CGFloat> { get }
    var secondKeyAlpha: Driver<CGFloat> { get }
    var thirdKeyAlpha: Driver<CGFloat> { get }
    var fourthKeyAlpha: Driver<CGFloat> { get }
    var event: Driver<PasscodeViewModel.Event> { get }
}

protocol PasscodeViewModelType {
    var inputs: PasscodeViewModelInput { get }
    var outputs: PasscodeViewModelOutput { get }
}

final class PasscodeViewModel: PasscodeViewModelInput, PasscodeViewModelOutput {
    enum Mode {
        case create(Times)
        case unlock

        var message: String {
            switch self {
            case .create(let times):
                switch times {
                case .first:
                    return R.string.localizable.passcodeEntry()
                case .second(_):
                    return R.string.localizable.newPasscodeValidation()
                }
            case .unlock:
                return R.string.localizable.passcodeEntry()
            }
        }

        var navigationTitle: String {
            switch self {
            case .create(_):
                return R.string.localizable.passcodeSetting()
            case .unlock:
                return ""
            }
        }

        var isSetupCancelBarButton: Bool {
            switch self {
            case .create(_):
                return true
            case .unlock:
                return false
            }
        }
    }

    enum Times {
        case first
        case second([String]) // String型の配列にはfirstで設定したpasscodeが入る
    }

    enum Event {
        case dismiss
        case pushPasscodeVC([String])
        case popViewController
        case keyImageStackViewAnimation
    }

    enum KeyState {
        case off
        case oneOn
        case twoOn
        case threeOn
    }

    private let mode: Mode
    private var settingsRepository: SettingsRepositoryProtocol
    private var passcodeArray: [String] = [] // パスコード
    private var keyState: KeyState = .off
    private let navigationTitleRelay = PublishRelay<String>()
    private let isSetupCancelBarButtonRelay = PublishRelay<Bool>()
    private let messageLabelTextRelay = PublishRelay<String>()
    private let firstKeyAlphaRelay = PublishRelay<CGFloat>()
    private let secondKeyAlphaRelay = PublishRelay<CGFloat>()
    private let thirdKeyAlphaRelay = PublishRelay<CGFloat>()
    private let fourthKeyAlphayRelay = PublishRelay<CGFloat>()
    private let eventRelay = PublishRelay<Event>()

    init(mode: Mode,
         settingsRepository: SettingsRepositoryProtocol = SettingsRepository()) {
        self.mode = mode
        self.settingsRepository = settingsRepository
    }

    var navigationTitle: Driver<String> {
        navigationTitleRelay.asDriver(onErrorDriveWith: .empty())
    }

    var isSetupCancelBarButton: Driver<Bool> {
        isSetupCancelBarButtonRelay.asDriver(onErrorDriveWith: .empty())
    }

    var messageLabelText: Driver<String> {
        messageLabelTextRelay.asDriver(onErrorDriveWith: .empty())
    }

    var firstKeyAlpha: Driver<CGFloat> {
        firstKeyAlphaRelay.asDriver(onErrorDriveWith: .empty())
    }

    var secondKeyAlpha: Driver<CGFloat> {
        secondKeyAlphaRelay.asDriver(onErrorDriveWith: .empty())
    }

    var thirdKeyAlpha: Driver<CGFloat> {
        thirdKeyAlphaRelay.asDriver(onErrorDriveWith: .empty())
    }

    var fourthKeyAlpha: Driver<CGFloat> {
        fourthKeyAlphayRelay.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func onViewDidLoad() {
        messageLabelTextRelay.accept(mode.message)
        navigationTitleRelay.accept(mode.navigationTitle)
        isSetupCancelBarButtonRelay.accept(mode.isSetupCancelBarButton)
    }

    func didTapNumberButton(tapNumber: String) {
        passcodeArray.append(tapNumber)
        switch keyState {
        case .off:
            firstKeyAlphaRelay.accept(1)
            keyState = .oneOn
        case .oneOn:
            secondKeyAlphaRelay.accept(1)
            keyState = .twoOn
        case .twoOn:
            thirdKeyAlphaRelay.accept(1)
            keyState = .threeOn
        case .threeOn:
            fourthKeyAlphayRelay.accept(1)
            acceptEvent(mode: mode)
        }
    }

    private func acceptEvent(mode: Mode) {
        switch mode {
        case .create(let times):
            switch times {
            case .first:
                eventRelay.accept(.pushPasscodeVC(passcodeArray))
                keyState = .off
                firstKeyAlphaRelay.accept(0.5)
                secondKeyAlphaRelay.accept(0.5)
                thirdKeyAlphaRelay.accept(0.5)
                fourthKeyAlphayRelay.accept(0.5)
                passcodeArray.removeAll()
            case .second(let firstPasscodeArray):
                if firstPasscodeArray == passcodeArray {
                    var passcode: String = ""
                    passcodeArray.forEach { passcode += $0 }
                    settingsRepository.passcode = passcode
                    eventRelay.accept(.dismiss)
                } else {
                    eventRelay.accept(.popViewController)
                }
            }
        case .unlock:
            let passcodeData = settingsRepository.passcode
            var passcode: String = ""
            self.passcodeArray.forEach { passcode += $0 }
            if passcode == passcodeData {
                eventRelay.accept(.dismiss)
            } else {
                eventRelay.accept(.keyImageStackViewAnimation)
                keyState = .off
                firstKeyAlphaRelay.accept(0.5)
                secondKeyAlphaRelay.accept(0.5)
                thirdKeyAlphaRelay.accept(0.5)
                fourthKeyAlphayRelay.accept(0.5)
                self.passcodeArray.removeAll()
            }
        }
    }

    func didTapDeleteButton() {
        switch keyState {
        case .off:
            break
        case .oneOn:
            passcodeArray.removeLast()
            firstKeyAlphaRelay.accept(0.5)
            keyState = .off
        case .twoOn:
            passcodeArray.removeLast()
            secondKeyAlphaRelay.accept(0.5)
            keyState = .oneOn
        case .threeOn:
            passcodeArray.removeLast()
            thirdKeyAlphaRelay.accept(0.5)
            keyState = .twoOn
        }
    }

    func didTapCancelButton() {
        eventRelay.accept(.dismiss)
        settingsRepository.isOnPasscode = false
    }
}

// MARK: - PasscodeViewModelType
extension PasscodeViewModel: PasscodeViewModelType {
    var inputs: PasscodeViewModelInput {
        return self
    }

    var outputs: PasscodeViewModelOutput {
        return self
    }
}
