//
//  IncomeAndExpenditure.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/30.
//

import Foundation

struct IncomeAndExpenditure: Equatable {
    
    let date: Date
    let category: String
    let expenses: Int
    let memo: String
    
    init(date: Date, category: String, expenses: Int, memo: String) {
        self.date = date
        self.category = category
        self.expenses = expenses
        self.memo = memo
    }
    
    init(from dictionary: [String : Any]) {
        self.date = dictionary["date"] as! Date
        self.category = dictionary["category"] as! String
        self.expenses = dictionary["expenses"] as! Int
        self.memo = dictionary["memo"] as! String
    }
}
