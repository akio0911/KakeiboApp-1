//
//  CalendarCellLayout.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit

struct CalendarCellLayout {
    
    let weekdayCellHeight: CGFloat = 20 // 週を表示するセルの高さ
    let daysCellHeight: CGFloat = 50 // 日付を表示するセルの高さ
    let spaceOfCell:CGFloat = 1.3 // セルの間隔
    let insetForSection = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 10)

    var sixWeeksHeight: CGFloat {
        calcCalendarHeight(weeksNumber: 6)
    }
    var fiveWeeksHeight: CGFloat {
        calcCalendarHeight(weeksNumber: 5)
    }
    var fourWeeksHeight: CGFloat {
        calcCalendarHeight(weeksNumber: 4)
    }
    
//    // セーブデータから日付が一致する収支を合計
//    func calcDateExpenses(date: Date, saveData: [IncomeAndExpenditure]) -> Int? {
//        var dateExpenses: Int? = nil
//        let filteredData = saveData.filter { $0.date == date }
//        if filteredData != [] {
//            dateExpenses = filteredData.reduce(0) { $0 + $1.expenses }
//        }
//        return dateExpenses
//    }

    // 週の数からカレンダーの高さを計算
    private func calcCalendarHeight(weeksNumber: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        height += weekdayCellHeight
            + daysCellHeight * weeksNumber
            + spaceOfCell * (weeksNumber - 1)
            + (insetForSection.top * 2)
            + (insetForSection.bottom * 2)
        return height
    }
}
