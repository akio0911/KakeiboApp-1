//
//  CategoryInfo.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/11.
//

import Foundation

struct CategoryInfo {
    var graphArray: [CategoryGraphInfo] = []
    var listIncomeArray: [CategoryListInfo] = []
    var listExpensesArray: [CategoryListInfo] = []
    
    func setArray(data: [IncomeAndExpenditure], firstDay: Date) {
        let monthData = data.filter{
            $0.date.string(dateFormat: "MM") == firstDay.string(dateFormat: "MM")
        }
        
        
    }
}
