//
//  ExrensionArray.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/05.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        //indexが配列内なら要素を返し、配列外ならnilを返す（三項演算子）
        return indices.contains(index) ? self[index] : nil
    }
}
