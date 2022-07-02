//
//  PasscodeInputButtonView.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/29.
//

import UIKit

protocol PasscodeInputButtonViewDelegate: AnyObject {
    func didTapNumberButton(tapNumber: String)
    func didTapDeleteButton()
}

final class PasscodeInputButtonView: UIView {
    weak var delegate: PasscodeInputButtonViewDelegate?

    private var button1: UIButton!
    private var button2: UIButton!
    private var button3: UIButton!
    private var button4: UIButton!
    private var button5: UIButton!
    private var button6: UIButton!
    private var button7: UIButton!
    private var button8: UIButton!
    private var button9: UIButton!
    private var button0: UIButton!
    private var deleteButton: UIButton!

    private let space: CGFloat = 20 // ボタンの間隔
    private var buttonWidth: CGFloat { floor((super.frame.width - (space * 2)) / 3) }
    private var buttonHeight: CGFloat { floor((super.frame.height - (space * 3)) / 4) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        button0 = createNumberButton(title: "0")
        addSubview(button0)
        button1 = createNumberButton(title: "1")
        addSubview(button1)
        button2 = createNumberButton(title: "2")
        addSubview(button2)
        button3 = createNumberButton(title: "3")
        addSubview(button3)
        button4 = createNumberButton(title: "4")
        addSubview(button4)
        button5 = createNumberButton(title: "5")
        addSubview(button5)
        button6 = createNumberButton(title: "6")
        addSubview(button6)
        button7 = createNumberButton(title: "7")
        addSubview(button7)
        button8 = createNumberButton(title: "8")
        addSubview(button8)
        button9 = createNumberButton(title: "9")
        addSubview(button9)
        deleteButton = createDeleteButton()
        addSubview(deleteButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createNumberButton(title: String) -> UIButton {
        let button = UIButton()
        let attributedTitleNormal: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: R.color.s333333()!,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 27)
        ]
        let stringNormal = NSAttributedString(string: title, attributes: attributedTitleNormal)
        button.setAttributedTitle(stringNormal, for: .normal)
        let attributedTitleHighlighted: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: R.color.s333333()!.withAlphaComponent(0.5),
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 27)
        ]
        let stringHighlighted = NSAttributedString(string: title, attributes: attributedTitleHighlighted)
        button.setAttributedTitle(stringHighlighted, for: .highlighted)
        button.setBackgroundImage(UIImage(color: .systemGray5), for: .normal)
        button.setBackgroundImage(UIImage(color: .systemGray5.withAlphaComponent(0.5)), for: .highlighted)
        button.addTarget(self, action: #selector(didTapNumberButton(_:)), for: .touchUpInside)
        return button
    }

    private func createDeleteButton() -> UIButton {
        let button = UIButton()
        if #available(iOS 15.0, *) {
            let configurationNormal = UIImage.SymbolConfiguration(hierarchicalColor: .label)
            button.setImage(
                UIImage(
                    systemName: "delete.left",
                    withConfiguration: configurationNormal
                ),
                for: .normal
            )
            let configurationHighlighted = UIImage.SymbolConfiguration(
                hierarchicalColor: .label.withAlphaComponent(0.5)
            )
            button.setImage(
                UIImage(
                    systemName: "delete.left",
                    withConfiguration: configurationHighlighted
                ), for: .highlighted
            )
        } else {
            button.setImage(UIImage(systemName: "delete.left"), for: .normal)
            button.imageView?.tintColor = .label
        }
        button.setBackgroundImage(UIImage(color: .systemGray5), for: .normal)
        button.setBackgroundImage(UIImage(color: .systemGray5.withAlphaComponent(0.5)), for: .highlighted)
        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        return button
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureButtonLayout(button: button1, position: 0)
        configureButtonLayout(button: button2, position: 1)
        configureButtonLayout(button: button3, position: 2)
        configureButtonLayout(button: button4, position: 3)
        configureButtonLayout(button: button5, position: 4)
        configureButtonLayout(button: button6, position: 5)
        configureButtonLayout(button: button7, position: 6)
        configureButtonLayout(button: button8, position: 7)
        configureButtonLayout(button: button9, position: 8)
        configureButtonLayout(button: button0, position: 10)
        configureButtonLayout(button: deleteButton, position: 11)
        configureDeleteButtonImageLayout(button: deleteButton)
    }

    /* position: Int
      ---- ---- ----
     | 0  | 1  | 2  |
      ---- ---- ----
     | 3  | 4  | 5  |
      ---- ---- ----
     | 6  | 7  | 8  |
      ---- ---- ----
     | 9  | 10 | 11 |
      ---- ---- ----
     */
    private func configureButtonLayout(button: UIButton, position: Int) {
        // ボタンのframeを設定
        let line = CGFloat(floor(Double(position) / 3)) // 行
        let column = CGFloat(position % 3) // 列

        let buttonX = buttonWidth * column + space * column
        let buttonY = buttonHeight * line + space * line
        let buttonFrame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
        button.frame = buttonFrame

        // ボタンを短い辺に合わせてフィレット
        let lengthThanShort = min(buttonWidth, buttonHeight)
        button.layer.cornerRadius = lengthThanShort / 2
        button.layer.masksToBounds = true
    }

    private func configureDeleteButtonImageLayout(button: UIButton) {
        // imageのサイズを設定
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        let lengthThanShort = min(buttonWidth, buttonHeight)
        let edgeInset = lengthThanShort / 3
        button.imageEdgeInsets = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
    }

    @objc private func didTapNumberButton(_ sender: UIButton) {
        delegate?.didTapNumberButton(tapNumber: sender.titleLabel?.text ?? "")
    }

    @objc private func didTapDeleteButton() {
        delegate?.didTapDeleteButton()
    }
}
