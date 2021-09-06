//
//  CalendarDate.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/28.
//

import RxSwift
import RxRelay

protocol CalendarDateProtocol {
    var collectionViewDateArray: Observable<[Date]> { get } // calendarに表示する日付
    var tableViewDateArray: Observable<[Date]> { get } // titleに表示される月の日付
    var navigationTitle: Observable<String> { get } // titleの表示(〇〇年〇〇月を表示)
    func nextMonth()
    func lastMonth()
}

class CalendarDate: CalendarDateProtocol {

    private let collectionViewDateRelay = BehaviorRelay<[Date]>(value: [])
    private let tableViewDateRelay = BehaviorRelay<[Date]>(value: [])
    private let navigationTitleRelay = BehaviorRelay<String>(value: "")
    private let carendar = Calendar(identifier: .gregorian)
    // TODO: エラーが出たため強制オプショナルアンラップ
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

    var collectionViewDateArray: Observable<[Date]> {
           collectionViewDateRelay.asObservable()
       }

    var tableViewDateArray: Observable<[Date]> {
        tableViewDateRelay.asObservable()
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

        let collectionViewDateArray: [Date] = (1...numberOfItems).map { num in
            var dateComponents = DateComponents()
            dateComponents.day = num - firstWeekday
            return carendar.date(byAdding: dateComponents, to: firstDay)!
        }
        collectionViewDateRelay.accept(collectionViewDateArray)

        let tableViewDateArray: [Date] = (1...numberOfItems).map { num in
            var dateComponents = DateComponents()
            dateComponents.day = num
            return carendar.date(byAdding: dateComponents, to: firstDay)!
        }
        tableViewDateRelay.accept(tableViewDateArray)
    }

    // TODO: firstDayに依存
    private func acceptNavigationTitle() {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY年MM月"
        let navigationTitle = dateformatter.string(from: firstDay)
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

    /*UICollectionViewDataSourceのnumberOfItemsInSectionで呼ばれるメソッド
      曜日のセクションには曜日の数を、日付のセクションには日付の数を返す*/
//    func countSectionItems(at section: Int) -> Int {
//        section == 0 ? weekday.count : days.count
//    }

    // 指定された曜日をString型で返す
//    func presentWeekday(at index: Int) -> String {
//        weekday[index]
//    }

    // 曜日の数を返す
//    func countWeekday() -> Int {
//        weekday.count
//    }

    // すでに設定されているfirstDayをString型で返す
//    func convertStringFirstDay(dateFormat: String) -> String {
//        firstDay.string(dateFormat: dateFormat)
//    }

    // days配列から引数のindexで指定されたDateを返す
//    func presentDate(at index: Int) -> Date {
//        days[index]
//    }
}
