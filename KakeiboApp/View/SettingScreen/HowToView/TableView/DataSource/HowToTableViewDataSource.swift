//
//  HowToTableViewDataSource.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/08.
//

import RxSwift
import RxCocoa

final class HowToTableViewDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {

    typealias Element = [HowToItem]
    private var items: Element = []

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }

    // MARK: - RxTableViewDataSourceType
    func tableView(_ tableView: UITableView, observedEvent: Event<[HowToItem]>) {
        Binder(self) { dataSource, element in
            dataSource.items = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}
