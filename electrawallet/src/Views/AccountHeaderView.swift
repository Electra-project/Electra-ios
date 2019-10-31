//
//  AccountHeaderView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit
import BRCore

private let largeFontSize: CGFloat = 28.0
private let smallFontSize: CGFloat = 14.0

class AccountHeaderView: UIView, Subscriber {

    // MARK: - Views
    
    private let currencyLogo = UIImageView(image: #imageLiteral(resourceName: "eca_white"))
    private let skinContainerView = UIView()
    private let exchangeRateLabel = UILabel(font: .customBody(size: 14.0))
    private let primaryBalance: UpdatingLabel
    private let secondaryBalance: UpdatingLabel
    private let conversionSymbol = UIImageView(image: #imageLiteral(resourceName: "conversion"))
    private let currencyTapView = UIView()
    private let syncView: SyncingHeaderView
    private let modeLabel = UILabel(font: .customBody(size: 12.0), color: .transparentWhiteText) // debug info
    private var regularConstraints: [NSLayoutConstraint] = []
    private var swappedConstraints: [NSLayoutConstraint] = []
    private var syncViewHeight: NSLayoutConstraint?
    private var delistedTokenView: DelistedTokenView?

    // MARK: Properties
    private let currency: Currency
    private var hasInitialized = false
    private var hasSetup = false
    
    private var isSyncIndicatorVisible: Bool = false {
        didSet {
            if isSyncIndicatorVisible {
                showSyncView()
            }
        }
    }

    var isWatchOnly: Bool = false {
        didSet {
            if E.isTestnet || isWatchOnly {
                if E.isTestnet && isWatchOnly {
                    modeLabel.text = "(Testnet - Watch Only)"
                } else if E.isTestnet {
                    modeLabel.text = "(Testnet)"
                } else if isWatchOnly {
                    modeLabel.text = "(Watch Only)"
                }
                modeLabel.isHidden = false
            }
            if E.isScreenshots {
                modeLabel.isHidden = true
            }
        }
    }
    private var exchangeRate: Rate? {
        didSet {
            DispatchQueue.main.async {
                self.setBalances()
            }
        }
    }
    
    private var balance: UInt256 = 0 {
        didSet {
            DispatchQueue.main.async {
                self.setBalances()
            }
        }
    }
    
    private var isBtcSwapped: Bool {
        didSet {
            DispatchQueue.main.async {
                self.setBalances()
            }
        }
    }

    // MARK: -
    
    init(currency: Currency) {
        self.currency = currency
        self.syncView =  SyncingHeaderView(currency: currency)
        self.isBtcSwapped = Store.state.isBtcSwapped
        if let rate = currency.state?.currentRate {
            let placeholderAmount = Amount(amount: 0, currency: currency, rate: rate)
            self.exchangeRate = rate
            self.secondaryBalance = UpdatingLabel(formatter: placeholderAmount.localFormat)
            self.primaryBalance = UpdatingLabel(formatter: placeholderAmount.tokenFormat)
        } else {
            self.secondaryBalance = UpdatingLabel(formatter: NumberFormatter())
            self.primaryBalance = UpdatingLabel(formatter: NumberFormatter())
        }
        if let token = currency as? ERC20Token, token.isSupported == false {
            self.delistedTokenView = DelistedTokenView(currency: currency)
        }
        super.init(frame: CGRect())
        
        setup()
    }

    // MARK: Private
    
    private func setup() {
        addSubviews()
        addConstraints()
        setData()
        addSubscriptions()
    }

    private func setData() {
        skinContainerView.backgroundColor = UIColor(red: 0.110, green: 0.070, blue: 0.257, alpha: 1.0)
        skinContainerView.layer.cornerRadius = 10
        skinContainerView.layer.borderWidth = 1
        skinContainerView.layer.borderColor = UIColor.white.cgColor
        
        exchangeRateLabel.textColor = .transparentWhiteText
        exchangeRateLabel.textAlignment = .center
        
        primaryBalance.textAlignment = .center
        secondaryBalance.textAlignment = .center
        
        swapLabels()

        modeLabel.isHidden = true
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(currencySwitchTapped))
        currencyTapView.addGestureRecognizer(gr)
    }

    private func addSubviews() {
        addSubview(skinContainerView)
        addSubview(currencyLogo)
        addSubview(skinContainerView)
        addSubview(exchangeRateLabel)
        addSubview(primaryBalance)
        addSubview(secondaryBalance)
        addSubview(conversionSymbol)
        addSubview(modeLabel)
        addSubview(currencyTapView)
        addSubview(syncView)
        if let delistedTokenView = delistedTokenView {
            addSubview(delistedTokenView)
        }
    }

    private func showSyncView() {
        syncViewHeight?.constant = SyncingHeaderView.height
        UIView.spring(C.animationDuration, animations: {
            self.superview?.superview?.layoutIfNeeded()
        }, completion: {_ in})
    }

    private func hideSyncView() {
        syncViewHeight?.constant = 0.0
        UIView.spring(C.animationDuration, animations: {
            self.superview?.superview?.layoutIfNeeded()
        }, completion: {_ in})
    }

    private func addConstraints() {
        currencyLogo.contentMode = .scaleAspectFit
        currencyLogo.constrain([
            currencyLogo.constraint(.leading, toView: self, constant: C.padding[1]),
            currencyLogo.constraint(.trailing, toView: self, constant: -C.padding[1]),
            currencyLogo.constraint(.height, constant: 55),
            currencyLogo.constraint(.top, toView: self, constant: E.isIPhoneX ? C.padding[5] : C.padding[3])])
        
        primaryBalance.constrain([
            primaryBalance.constraint(.leading, toView: self, constant: C.padding[2]),
            primaryBalance.constraint(.trailing, toView: self, constant: -C.padding[2])])
        
        secondaryBalance.constrain([
            secondaryBalance.trailingAnchor.constraint(equalTo: primaryBalance.trailingAnchor),
            secondaryBalance.leadingAnchor.constraint(equalTo: primaryBalance.leadingAnchor)])
        
        conversionSymbol.contentMode = .scaleAspectFit
        conversionSymbol.constrain([
            conversionSymbol.constraint(.height, constant: 20.0),
            conversionSymbol.constraint(.leading, toView: self, constant: C.padding[2]),
            conversionSymbol.constraint(.trailing, toView: self, constant: -C.padding[2])])

        currencyTapView.constrain([
            currencyTapView.trailingAnchor.constraint(equalTo: primaryBalance.trailingAnchor),
            currencyTapView.leadingAnchor.constraint(equalTo: primaryBalance.leadingAnchor)])

        skinContainerView.constrain([
            skinContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            skinContainerView.topAnchor.constraint(equalTo: currencyLogo.bottomAnchor, constant: C.padding[1]),
            skinContainerView.bottomAnchor.constraint(equalTo: currencyLogo.bottomAnchor, constant: C.padding[1] + 110),
            skinContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
            skinContainerView.widthAnchor.constraint(equalTo: widthAnchor, constant: -14)])
        
        exchangeRateLabel.constrain([
            exchangeRateLabel.trailingAnchor.constraint(equalTo: skinContainerView.trailingAnchor, constant: -C.padding[1]),
            exchangeRateLabel.bottomAnchor.constraint(equalTo: skinContainerView.bottomAnchor, constant: -C.padding[1])])

        regularConstraints = [
            primaryBalance.topAnchor.constraint(equalTo: skinContainerView.topAnchor, constant: C.padding[1]),
            conversionSymbol.topAnchor.constraint(equalTo: primaryBalance.bottomAnchor, constant: C.padding[1]),
            secondaryBalance.topAnchor.constraint(equalTo: conversionSymbol.bottomAnchor),
            currencyTapView.topAnchor.constraint(equalTo: primaryBalance.topAnchor),
            currencyTapView.bottomAnchor.constraint(equalTo: secondaryBalance.bottomAnchor)
            
        ]
        swappedConstraints = [
             secondaryBalance.topAnchor.constraint(equalTo: skinContainerView.topAnchor, constant: C.padding[1]),
             conversionSymbol.topAnchor.constraint(equalTo: secondaryBalance.bottomAnchor, constant: C.padding[1]),
             primaryBalance.topAnchor.constraint(equalTo: conversionSymbol.bottomAnchor),
             currencyTapView.topAnchor.constraint(equalTo: secondaryBalance.topAnchor),
             currencyTapView.bottomAnchor.constraint(equalTo: primaryBalance.bottomAnchor)
        ]
        NSLayoutConstraint.activate(isBtcSwapped ? self.swappedConstraints : self.regularConstraints)

        syncViewHeight = syncView.heightAnchor.constraint(equalToConstant: 40.0)
        
        if let delistedTokenView = delistedTokenView {
            delistedTokenView.constrain([
                delistedTokenView.topAnchor.constraint(equalTo: primaryBalance.firstBaselineAnchor, constant: C.padding[2]),
                delistedTokenView.bottomAnchor.constraint(equalTo: bottomAnchor),
                delistedTokenView.widthAnchor.constraint(equalTo: widthAnchor),
                delistedTokenView.leadingAnchor.constraint(equalTo: leadingAnchor)])
        } else {
            syncView.constrain([
                syncView.topAnchor.constraint(equalTo: skinContainerView.bottomAnchor, constant: C.padding[1]),
                syncView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[1]),
                syncView.widthAnchor.constraint(equalTo: widthAnchor, constant: -14),
                syncView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
                syncViewHeight])
        }
    }

    private func addSubscriptions() {
        Store.lazySubscribe(self,
                            selector: { $0.isBtcSwapped != $1.isBtcSwapped },
                            callback: { self.isBtcSwapped = $0.isBtcSwapped })
        Store.lazySubscribe(self,
                            selector: { $0[self.currency]?.currentRate != $1[self.currency]?.currentRate},
                            callback: {
                                if let rate = $0[self.currency]?.currentRate {
                                    let placeholderAmount = Amount(amount: 0, currency: self.currency, rate: rate)
                                    self.secondaryBalance.formatter = placeholderAmount.localFormat
                                    //self.primaryBalance.formatter = placeholderAmount.tokenFormat
                                }
                                self.exchangeRate = $0[self.currency]?.currentRate
        })
        
        Store.lazySubscribe(self,
                            selector: { $0[self.currency]?.maxDigits != $1[self.currency]?.maxDigits},
                            callback: {
                                if let rate = $0[self.currency]?.currentRate {
                                    let placeholderAmount = Amount(amount: 0, currency: self.currency, rate: rate)
                                    self.secondaryBalance.formatter = placeholderAmount.localFormat
                                    //self.primaryBalance.formatter = placeholderAmount.tokenFormat
                                    self.setBalances()
                                }
        })
        Store.subscribe(self,
                        selector: { $0[self.currency]?.balance != $1[self.currency]?.balance },
                        callback: { state in
                            if let balance = state[self.currency]?.balance {
                                self.balance = balance
                            } })
        
        Store.subscribe(self, selector: { $0[self.currency]?.syncState != $1[self.currency]?.syncState },
                        callback: { state in
                            guard let syncState = state[self.currency]?.syncState else { return }
                            switch syncState {
                            case .connecting:
                                self.isSyncIndicatorVisible = true
                            case .syncing:
                                self.isSyncIndicatorVisible = true
                            case .success:
                                self.isSyncIndicatorVisible = false
                            }
        })
        
        Store.subscribe(self, selector: {
            return $0[self.currency]?.lastBlockTimestamp != $1[self.currency]?.lastBlockTimestamp },
                        callback: { state in
                            if let progress = state[self.currency]?.syncProgress {
                                self.syncView.syncIndicator.progress = CGFloat(progress)
                            }
        })
    }

    private func setCryptoOnlyBalance() {
        let amount = Amount(amount: balance, currency: currency, rate: nil)
        primaryBalance.text = amount.description
        secondaryBalance.isHidden = true
        conversionSymbol.isHidden = true
    }

    func setBalances() {
        guard let rate = exchangeRate else {
            setCryptoOnlyBalance()
            return
        }
        
        if let state = currency.state, let rate = state.rates.first(where: {$0.code == "BTC"})
        {
            // Need to retrieve Satoshi rate
            let satoshiRate = rate.rate * Double(C.satoshis)
            // Displays an extra dighit when under 10 sat
            exchangeRateLabel.text = String(format: S.AccountHeader.exchangeRate, "\(satoshiRate.asRoundedString(digits: satoshiRate < 10 ? 1 : 0)) Sat.", currency.code)
        }
         else
        {
        exchangeRateLabel.text = String(format: S.AccountHeader.exchangeRate, rate.localString, currency.code)
        }
        
        let amount = Amount(amount: balance, currency: currency, rate: rate)
        
        if !hasInitialized {
            primaryBalance.text = amount.tokenDescription
            secondaryBalance.setValue(amount.fiatValue)
            swapLabels()
            hasInitialized = true
        } else {
            if primaryBalance.isHidden {
                primaryBalance.isHidden = false
            }

            if secondaryBalance.isHidden {
                secondaryBalance.isHidden = false
            }
            
            if conversionSymbol.isHidden {
                conversionSymbol.isHidden = false
            }
            
            primaryBalance.text = amount.tokenDescription
            secondaryBalance.setValueAnimated(amount.fiatValue, completion: { [weak self] in
                self?.swapLabels()
            })
        }
    }
    
    private func swapLabels() {
        NSLayoutConstraint.deactivate(isBtcSwapped ? regularConstraints : swappedConstraints)
        NSLayoutConstraint.activate(isBtcSwapped ? swappedConstraints : regularConstraints)
        if isBtcSwapped {
            primaryBalance.makeSecondary()
            secondaryBalance.makePrimary()
        } else {
            primaryBalance.makePrimary()
            secondaryBalance.makeSecondary()
        }
    }

    override func draw(_ rect: CGRect) {
    }

    @objc private func currencySwitchTapped() {
        layoutIfNeeded()
        UIView.spring(0.7, animations: {
            self.primaryBalance.toggle()
            self.secondaryBalance.toggle()
            NSLayoutConstraint.deactivate(!self.isBtcSwapped ? self.regularConstraints : self.swappedConstraints)
            NSLayoutConstraint.activate(!self.isBtcSwapped ? self.swappedConstraints : self.regularConstraints)
            self.layoutIfNeeded()
        }, completion: { _ in })

        Store.perform(action: CurrencyChange.Toggle())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -

private extension UILabel {
    func makePrimary() {
        font = UIFont.customBold(size: largeFontSize)
        textColor = .white
        reset()
    }
    
    func makeSecondary() {
        font = UIFont.customBody(size: largeFontSize)
        textColor = .transparentWhiteText
        shrink()
    }
    
    func shrink() {
        transform = .identity // must reset the view's transform before we calculate the next transform
        let scaleFactor: CGFloat = smallFontSize/largeFontSize
        let deltaX = CGFloat(1.0)//frame.width * (1-scaleFactor)
        let deltaY = frame.height * (1-scaleFactor)
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        transform = scale.translatedBy(x: deltaX, y: -(deltaY/2.0))
    }
    
    func reset() {
        transform = .identity
    }
    
    func toggle() {
        if transform.isIdentity {
            makeSecondary()
        } else {
            makePrimary()
        }
    }
}
