//
//  PasscodeViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/30.
//

import RxSwift
import RxCocoa

protocol PasscodeViewModelInput {
    func didTapNumberButton(tapNumber: String)
    func didTapDeleteButton()
}

protocol PasscodeViewModelOutput {
    var navigationTitle: Driver<String> { get }
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

        enum Times {
            case first
            case second
        }

        var message: String {
            switch self {
            case .create(let times):
                switch times {
                case .first:
                    return "パスコードを入力"
                case .second:
                    return "新しいパスコードを確認"
                }
            case .unlock:
                return "パスコードを入力"
            }
        }

        var navigationTitle: String {
            switch self {
            case .create(_):
                return "パスコードを設定"
            case .unlock:
                return ""
            }
        }
    }

    enum Event {
    }

    enum KeyState {
        case off
        case oneOn
        case twoOn
        case threeOn
    }

    private let mode: Mode
    private var keyState: KeyState = .off
    private let navigationTitleRelay = BehaviorRelay<String>(value: "")
    private let messageLabelTextRelay = BehaviorRelay<String>(value: "")
    private let firstKeyAlphaRelay = PublishRelay<CGFloat>()
    private let secondKeyAlphaRelay = PublishRelay<CGFloat>()
    private let thirdKeyAlphaRelay = PublishRelay<CGFloat>()
    private let fourthKeyAlphayRelay = PublishRelay<CGFloat>()
    private let eventRelay = PublishRelay<Event>()

    init(mode: Mode) {
        self.mode = mode
        messageLabelTextRelay.accept(mode.message)
        navigationTitleRelay.accept(mode.navigationTitle)
    }

    var navigationTitle: Driver<String> {
        navigationTitleRelay.asDriver(onErrorDriveWith: .empty())
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

    func didTapNumberButton(tapNumber: String) {
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
            // keyState仮実装
            keyState = .off
            firstKeyAlphaRelay.accept(0.5)
            secondKeyAlphaRelay.accept(0.5)
            thirdKeyAlphaRelay.accept(0.5)
            fourthKeyAlphayRelay.accept(0.5)
        }
    }

    func didTapDeleteButton() {
        switch keyState {
        case .off:
            break
        case .oneOn:
            firstKeyAlphaRelay.accept(0.5)
            keyState = .off
        case .twoOn:
            secondKeyAlphaRelay.accept(0.5)
            keyState = .oneOn
        case .threeOn:
            thirdKeyAlphaRelay.accept(0.5)
            keyState = .twoOn
        }
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
