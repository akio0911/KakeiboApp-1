//
//  CalendarCollectionViewDataSource.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import UIKit
import RxSwift
import RxCocoa

final class CalendarCollectionViewDataSource: NSObject,
                                              UICollectionViewDataSource,
                                              RxCollectionViewDataSourceType {
    typealias Element = [CalendarItem]
    private var items: Element = []
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard !items.isEmpty else { return 0 }
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return weekdays.count
        case 1:
            return items.count
        default:
            fatalError("collectionViewで想定していないsection")
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarWeekdayCollectionViewCell.identifier,
                for: indexPath
            ) as! CalendarWeekdayCollectionViewCell // swiftlint:disable:this force_cast
            cell.configure(
                weekday: weekdays[indexPath.row],
                at: indexPath.row
            )
            cell.backgroundColor = UIColor.systemGray4
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarDayCollectionViewCell.identifier,
                for: indexPath
            ) as! CalendarDayCollectionViewCell // swiftlint:disable:this force_cast
            let calendarItem = items[indexPath.row]
            cell.configure(
                calendarItem: calendarItem,
                index: indexPath.row
            )
            if calendarItem.isCalendarMonth {
                cell.backgroundColor = .white
            } else {
                cell.backgroundColor = .systemGray6
            }
            let highlightView = UIView(frame: cell.frame)
            highlightView.backgroundColor = UIColor(named: CalendarColorName.seashell.rawValue)
            cell.selectedBackgroundView = highlightView
            // 日付が今日の場合、cellをハイライト表示する
            if Calendar(identifier: .gregorian).isDate(calendarItem.date, equalTo: Date(), toGranularity: .day) {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            }
            return cell
        default:
            fatalError("collectionViewで想定していないsection")
        }
    }

    // MARK: - RxCollectionViewDataSourceType
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[CalendarItem]>) {
        Binder(self) { dataSource, element in
            dataSource.items = element
            collectionView.reloadData()
        }
        .on(observedEvent)
    }
}
