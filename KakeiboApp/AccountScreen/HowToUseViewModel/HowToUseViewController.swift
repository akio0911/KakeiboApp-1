//
//  HowToUseViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/08.
//

import UIKit
import RxSwift
import RxCocoa

final class HowToUseViewController: UIViewController, UITableViewDelegate {
    @IBOutlet private weak var howToUseTableView: UITableView!

    private let viewModel: HowToUseViewModelType
    private let disposeBag = DisposeBag()
    private let howToTableViewDataSource = HowToUseTableViewDataSource()

    init(viewModel: HowToUseViewModelType = HowToUseViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHowToTableView()
        setupBinding()
        navigationItem.title = R.string.localizable.appHowToUse()
    }

    private func setupHowToTableView() {
        howToUseTableView.register(HowToUseTableViewCell.nib,
                                   forCellReuseIdentifier: HowToUseTableViewCell.identifier)
        howToUseTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }

    private func setupBinding() {
        viewModel.outputs.items
            .bind(to: howToUseTableView.rx.items(
                dataSource: howToTableViewDataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.didSelectRowAt(index: indexPath)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}
