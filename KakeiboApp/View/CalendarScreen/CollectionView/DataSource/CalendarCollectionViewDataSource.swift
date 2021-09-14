//
//  CalendarCollectionViewDataSource.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import UIKit
import RxSwift
import RxCocoa

final class CalendarCollectionViewDataSource: NSObject, UICollectionViewDataSource, RxCollectionViewDataSourceType {

    typealias Element = [DayItemData]
    private var items: Element = []
    private let weekdayItemData = WeekdayItemData()

    // MARK: - UICollectionViewDataSource
    // TODO: numberOfSectionsのreturnがマジックナンバーになっている
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch items.count {
        case 0:
            return 0
        default:
            return 2 // 曜日Sectionと日にちSection
        }
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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarWeekdayCollectionViewCell.identifier,
                for: indexPath
            ) as! CalendarWeekdayCollectionViewCell
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
            ) as! CalendarDayCollectionViewCell
            cell.configure(
                data: items[indexPath.row],
                index: indexPath.row
            )
            if items[indexPath.row].isCalendarMonth {
                cell.backgroundColor = .white
            } else {
                cell.backgroundColor = .systemGray6
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
