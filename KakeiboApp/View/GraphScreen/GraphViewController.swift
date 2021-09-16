//
//  GraphViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/02.
//

import UIKit
import Charts
import RxSwift
import RxCocoa

final class GraphViewController: UIViewController, UITableViewDelegate, SegmentedControlViewDelegate {

    @IBOutlet private weak var graphNavigationBar: UINavigationBar!
    @IBOutlet private weak var graphNavigationItem: UINavigationItem!
    @IBOutlet private weak var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var lastBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var categoryPieChartView: PieChartView!
    @IBOutlet private weak var graphTableView: UITableView!

    private let viewModel: GraphViewModelType
    private let disposeBag = DisposeBag()
    private let graphTableViewDataSource = GraphTableViewDataSource()
    private var pieChartData = [GraphData]()
    private var segmentedControlView: SegmentedControlView!

    init(viewModel: GraphViewModelType = GraphViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupGraphTableView()
        setupSegmentedControlView()
        navigationItem.title = "グラフ"
    }

    private func setupBinding() {
        nextBarButtonItem.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapNextBarButton)
            .disposed(by: disposeBag)

        lastBarButtonItem.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapLastBarButton)
            .disposed(by: disposeBag)
        
        viewModel.outputs.navigationTitle
            .drive(graphNavigationItem.rx.title)
            .disposed(by: disposeBag)

        viewModel.outputs.graphData
            .bind(to: graphTableView.rx.items(dataSource: graphTableViewDataSource))
            .disposed(by: disposeBag)

        viewModel.outputs.graphData
            .subscribe(onNext: { [weak self] graphData in
                guard let self = self else { return }
                var chartDataEntry: [PieChartDataEntry] = []
                graphData.forEach {
                    let label: String
                    switch $0.category {
                    case .income(let category):
                        label = category.rawValue
                    case .expense(let category):
                        label = category.rawValue
                    }
                    chartDataEntry.append(
                        PieChartDataEntry(value: Double($0.totalBalance), label: label)
                    )
                }
                let pieChartDataSet = PieChartDataSet(entries: chartDataEntry)
                self.categoryPieChartView.data = PieChartData(dataSet: pieChartDataSet)

                var colors: [UIColor] = []
                graphData.forEach {
                    switch $0.category {
                    case .income(let category):
                        colors.append(UIColor(named: category.colorName)!)
                    case .expense(let category):
                        colors.append(UIColor(named: category.colorName)!)
                    }
                }
                pieChartDataSet.colors = colors
                self.categoryPieChartView.legend.enabled = false
            })
            .disposed(by: disposeBag)
    }

    private func setupGraphTableView() {
        graphTableView.register(GraphTableViewCell.nib,
                                forCellReuseIdentifier: GraphTableViewCell.identifier)
    }

    private func setupSegmentedControlView() {
        segmentedControlView = SegmentedControlView()
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlView.delegate = self
        view.addSubview(segmentedControlView)
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            categoryPieChartView.widthAnchor.constraint(
                equalToConstant: view.frame.width - 90
            ),
            segmentedControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70),
            segmentedControlView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -70),
            segmentedControlView.topAnchor.constraint(equalTo: graphNavigationBar.bottomAnchor, constant: 8),
            segmentedControlView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // MARK: - SegmentedControlViewDelegate
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        viewModel.inputs.didChangeSegmentIndex(index: selectedSegmentIndex)
    }
}
