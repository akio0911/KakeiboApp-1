//
//  GraphViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/02.
//

import UIKit
import RxSwift
import RxCocoa

final class GraphViewController: UIViewController, UITableViewDelegate, SegmentedControlViewDelegate {

    @IBOutlet private weak var graphNavigationBar: UINavigationBar!
    @IBOutlet private weak var graphNavigationItem: UINavigationItem!
    @IBOutlet private weak var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var lastBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var pieChartView: PieChartView!
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
//        setupSwipeGestureRecognizer()
        setupGraphTableView()
        setupSegmentedControlView()
        navigationItem.title = "グラフ"
    }

//    private func setupSwipeGestureRecognizer() {
//        // 左スワイプの実装
//        let leftSwipeRecognizer = UISwipeGestureRecognizer(
//            target: self,
//            action: #selector(viewSwipeGesture(sender:))
//        )
//        leftSwipeRecognizer.direction = .left
//        rightSwipeView.addGestureRecognizer(leftSwipeRecognizer)
//
//        // 右スワイプの実装
//        let rightSwipeRecognizer = UISwipeGestureRecognizer(
//            target: self,
//            action: #selector(viewSwipeGesture(sender:))
//        )
//        rightSwipeRecognizer.direction = .right
//        leftSwipeView.addGestureRecognizer(rightSwipeRecognizer)
//    }

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
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.pieChartView.setupPieChartView(setData: data)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .presentCategoryVC(let categoryData):
                    let categoryViewController = CategoryViewController(
                        viewModel: CategoryViewModel(categoryData: categoryData)
                    )
                    categoryViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(categoryViewController, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupGraphTableView() {
        graphTableView.register(GraphTableViewCell.nib,
                                forCellReuseIdentifier: GraphTableViewCell.identifier)
        graphTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }

    private func setupSegmentedControlView() {
        segmentedControlView = SegmentedControlView()
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlView.delegate = self
        view.addSubview(segmentedControlView)
    }

    // MARK: - @objc(SwipeGestureRecognizer)
    @objc private func viewSwipeGesture(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.right:
            viewModel.inputs.didTapLastBarButton()
        case UISwipeGestureRecognizer.Direction.left:
            viewModel.inputs.didTapNextBarButton()
        default:
            break
        }
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            pieChartView.widthAnchor.constraint(equalToConstant: view.frame.width - 90),
            segmentedControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70),
            segmentedControlView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -70),
            segmentedControlView.topAnchor.constraint(equalTo: graphNavigationBar.bottomAnchor, constant: 8),
            segmentedControlView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.didSelectRowAt(index: indexPath)
    }

    // MARK: - SegmentedControlViewDelegate
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        viewModel.inputs.didChangeSegmentIndex(index: selectedSegmentIndex)
    }
}
