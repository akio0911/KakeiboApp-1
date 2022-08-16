//
//  GraphViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/02.
//

import UIKit
import RxSwift
import RxCocoa

final class GraphViewController: UIViewController, UITableViewDelegate, BalanceSegmentedControlViewDelegate {
    @IBOutlet private weak var dateTitleLabel: UILabel!
    @IBOutlet private weak var nextMonthButton: UIButton!
    @IBOutlet private weak var lastMonthButton: UIButton!
    @IBOutlet private weak var pieChartView: PieChartView!
    @IBOutlet private weak var graphView: UIView!
    @IBOutlet private weak var graphTableView: UITableView!

    private let viewModel: GraphViewModelType = GraphViewModel()
    private let disposeBag = DisposeBag()
    private var graphDataArray: [GraphData] = []
    private var segmentedControlView: BalanceSegmentedControlView!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupSwipeGestureRecognizer()
        setupGraphTableView()
        setupSegmentedControlView()
        navigationItem.title = R.string.localizable.graph()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.onViewWillAppear()
    }

    private func setupSwipeGestureRecognizer() {
        // 左スワイプの実装
        let leftSwipeRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(viewSwipeGesture(sender:))
        )
        leftSwipeRecognizer.direction = .left
        graphView.addGestureRecognizer(leftSwipeRecognizer)

        // 右スワイプの実装
        let rightSwipeRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(viewSwipeGesture(sender:))
        )
        rightSwipeRecognizer.direction = .right
        graphView.addGestureRecognizer(rightSwipeRecognizer)
    }

    private func setupBinding() {
        nextMonthButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didActionNextMonth)
            .disposed(by: disposeBag)

        lastMonthButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didActionLastMonth)
            .disposed(by: disposeBag)

        viewModel.outputs.dateTitle
            .drive(dateTitleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.graphData
            .subscribe(
                onNext: { [weak self] graphDataArray in
                    self?.graphDataArray = graphDataArray
                    self?.graphTableView.reloadData()
                }
            )
            .disposed(by: disposeBag)

        viewModel.outputs.graphData
            .subscribe(onNext: pieChartView.setupPieChartView)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .presentCategoryVC(let categoryData, let displayDate):
                    let categoryViewController = CategoryViewController(
                        viewModel: CategoryViewModel(categoryData: categoryData, displayDate: displayDate)
                    )
                    categoryViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(categoryViewController, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupGraphTableView() {
        graphTableView.register(
            GraphTableViewCell.nib,
            forCellReuseIdentifier: GraphTableViewCell.identifier
        )
        graphTableView.dataSource = self
        graphTableView.delegate = self
    }

    private func setupSegmentedControlView() {
        segmentedControlView = BalanceSegmentedControlView()
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlView.delegate = self
        graphView.addSubview(segmentedControlView)
    }

    // MARK: - @objc(SwipeGestureRecognizer)
    @objc private func viewSwipeGesture(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.right:
            viewModel.inputs.didActionLastMonth()
        case UISwipeGestureRecognizer.Direction.left:
            viewModel.inputs.didActionNextMonth()
        default:
            break
        }
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            segmentedControlView.leadingAnchor.constraint(equalTo: graphView.leadingAnchor, constant: 70),
            segmentedControlView.rightAnchor.constraint(equalTo: graphView.rightAnchor, constant: -70),
            segmentedControlView.topAnchor.constraint(equalTo: graphView.topAnchor, constant: 8),
            segmentedControlView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.didSelectRowAt(indexPath: indexPath)
    }

    // MARK: - BalanceSegmentedControlViewDelegate
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        viewModel.inputs.didChangeSegmentIndex(index: selectedSegmentIndex)
    }
}

// MARK: - UITableViewDataSource
extension GraphViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        graphDataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: GraphTableViewCell.identifier,
            for: indexPath
        ) as? GraphTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(data: graphDataArray[indexPath.row])
        return cell
    }
}
