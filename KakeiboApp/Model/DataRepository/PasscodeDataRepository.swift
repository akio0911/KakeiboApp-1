//
//  PasscodeDataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/30.
//

import Foundation

protocol PasscodeDataRepositoryProtocol {
    func load() -> Int
    func save(passcode: Int)
}

final class PasscodeDataRepository: PasscodeDataRepositoryProtocol {

    private let userDefaults = UserDefaults.standard
    private let passcodeDataKey = "passcode"

    func load() -> Int {
        return userDefaults.integer(forKey: passcodeDataKey)
    }

    func save(passcode: Int) {
        userDefaults.set(passcode, forKey: passcodeDataKey)
    }
}
