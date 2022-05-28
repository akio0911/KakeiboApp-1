//
//  CategoryTableViewDataSource.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/19.
//

import UIKit
import RxSwift
import RxCocoa

final class CategoryTableViewDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    typealias Element = [[CellDateCategoryData]]
    private var items: Element = [[]]

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier
        ) as! CategoryTableViewCell // swiftlint:disable:this force_cast
        cell.configure(data: items[indexPath.section][indexPath.row])
        return cell
    }

    // MARK: - RxTableViewDataSourceType
    func tableView(_ tableView: UITableView, observedEvent: Event<[[CellDateCategoryData]]>) {
        Binder(self) { dataSource, element in
            dataSource.items = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}
