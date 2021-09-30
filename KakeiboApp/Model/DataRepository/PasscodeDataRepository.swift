//
//  PasscodeDataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/30.
//

import Foundation

protocol PasscodeDataRepositoryProtocol {
    func load() -> String
    func save(passcode: String)
}

final class PasscodeDataRepository: PasscodeDataRepositoryProtocol {

    private let userDefaults = UserDefaults.standard
    private let passcodeDataKey = "passcode"

    func load() -> String {
        if let passcode = userDefaults.string(forKey: passcodeDataKey) {
            return passcode
        } else {
            fatalError("passcode読み込みに失敗しました。")
        }
    }

    func save(passcode: String) {
        userDefaults.set(passcode, forKey: passcodeDataKey)
    }
}
