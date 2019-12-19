//
//  VerifyPinViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-01-17.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol ContentBoxPresenter {
    var contentBox: UIView { get }
    var blurView: UIVisualEffectView { get }
    var effect: UIBlurEffect { get }
}

class VerifyPinViewController: UIViewController, ContentBoxPresenter {

    init(bodyText: String, pinLength: Int, walletAuthenticator: WalletAuthenticator, success: @escaping (String) -> Void) {
        self.bodyText = bodyText
        self.success = success
        self.pinLength = pinLength
        self.pinView = PinView(style: .verify, length: pinLength)
        self.walletAuthenticator = walletAuthenticator
        super.init(nibName: nil, bundle: nil)
    }

    var didCancel: (() -> Void)?
    let blurView = UIVisualEffectView()
    let effect = UIBlurEffect(style: .dark)
    let contentBox = UIView()
    private let success: (String) -> Void
    private let pinPad = PinPadViewController(style: .clear, keyboardType: .pinPad, maxDigits: 0, shouldShowBiometrics: false)
    private let titleLabel = UILabel(font: .customBold(size: 19.0), color: .white)
    private let body = UILabel(font: .customBody(size: 15.0), color: .white)
    private let pinView: PinView
    private let toolbar = UIView(color: .whiteTint)
    private let cancel = UIButton(type: .system)
    private let bodyText: String
    private let pinLength: Int
    private let walletAuthenticator: WalletAuthenticator

    override func viewDidLoad() {
        addSubviews()
        addConstraints()
        setupSubviews()
    }

    private func addSubviews() {
        view.addSubview(contentBox)
        view.addSubview(toolbar)
        toolbar.addSubview(cancel)

        contentBox.addSubview(titleLabel)
        contentBox.addSubview(body)
        contentBox.addSubview(pinView)
        addChildViewController(pinPad, layout: {
            pinPad.view.constrain([
                pinPad.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pinPad.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: LAContext.biometricType() == .face ? -C.padding[3] : 0.0),
                pinPad.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                pinPad.view.heightAnchor.constraint(equalToConstant: pinPad.height) ])
        })
    }

    private func addConstraints() {
        contentBox.constrain([
            contentBox.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentBox.bottomAnchor.constraint(equalTo: pinPad.view.topAnchor, constant: -C.padding[20]),
            contentBox.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.8) ])
        titleLabel.constrainTopCorners(sidePadding: C.padding[2], topPadding: C.padding[2])
        body.constrain([
            body.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            body.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            body.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor) ])
        pinView.constrain([
            pinView.topAnchor.constraint(equalTo: body.bottomAnchor, constant: C.padding[2]),
            pinView.centerXAnchor.constraint(equalTo: body.centerXAnchor),
            pinView.widthAnchor.constraint(equalToConstant: pinView.width),
            pinView.heightAnchor.constraint(equalToConstant: pinView.itemSize),
            pinView.bottomAnchor.constraint(equalTo: contentBox.bottomAnchor, constant: -C.padding[2]) ])
        toolbar.constrain([
            toolbar.leadingAnchor.constraint(equalTo: pinPad.view.leadingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: pinPad.view.topAnchor),
            toolbar.trailingAnchor.constraint(equalTo: pinPad.view.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44.0) ])
        cancel.constrain([
            cancel.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            cancel.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -C.padding[2]) ])
    }

    private func setupSubviews() {
        contentBox.backgroundColor = .transparent
        toolbar.backgroundColor = .transparent
        view.layer.contents =  #imageLiteral(resourceName: "Background").cgImage
        contentBox.layer.cornerRadius = 8.0
        contentBox.layer.borderWidth = 1.0
        contentBox.layer.borderColor = UIColor.white.cgColor

        titleLabel.text = S.VerifyPin.title
        titleLabel.textAlignment = .center
        body.text = bodyText
        body.numberOfLines = 0
        body.lineBreakMode = .byWordWrapping
        body.textAlignment = .center

        pinPad.ouputDidUpdate = { [weak self] output in
            guard let myself = self else { return }
            let attemptLength = output.utf8.count
            myself.pinView.fill(attemptLength)
            myself.pinPad.isAppendingDisabled = attemptLength < myself.pinLength ? false : true
            if attemptLength == myself.pinLength {
                if myself.walletAuthenticator.authenticate(withPin: output) {
                    myself.dismiss(animated: true, completion: {
                        myself.success(output)
                    })
                } else {
                    myself.authenticationFailed()
                }
            }
        }
        cancel.tap = { [weak self] in
            self?.didCancel?()
            self?.dismiss(animated: true, completion: nil)
        }
        cancel.setTitle(S.Button.cancel, for: .normal)
        view.backgroundColor = .clear
    }

    private func authenticationFailed() {
        pinPad.view.isUserInteractionEnabled = false
        pinView.shake { [weak self] in
            self?.pinPad.view.isUserInteractionEnabled = true
            self?.pinView.fill(0)
            self?.lockIfNeeded()
        }
        pinPad.clear()
    }

    private func lockIfNeeded() {
        guard walletAuthenticator.walletIsDisabled else { return }
        dismiss(animated: true, completion: {
            Store.perform(action: RequireLogin())
        })
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
