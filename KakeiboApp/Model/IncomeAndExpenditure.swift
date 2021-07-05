//
//  IncomeAndExpenditure.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/30.
//

import Foundation

struct IncomeAndExpenditure: Equatable, Codable {

    let date: Date //　収支の日付
    let category: Category // 収支の分類
    let expenses: Int // 収支の費用
    let memo: String // 収支についてのメモ
}
