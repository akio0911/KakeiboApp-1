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

final class GraphViewController: UIViewController, UITableViewDelegate {

    @IBOutlet private weak var graphNavigationItem: UINavigationItem!
    @IBOutlet private weak var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var lastBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var pieChartSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var categoryPieChartView: PieChartView!
    @IBOutlet private weak var graphTableView: UITableView!

    private let viewModel: GraphViewModelType
    private let disposeBag = DisposeBag()
    private let graphTableViewDataSource = GraphTableViewDataSource()
    private var calendarDate: CalendarDate!
    private var pieChartData = [GraphData]()

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
        navigationItem.title = "グラフ"
    }

    private func setupBinding() {
        nextBarButtonItem.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapNextBarButton)
            .disposed(by: disposeBag)

        lastBarButtonItem.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapLastBarButton)
            .disposed(by: disposeBag)

        // TODO: 動作確認必要
        pieChartSegmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: viewModel.inputs.didChangeSegmentIndex(index:))
            .disposed(by: disposeBag)
        
        viewModel.outputs.navigationTitle
            .drive(graphNavigationItem.rx.title)
            .disposed(by: disposeBag)

        viewModel.outputs.cellCategoryDataObservable
            .bind(to: graphTableView.rx.items(dataSource: graphTableViewDataSource))
            .disposed(by: disposeBag)

        viewModel.outputs.graphData
            .drive(onNext: { [weak self] graphData in
                guard let self = self else { return }
                let chartDataEntry = graphData
                    .map {
                        PieChartDataEntry(value: Double($0.totalBalance), label: $0.category.rawValue)
                    }
                let pieChartDataSet = PieChartDataSet(entries: chartDataEntry)
                self.categoryPieChartView.data = PieChartData(dataSet: pieChartDataSet)

                let colors = graphData
                    .map {
                        UIColor(named: $0.category.colorName)!
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

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryPieChartView.frame = CGRect(x: view.safeAreaInsets.left + 30,
                                            y: view.safeAreaInsets.top + 50,
                                            width: view.frame.width - 60,
                                            height: view.frame.width - 60)
        graphTableView.frame = CGRect(x: view.frame.minX,
                                      y: categoryPieChartView.frame.maxY + 8,
                                      width: view.frame.width,
                                      height: view.frame.height
                                        - view.safeAreaInsets.top
                                        - categoryPieChartView.frame.height)
    }
}
