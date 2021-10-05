//
//  CategoryEditTableViewDataSource.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/05.
//

import UIKit
import RxSwift
import RxCocoa

final class CategoryEditTableViewDataSource:
    NSObject, UITableViewDataSource, RxTableViewDataSourceType {

    typealias Element = [CategoryData]
    private var items: Element = []

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryEditTableViewCell.identifier
        ) as! CategoryEditTableViewCell
        cell.configure(data: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<[CategoryData]>) {
        Binder(self) { dataSource, element in
            dataSource.items = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}
