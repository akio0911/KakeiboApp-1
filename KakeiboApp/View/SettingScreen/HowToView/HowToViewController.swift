//
//  HowToViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/08.
//

import UIKit
import RxSwift
import RxCocoa

final class HowToViewController: UIViewController, UITableViewDelegate {

    @IBOutlet private weak var howToTableView: UITableView!

    private let viewModel: HowToViewModelType
    private let disposeBag = DisposeBag()
    private let howToTableViewDataSource = HowToTableViewDataSource()

    init(viewModel: HowToViewModelType = HowToViewModel()) {
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
    }

    private func setupHowToTableView() {
        howToTableView.register(HowToTableViewCell.nib,
                                forCellReuseIdentifier: HowToTableViewCell.identifier)
        howToTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }

    private func setupBinding() {
        viewModel.outputs.items
            .bind(to: howToTableView.rx.items(
                dataSource: howToTableViewDataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.didSelectRowAt(index: indexPath)
    }
}
