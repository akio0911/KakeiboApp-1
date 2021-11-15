//
//  PieChartView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/14.
//

import UIKit

final class PieChartView: UIView, CAAnimationDelegate {
    private struct Pie {
        let layer: CAShapeLayer
        let duration: CFTimeInterval
        let label: UILabel? // 項目の割合が小さい場合はラベルを表示しないためオプショナル
    }

    private var count = 0 // 実行中のアニメーションレイヤー
    private var pies: [Pie] = []
    private var size: CGFloat! // frameの短い辺
    private var radius: CGFloat! // arcPathの半径
    private var basicLineWidth: CGFloat! // グラフの幅
    private var largerLineWidth: CGFloat! // 拡大時のグラフの幅
    private var selectedLayer: CAShapeLayer? // 選択されているレイヤー
    private var centerSpace: CGFloat! // グラフ中心のスペース
    private let duration: TimeInterval = 0.25 // グラフが表示されるまでの時間
    private var totalBalanceText: String! // グラフ中央のtext

    override func awakeFromNib() {
        super.awakeFromNib()
        size = min(frame.width, frame.height)
        basicLineWidth = size / 3.5 // グラフの幅を指定
        let scaleLength: CGFloat = 5 // タップ時に拡大する長さを指定
        largerLineWidth = basicLineWidth + (scaleLength * 2)
        radius = (size - largerLineWidth) / 2
        centerSpace = size - (2 * basicLineWidth) - (largerLineWidth - basicLineWidth)
    }

    // MARK: - touchesBegan
    // グラフタップ時にグラフを拡大・縮小
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タップされたポイントの色を取得
        let touch = touches.first
        let point = touch!.location(in: self)
        let color = colorOfPoint(point: point)

        // piesから色が一致するレイヤーがあれば、取り出す
        // colorに丸め誤差が発生するため、HEXに変換し、比較する
        guard let layer = pies.first(where: {
            UIColor(cgColor: $0.layer.strokeColor!).hex == color.hex
        })?.layer else { return }

        // レイヤーの拡大・縮小
        if layer == selectedLayer {
            // すでに選択されている時
            layer.lineWidth = basicLineWidth
            selectedLayer = nil
        } else {
            // 選択されていない時
            selectedLayer?.lineWidth = basicLineWidth
            layer.lineWidth = largerLineWidth
            selectedLayer = layer
        }
    }

    // pointの色を取得する
    private func colorOfPoint(point: CGPoint) -> UIColor {
        // デバイスに依存したRGB色空間を作成
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()

        // ビットマップをRGBAで取得
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        // ピクセルデータを取得
        var pixelData: [UInt8] = [0, 0, 0, 0]
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8,
                                bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.translateBy(x: -point.x, y: -point.y)
        self.layer.render(in: context!)

        // ピクセルデータからUIColorを作成
        let red: CGFloat = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green: CGFloat = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue: CGFloat = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha: CGFloat = CGFloat(pixelData[3]) / CGFloat(255.0)
        let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)

        return color
    }

    // MARK: - function
    func setupPieChartView(setData data: [GraphData]) {
        // 初期化の処理
        count = 0
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        pies.removeAll()

        // データが空の時の処理
        if data.isEmpty {
            addCenterView(text: "0円", duration: 0.4)
            return
        }

        // Pieの配列を作成
        let totalBalance = data.reduce(0) { $0 + $1.totalBalance }
        var startAngle = -Double.pi / 2
        data.sorted { $0.totalBalance > $1.totalBalance }
        .forEach {
            let angleRate = ceil(Double($0.totalBalance) / Double(totalBalance) * pow(10, 5)) / pow(10, 5)
            let angle = Double.pi * 2 * angleRate + startAngle
            let arcPath = createArcPath(startAngle: startAngle, endAngle: angle)
            let layer = createCAShapeLayer(path: arcPath, storokeColor: $0.categoryData.color.cgColor)

            // angleRateが小さい場合はラベルを作らない
            var label: UILabel?
            if angleRate > Double(22 / size) {
                label = createCategoryLabel(category: $0.categoryData.name, balance: $0.totalBalance,
                                            startAngle: startAngle, endAngle: angle)
            }

            pies.append(
                Pie(layer: layer, duration: Double(angleRate * duration), label: label)
            )
            startAngle = angle
        }

        totalBalanceText = NumberFormatterUtility.changeToCurrencyNotation(from: totalBalance) ?? "0円"

        // 最初のアニメーション実行
        addCABasicAnimation(layer: pies[count].layer, duration: pies[count].duration)
        layer.addSublayer(pies[count].layer)

        // 最初のラベルを反映
        if let label = pies[count].label {
            addSubview(label)
            // アニメーションで表示
            UIView.animate(withDuration: 0.2) {
                label.alpha = 1
            }
        }
    }

    // 円弧のパスを作成
    private func createArcPath(startAngle: CGFloat, endAngle: CGFloat) -> CGPath {
        let arcCenter = CGPoint(x: size / 2, y: size / 2)
        let arcPath = UIBezierPath(
            arcCenter: arcCenter,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        return arcPath.cgPath
    }

    // レイヤーを作成
    private func createCAShapeLayer(path: CGPath, storokeColor: CGColor) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.strokeColor = storokeColor
        shapeLayer.lineWidth = basicLineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        return shapeLayer
    }

    // レイヤーにアニメーションを反映
    private func addCABasicAnimation(layer: CAShapeLayer, duration: CFTimeInterval) {
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.delegate = self
        layer.add(animation, forKey: #keyPath(CAShapeLayer.strokeEnd))
    }

    // グラフ中央のViewを反映
    private func addCenterView(text: String, duration: TimeInterval) {
        // センターの丸いviewを作成
        let centerView = UIView(frame: CGRect(x: 0, y: 0, width: centerSpace, height: centerSpace))
        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = centerSpace / 2
        centerView.clipsToBounds = true
        centerView.center = CGPoint(x: size / 2, y: size / 2)
        centerView.alpha = 0 // フェードのようなアニメーションをするためalphaを0に設定

        // センターに載せるラベルを作成
        let label = UILabel(
            frame: CGRect(x: 0, y: 0, width: centerSpace - 5, height: 34)
        )
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = text
        label.center = CGPoint(x: centerSpace / 2, y: centerSpace / 2)
        centerView.addSubview(label)
        addSubview(centerView)

        // アニメーションで表示
        UIView.animate(withDuration: duration) {
            centerView.alpha = 1
        }
    }

    // グラフの上に載せるラベルを作成
    private func createCategoryLabel(category: String, balance: Int, startAngle: Double, endAngle: Double) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: basicLineWidth - 5, height: 45))
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "\(category)\n\(NumberFormatterUtility.changeToCurrencyNotation(from: balance) ?? "0円")"
        label.textColor = .white
        label.center = calcCenter(startAngle: startAngle, endAngle: endAngle)
        label.alpha = 0 // フェードのようなアニメーションをするためalphaを0に設定
        return label
    }

    // グラフの上に載せるラベルのcenterを計算
    private func calcCenter(startAngle: Double, endAngle: Double) -> CGPoint {
        let angle = (endAngle - startAngle) / 2 + startAngle
        let x = cos(angle) * radius // swiftlint:disable:this identifier_name
        let y = sin(angle) * radius // swiftlint:disable:this identifier_name
        return CGPoint(x: Double(size / 2) + x, y: Double(size / 2) + y)
    }

    // MARK: - CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        count += 1
        if count < pies.count {
            // アニメーションを実行
            addCABasicAnimation(layer: pies[count].layer, duration: pies[count].duration)
            layer.addSublayer(pies[count].layer)
            // ラベルを反映
            if let label = pies[count].label {
                addSubview(label)
                // アニメーションで表示
                UIView.animate(withDuration: 0.2) {
                    label.alpha = 1
                }
            }
        }

        // 全ての実行を終えた時
        if count == pies.count {
            // グラフ中央のviewを反映
            addCenterView(text: totalBalanceText, duration: 0.2)
        }
    }
}
