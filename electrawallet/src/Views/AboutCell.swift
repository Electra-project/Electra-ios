//
//  AboutCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-04-05.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

class AboutCell: UIView {

    let button: UIButton

    init(text: String, image: UIImage) {
        button = UIButton.init(color: .transparent)
        label.text = text
        icon.image = image
        super.init(frame: .zero)
        setup()
    }

    private let label = UILabel(font: .customBody(size: 16.0), color: .white)
    private let separator = UIView(color: .secondaryShadow)
    private let icon = UIImageView()
    
    private func setup() {
        addSubview(icon)
        addSubview(label)
        addSubview(button)
        addSubview(separator)
        
        icon.contentMode = .scaleAspectFit
        icon.constrain([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
            icon.heightAnchor.constraint(equalToConstant: 36), // 36: OpenBrowser reference
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalTo: icon.heightAnchor)])
        label.constrain([
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: C.padding[2]),
            label.topAnchor.constraint(equalTo: topAnchor, constant: C.padding[2]),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[2]) ])
        
        button.constrain([
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.heightAnchor.constraint(equalTo: heightAnchor)])
        separator.constrain([
            separator.leadingAnchor.constraint(equalTo: icon.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -C.padding[2]),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0) ])
        button.tintColor = .transparentWhite
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WalletIDCell: UIView {
    
    init() {
        button = UIButton(type: .system)
        super.init(frame: .zero)
        setup()
    }
    
    private let button: UIButton
    private let label = UILabel(font: .customBody(size: 16.0), color: .white)
    private let separator = UIView(color: .secondaryShadow)
    
    private func setup() {
        addSubview(label)
        addSubview(button)
        addSubview(separator)
        
        // constraints
        label.constrain([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
            label.topAnchor.constraint(equalTo: topAnchor, constant: C.padding[2]),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[2]) ])
        button.constrain([
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]),
            button.centerYAnchor.constraint(equalTo: label.centerYAnchor) ])
        separator.constrain([
            separator.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0) ])
        button.tintColor = .primaryButton
        
        // properties
        button.setTitle(S.URLHandling.copy, for: .normal)
        let title = NSMutableAttributedString(string: S.About.walletID)
        if let walletID = Store.state.walletID {
            title.append(NSAttributedString(string: "\n\(walletID)", attributes: [.foregroundColor: UIColor.darkGray]))
            button.tap = { [unowned self] in
                self.button.tempDisable()
                Store.trigger(name: .lightWeightAlert(S.Receive.copied))
                UIPasteboard.general.string = walletID
            }
        }
        label.numberOfLines = 2
        label.attributedText = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
