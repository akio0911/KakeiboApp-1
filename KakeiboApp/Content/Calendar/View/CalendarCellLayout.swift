//
//  CalendarCellLayout.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit

struct CalendarCellLayout {
    
    let WeekdayCellHeight: CGFloat = 20
    let daysCellHeight: CGFloat = 50
    let spaceOfCell:CGFloat = 1.3
    let insetForSection = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 10)
    let sixNumberOfWeeksHeight: CGFloat = 356.5
    let fiveNumberOfWeeksHeight: CGFloat = 305.2
    let fourNumberOfWeeksHeight: CGFloat = 253.9
    
    
    func expenses(date: Date, saveData: [IncomeAndExpenditure]) -> Int! {
        var expenses: Int!
        var total = 0
        for d in saveData {
            if date == d.date {
                total += d.expenses
                expenses = total
            }
        }
        return expenses
    }
}
