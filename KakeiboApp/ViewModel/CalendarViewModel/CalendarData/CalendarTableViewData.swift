//
//  TableViewData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import Foundation

struct HeaderDateKakeiboData {
    let date: Date // 日付
    let totalBalance: Int // totalの収支
}

struct CellDateKakeiboData {
    let category: Category // カテゴリー
    let balance: Balance // 収支
    let memo: String // メモ
}
