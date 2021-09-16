//
//  GraphTableViewDataSource.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/08.
//

import UIKit
import RxSwift
import RxCocoa

final class GraphTableViewDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {

    typealias Element = [GraphData]
    private var items: Element = []

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: GraphTableViewCell.identifier
        ) as! GraphTableViewCell
        cell.configure(data: items[indexPath.row])
        return cell
    }

    // MARK: - RxTableViewDataSourceType
    func tableView(_ tableView: UITableView, observedEvent: Event<[GraphData]>) {
        Binder(self) { dataSource, element in
            dataSource.items = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}
