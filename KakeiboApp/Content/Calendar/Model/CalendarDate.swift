//
//  CalendarDate.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/28.
//

import Foundation

protocol CalendarFrameDelegate: AnyObject {
    func calendarHeight(beforeNumberOfWeeks: Int, afterNumberOfWeeks: Int)
}

class CalendarDate {
    
    weak var delegate: CalendarFrameDelegate?
    
    private var days = [Date]()
    private let weekday = ["日", "月", "火", "水", "木", "金", "土"]
    private let carendar = Calendar(identifier: .gregorian)
    private(set) var numberOfWeeks: Int!

    private(set) var firstDay: Date! {
        didSet {
            let beforeNumberOfWeeks = numberOfWeeks
            days = setDays()
            if beforeNumberOfWeeks != numberOfWeeks {
                delegate?.calendarHeight(beforeNumberOfWeeks: beforeNumberOfWeeks!, afterNumberOfWeeks: numberOfWeeks)
            }
        }
    }
    
    init() {
        let component = carendar.dateComponents([.year, .month], from: Date())
        firstDay = carendar.date(from: DateComponents(year: component.year, month: component.month, day: 1))
        days = setDays()
    }
    
    private func setDays() -> [Date] {
        // 月の最初の曜日
        let firstWeekday = carendar.component(.weekday, from: firstDay)
        // 月の週の数
        let numberOfWeeks = carendar.range(of: .weekOfMonth, in: .month, for: firstDay)
        self.numberOfWeeks = numberOfWeeks?.count
        // カレンダーに表示するItemの数
        let numberOfItems = self.numberOfWeeks * 7
        
        return (1...numberOfItems).map { num in
            var dateComponents = DateComponents()
            dateComponents.day = num - firstWeekday
            return carendar.date(byAdding: dateComponents, to: firstDay)!
        }
    }
    
    func nextMonth() {
        days.removeAll()
        firstDay = carendar.date(byAdding: .month, value: 1, to: firstDay)
    }
    
    func lastMonth() {
        days.removeAll()
        firstDay = carendar.date(byAdding: .month, value: -1, to: firstDay)
    }

    /*UICollectionViewDataSourceのnumberOfItemsInSectionで呼ばれるメソッド
      曜日のセクションには曜日の数を、日付のセクションには日付の数を返す*/
    func countSectionItems(at section: Int) -> Int {
        section == 0 ? weekday.count : days.count
    }

    // 指定された曜日をString型で返す
    func presentWeekday(at index: Int) -> String {
        weekday[index]
    }

    // 曜日の数を返す
    func countWeekday() -> Int {
        weekday.count
    }

    // すでに設定されているfirstDayをString型で返す
    func convertStringFirstDay(dateFormat: String) -> String {
        firstDay.string(dateFormat: dateFormat)
    }

    // days配列から引数のindexで指定されたDateを返す
    func presentDate(at index: Int) -> Date {
        days[index]
    }
}
