//
//  HowToUseTableViewDataSource.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/08.
//

import RxSwift
import RxCocoa

final class HowToUseTableViewDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    typealias Element = [HowToUseItem]
    private var items: Element = []

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: HowToUseTableViewCell.identifier
        ) as! HowToUseTableViewCell // swiftlint:disable:this force_cast
        cell.configure(item: items[indexPath.row])
        cell.selectedBackgroundView = UIView()
        return cell
    }

    // MARK: - RxTableViewDataSourceType
    func tableView(_ tableView: UITableView, observedEvent: Event<[HowToUseItem]>) {
        Binder(self) { dataSource, element in
            dataSource.items = element
        }
        .on(observedEvent)
    }
}
