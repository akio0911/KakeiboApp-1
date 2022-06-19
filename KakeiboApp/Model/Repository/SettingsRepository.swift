//
//  PasscodeRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/30.
//

import Foundation

enum SettingKeys: String {
    case passcode
    case isOnPasscode
}

final class SettingsRepository: SettingsRepositoryProtocol {
    private let userDefaults = UserDefaults.standard

    var passcode: String? {
        get {
            return userDefaults.string(forKey: SettingKeys.passcode.rawValue)
        }
        set(value) {
            userDefaults.set(value, forKey: SettingKeys.passcode.rawValue)
        }
    }

    var isOnPasscode: Bool {
        get {
            userDefaults.bool(forKey: SettingKeys.isOnPasscode.rawValue)
        }
        set(value) {
            userDefaults.set(value, forKey: SettingKeys.isOnPasscode.rawValue)
        }
    }
}

protocol SettingsRepositoryProtocol {
    var passcode: String? { get set }
    var isOnPasscode: Bool { get set }
}
