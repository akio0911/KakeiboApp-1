//
//  CategoryInputViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/10/06.
//

import UIKit

class CategoryInputViewController: UIViewController {

    @IBOutlet private weak var categoryTextField: UITextField!
    @IBOutlet private var contentsView: [UIView]!
    @IBOutlet private weak var mosaicView: UIView!
    @IBOutlet private weak var colorView: UIView!
    @IBOutlet private weak var heuSlider: UISlider!
    @IBOutlet private weak var saturationSlider: UISlider!
    @IBOutlet private weak var brightnessSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        contentsView.forEach { setupCornerRadius(view: $0) }
        setupCornerRadius(view: mosaicView)
        setupCornerRadius(view: colorView)
        colorView.backgroundColor = UIColor(hue: 50 / 100, saturation: 50 / 100, brightness: 50 / 100, alpha: 1)
        setupBarButtonItem()
    }

    private func setupCornerRadius(view: UIView) {
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupBarButtonItem() {
        let saveBarButton = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(didTapSaveBarButton)
        )
        navigationItem.rightBarButtonItem = saveBarButton

        let cancelBarButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancelBarButton)
        )
        navigationItem.leftBarButtonItem = cancelBarButton
    }

    @IBAction private func hueSliderValueChanged(_ sender: UISlider) {
        let hue: CGFloat = CGFloat(sender.value / 100)
        let saturation = CGFloat(saturationSlider.value / 100)
        let brightness = CGFloat(brightnessSlider.value / 100)
        colorView.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

    @IBAction func saturationSliderValueChange(_ sender: UISlider) {
        let hue: CGFloat = CGFloat(heuSlider.value / 100)
        let saturation = CGFloat(sender.value / 100)
        let brightness = CGFloat(brightnessSlider.value / 100)
        colorView.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

    @IBAction func brightnessSliderValueChange(_ sender: UISlider) {
        let hue: CGFloat = CGFloat(heuSlider.value / 100)
        let saturation = CGFloat(saturationSlider.value / 100)
        let brightness = CGFloat(sender.value / 100)
        colorView.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

    // MARK: - @objc
    @objc private func didTapCancelBarButton() {
    }

    @objc private func didTapSaveBarButton() {
    }
}
