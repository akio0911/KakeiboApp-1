//
//  ExtensionUserDefaults.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/31.
//

import Foundation

extension UserDefaults {

    func removeAll() {
        dictionaryRepresentation().forEach { removeObject(forKey: $0.key) }
    }
}
