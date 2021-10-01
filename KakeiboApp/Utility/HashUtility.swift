//
//  HashUtility.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/01.
//

import Foundation
import CryptoKit

struct HashUtility {
    static func sha256Hash(_ passcode: String) -> Int {
        let data = passcode.data(using: .utf8)
        let sha256 = SHA256.hash(data: data!)
        return sha256.hashValue
    }
}
