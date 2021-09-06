//
//  KakeiboData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

struct KakeiboData {
    let date: Date //　日付
    let category: Category // カテゴリー
    let balance: Balance // 収支
    let memo: String //　メモ
}

enum Balance: Equatable {
    case income(Int)
    case expense(Int)
}
// TODO: Categoryをここで実装する。stringやcolorは使用するViewModelでextensionとして実装し、ここでは書かない。
enum Category {
    case consumption
    case life
    case miscellaneous
    case transpotation
    case medical
    case communication
    case vehicleFee
    case entertainment
    case other
}
