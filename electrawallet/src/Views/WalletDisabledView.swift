//
//  WalletDisabledView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-05-01.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

class WalletDisabledView: UIView {

    func setTimeLabel(string: String) {
        label.text = string
    }

    init() {
        blur = UIVisualEffectView()
        super.init(frame: .zero)
        setup()
    }

    func show() {
        UIView.animate(withDuration: C.animationDuration, animations: {
            self.blur.effect = self.effect
        })
    }

    func hide(completion: @escaping () -> Void) {
        UIView.animate(withDuration: C.animationDuration, animations: {
            self.blur.effect = nil
        }, completion: { _ in
            completion()
        })
    }

    var didTapReset: (() -> Void)? {
        didSet {
            reset.tap = didTapReset
        }
    }

    private let label = UILabel(font: .customBold(size: 20.0), color: .whiteTint)
    private let blur: UIVisualEffectView
    private let reset = BRDButton(title: S.UnlockScreen.resetPin, type: .primary)
    private let effect = UIBlurEffect(style: .regular)

    private func setup() {
        addSubviews()
        addConstraints()
        setData()
    }

    private func addSubviews() {
        addSubview(blur)
        addSubview(label)
        addSubview(reset)
    }

    private func addConstraints() {
        blur.constrain(toSuperviewEdges: nil)
        label.constrain([
            label.centerYAnchor.constraint(equalTo: blur.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: blur.centerXAnchor) ])
        reset.constrain([
            reset.centerXAnchor.constraint(equalTo: centerXAnchor),
            reset.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[2]),
            reset.heightAnchor.constraint(equalToConstant: C.Sizes.buttonHeight),
            reset.widthAnchor.constraint(equalToConstant: 200.0) ])

    }

    private func setData() {
        label.textAlignment = .center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
