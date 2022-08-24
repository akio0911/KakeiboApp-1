//
//  CardCollectionViewCell.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2022/06/23.
//

import UIKit

protocol CardCollectionViewCellDelegate: AnyObject {
    func didSelectItemAt(calendarItem: CalendarItem)
}

final class CardCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var calendarCollectionView: UICollectionView!

    weak var delegate: CardCollectionViewCellDelegate?

    private var displayDate: Date = Date()
    private var selectedItem: CalendarItem?
    private var items: [CalendarItem] = []
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
    private let weekdayCellHeight: CGFloat = 23 // 週のセルの高さ
    private let dayCellHeight: CGFloat = 46 // 日付のセルの高さ
    private let numberOfDaysInWeek: CGFloat = 7 // 1週間の日数
    private let insetForSection = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        setupCardLayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = CGPath(rect: self.bounds, transform: nil)
    }

    func configure(displayDate: Date, selectedItem: CalendarItem?, items: [CalendarItem]) {
        self.displayDate = displayDate
        self.selectedItem = selectedItem
        self.items = items
        calendarCollectionView.reloadData()
    }

    func reloadSelectedItem(selectedItem: CalendarItem) {
        self.selectedItem = selectedItem
        // 選択されているItemを未選択にする
        if let selectedItemIndexPaths = calendarCollectionView.indexPathsForSelectedItems {
            selectedItemIndexPaths.forEach { indexPath in
                calendarCollectionView.deselectItem(at: indexPath, animated: false)
            }
        }
        // 表示Itemに同じ日付があれば選択状態にする
        if let index = items.firstIndex(where: { $0.date == selectedItem.date }) {
            calendarCollectionView.selectItem(
                at: IndexPath(row: index, section: 1),
                animated: false,
                scrollPosition: .top
            )
        }
    }

    private func setupCollectionView() {
        calendarCollectionView.register(
            CalendarWeekdayCollectionViewCell.nib,
            forCellWithReuseIdentifier: CalendarWeekdayCollectionViewCell.identifier
        )
        calendarCollectionView.register(
            CalendarDayCollectionViewCell.nib,
            forCellWithReuseIdentifier: CalendarDayCollectionViewCell.identifier
        )
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
    }

    private func setupCardLayer() {
        layer.cornerRadius = 8
        layer.shadowColor = R.color.s333333()?.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 2, height: 2)
    }
}

extension CardCollectionViewCell: UICollectionViewDataSource {
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
            // 日付が一致する場合、cellをハイライト表示する
            if let selectedItem = selectedItem,
               Calendar(identifier: .gregorian)
                .isDate(calendarItem.date, equalTo: selectedItem.date, toGranularity: .day) {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            } else {
                collectionView.deselectItem(at: indexPath, animated: false)
            }

            return cell
        default:
            fatalError("collectionViewで想定していないsection")
        }
    }
}

extension CardCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 週の数
        guard let numberOfWeek = Calendar(identifier: .gregorian)
            .range(of: .weekOfMonth, in: .month, for: displayDate) else {
            return CGSize()
        }
        let height: CGFloat
        switch indexPath.section {
        case 0:
            height = weekdayCellHeight
        case 1:
            height = floor(collectionView.bounds.height
                           - weekdayCellHeight
                           - (insetForSection.bottom * 2)) / CGFloat(numberOfWeek.count)
        default:
            fatalError("collectionViewで想定していないsection")
        }
        let width: CGFloat = floor(
            (collectionView.bounds.width - insetForSection.left - insetForSection.right) / numberOfDaysInWeek)
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insetForSection
    }
}

extension CardCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItemAt(calendarItem: items[indexPath.row])
    }
}
