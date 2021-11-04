//
//  ExtensionArray.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/11/04.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
