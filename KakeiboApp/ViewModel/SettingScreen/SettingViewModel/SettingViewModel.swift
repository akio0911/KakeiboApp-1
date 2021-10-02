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
}

protocol SettingViewModelOutput {
    var event: Driver<SettingViewModel.Event> { get }
}

protocol SettingViewModelType {
    var inputs: SettingViewModelInput { get }
    var outputs: SettingViewModelOutput { get }
}

final class SettingViewModel: SettingViewModelInput, SettingViewModelOutput {
    enum Event {
        case presentPasscodeVC
    }

    private let eventRelay = PublishRelay<Event>()

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didValueChangedPasscodeSwitch(value: Bool) {
        ModelLocator.shared.isOnPasscode = value
        if value {
            eventRelay.accept(.presentPasscodeVC)
        }
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
