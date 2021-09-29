//
//  TableViewData.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/18.
//

import Foundation

struct HeaderDateCategoryData {
    let date: Date // 日付
    let totalBalance: Int //
}

struct CellDateCategoryData {
    let balance: Balance // 収支
    let memo: String // メモ
}