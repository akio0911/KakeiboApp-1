//
//  CalendarTableViewDataSource.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import UIKit
import RxSwift
import RxCocoa

protocol CalendarTableViewDataSourceDelegate: AnyObject {
    func didDeleteCell(index: IndexPath)
}

final class CalendarTableViewDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    typealias Element = [CalendarItem]
    private var items: Element = []

    weak var delegate: CalendarTableViewDataSourceDelegate?

    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CalendarTableViewCell.identifier
        ) as! CalendarTableViewCell // swiftlint:disable:this force_cast
        cell.configure(data: items[indexPath.section].dataArray[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // cellの変更を許可する
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delegate?.didDeleteCell(index: indexPath)
        }
    }

    // MARK: - RxTableViewDataSourceType
    func tableView(_ tableView: UITableView, observedEvent: Event<[CalendarItem]>) {
        Binder(self) { dataSource, element in
            dataSource.items = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}
