//
//  PasscodeRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/30.
//

import Foundation

protocol PasscodeDataRepositoryProtocol {
    func loadPasscode() -> Int
    func savePasscode(passcode: Int)
}

protocol IsOnPasscodeRepositoryProtocol {
    func loadIsOnPasscode() -> Bool
    func saveIsOnPasscode(isOnPasscode: Bool)
}

final class PasscodeRepository:
    PasscodeDataRepositoryProtocol,IsOnPasscodeRepositoryProtocol {

    private let userDefaults = UserDefaults.standard
    private let passcodeDataKey = "passcode"
    private let isOnPasscodeKey = "isOnPasscode"

    func loadPasscode() -> Int {
        return userDefaults.integer(forKey: passcodeDataKey)
    }

    func savePasscode(passcode: Int) {
        userDefaults.set(passcode, forKey: passcodeDataKey)
    }

    func loadIsOnPasscode() -> Bool {
        return userDefaults.bool(forKey: isOnPasscodeKey)
    }

    func saveIsOnPasscode(isOnPasscode: Bool) {
        userDefaults.set(isOnPasscode, forKey: isOnPasscodeKey)
    }
}
