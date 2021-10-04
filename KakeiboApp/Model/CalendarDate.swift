//
//  CalendarDate.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/28.
//

import RxSwift
import RxRelay

protocol CalendarDateProtocol {
    var calendarDate: Observable<[Date]> { get } // calendarの日付
    var monthDate: Observable<[Date]> { get } // 月の日付
    var navigationTitle: Observable<String> { get } // title(〇〇年〇〇月)
    func nextMonth()
    func lastMonth()
}

class CalendarDate: CalendarDateProtocol {

    private let calendarDateRelay = BehaviorRelay<[Date]>(value: [])
    private let monthDateRelay = BehaviorRelay<[Date]>(value: [])
    private let navigationTitleRelay = BehaviorRelay<String>(value: "")
    private let carendar = Calendar(identifier: .gregorian)
    private var firstDay: Date!

    init() {
        let component = carendar.dateComponents([.year, .month], from: Date())
        guard let firstDay = carendar.date(
            from: DateComponents(year: component.year, month: component.month, day: 1)
        ) else { return }
        self.firstDay = firstDay
        acceptDateArray()
        acceptNavigationTitle()
    }

    var calendarDate: Observable<[Date]> {
           calendarDateRelay.asObservable()
       }

    var monthDate: Observable<[Date]> {
        monthDateRelay.asObservable()
    }

    var navigationTitle: Observable<String> {
        navigationTitleRelay.asObservable()
    }

    // TODO: firstDayに依存
    private func acceptDateArray() {
        // 月の最初の曜日
        let firstWeekday = carendar.component(.weekday, from: firstDay)
        // 月の週の数
        guard let numberOfWeeks = carendar.range(
            of: .weekOfMonth, in: .month, for: firstDay
        ) else { return }
        // カレンダーに表示するItemの数
        let numberOfItems = numberOfWeeks.count * 7

        let calendarDateArray: [Date] = (1...numberOfItems).map { num in
            var dateComponents = DateComponents()
            dateComponents.day = num - firstWeekday
            return carendar.date(byAdding: dateComponents, to: firstDay)!
        }
        calendarDateRelay.accept(calendarDateArray)

        let monthDateArray: [Date] = calendarDateArray.filter {
            Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0, toGranularity: .year)
                && Calendar(identifier: .gregorian)
                .isDate(firstDay, equalTo: $0, toGranularity: .month)
        }
        monthDateRelay.accept(monthDateArray)
    }

    // TODO: firstDayに依存
    private func acceptNavigationTitle() {
        let navigationTitle = DateUtility.stringFromDate(date: firstDay, format: "YYYY年MM月")
        navigationTitleRelay.accept(navigationTitle)
    }

    func nextMonth() {
        guard let firstDay = carendar.date(
            byAdding: .month, value: 1, to: firstDay
        ) else { return }
        self.firstDay = firstDay
        acceptDateArray()
        acceptNavigationTitle()
    }

    func lastMonth() {
        guard let firstDay = carendar.date(
                byAdding: .month, value: -1, to: firstDay
        ) else { return }
        self.firstDay = firstDay
        acceptDateArray()
        acceptNavigationTitle()
    }
}
