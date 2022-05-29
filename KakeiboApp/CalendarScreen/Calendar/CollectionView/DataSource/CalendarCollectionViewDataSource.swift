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
    typealias Element = [DayItemData]
    private var items: Element = []
    private let weekdayItemData = WeekdayItemData()

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard !items.isEmpty else { return 0 }
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return weekdayItemData.weekdays.count
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
                weekday: weekdayItemData.weekdays[indexPath.row],
                at: indexPath.row
            )
            cell.backgroundColor = UIColor.systemGray4
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarDayCollectionViewCell.identifier,
                for: indexPath
            ) as! CalendarDayCollectionViewCell // swiftlint:disable:this force_cast
            let data = items[indexPath.row]
            cell.configure(
                data: data,
                index: indexPath.row
            )
            if data.isCalendarMonth {
                cell.backgroundColor = .white
            } else {
                cell.backgroundColor = .systemGray6
            }
            let highlightView = UIView(frame: cell.frame)
            highlightView.backgroundColor = UIColor(named: CalendarColorName.seashell.rawValue)
            cell.selectedBackgroundView = highlightView
            // 日付が今日の場合、cellをハイライト表示する
            if Calendar(identifier: .gregorian).isDate(data.date, equalTo: Date(), toGranularity: .day) {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            }
            return cell
        default:
            fatalError("collectionViewで想定していないsection")
        }
    }

    // MARK: - RxCollectionViewDataSourceType
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[DayItemData]>) {
        Binder(self) { dataSource, element in
            dataSource.items = element
            collectionView.reloadData()
        }
        .on(observedEvent)
    }
}
