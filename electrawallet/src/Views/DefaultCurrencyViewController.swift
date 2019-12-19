//
//  DefaultCurrencyViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-04-06.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit
import BRCore

class DefaultCurrencyViewController: UITableViewController, Subscriber, Trackable {

    init() {
        self.rates = Currencies.btc.state?.rates.filter { $0.code != Currencies.btc.code } ?? [Rate]()
        super.init(style: .plain)
    }

    private let cellIdentifier = "CellIdentifier"
    private var rates: [Rate] = [] {
        didSet {
            tableView.reloadData()
            setExchangeRateLabel()
        }
    }
    private var defaultCurrencyCode: String? = nil {
        didSet {
            //Grab index paths of new and old rows when the currency changes
            let paths: [IndexPath] = rates.enumerated().filter { $0.1.code == defaultCurrencyCode || $0.1.code == oldValue } .map { IndexPath(row: $0.0, section: 0) }
            tableView.beginUpdates()
            tableView.reloadRows(at: paths, with: .automatic)
            tableView.endUpdates()

            setExchangeRateLabel()
        }
    }

    private let bitcoinLabel = UILabel(font: .customBold(size: 14.0), color: .white)
    private let bitcoinSwitch = UISegmentedControl(items: ["Bits (\(S.Symbols.bits))", "BTC (\(S.Symbols.btc))"])
    private let rateLabel = UILabel(font: .customBody(size: 16.0), color: .white)
    private var header: UIView?

    deinit {
        Store.unsubscribe(self)
    }

    override func viewDidLoad() {
        tableView.register(ThinSeparatorCell.self, forCellReuseIdentifier: cellIdentifier)
        Store.subscribe(self, selector: { $0.defaultCurrencyCode != $1.defaultCurrencyCode }, callback: {
            self.defaultCurrencyCode = $0.defaultCurrencyCode
        })
        Store.subscribe(self, selector: { $0[Currencies.btc]?.maxDigits != $1[Currencies.btc]?.maxDigits }, callback: { _ in
            self.setExchangeRateLabel()
        })

        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 140.0
        tableView.separatorStyle = .none
        view.layer.contents =  #imageLiteral(resourceName: "Background").cgImage

        let titleLabel = UILabel(font: .customBold(size: 17.0), color: .white)
        titleLabel.text = S.Settings.currency
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        let faqButton = UIButton.buildFaqButton(articleId: ArticleIds.displayCurrency, currency: Currencies.btc)
        faqButton.tintColor = .navigationTint
        //navigationItem.rightBarButtonItems = [UIBarButtonItem.negativePadding, UIBarButtonItem(customView: faqButton)]
        bitcoinSwitch.tintColor = .navigationTint
    }

    private func setExchangeRateLabel() {
        if let currentRate = rates.filter({ $0.code == defaultCurrencyCode }).first {
            let amount = Amount(amount: UInt256(C.satoshis), currency: Currencies.btc, rate: currentRate, minimumFractionDigits: 0, maximumFractionDigits: Amount.highPrecisionDigits)
            rateLabel.textColor = .white
            let rate = Double(truncating: amount.fiatValue as NSNumber)
            rateLabel.text = "\(amount.tokenDescription) = \(rate.stringWithSignificantDigit()) \(currentRate.code)"
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let rate = rates[indexPath.row]
        cell.textLabel?.text = "\(rate.code) (\(rate.currencySymbol))"
        cell.textLabel?.font = UIFont.customBody(size: 14.0)
        cell.textLabel?.textColor = .white
        if rate.code == defaultCurrencyCode {
            let check = UIImageView(image: #imageLiteral(resourceName: "CircleCheck").withRenderingMode(.alwaysTemplate))
            check.tintColor = .white
            cell.accessoryView = check
        } else {
            cell.accessoryView = nil
        }
        cell.contentView.backgroundColor = .transparent
        cell.backgroundColor = .transparent
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = self.header { return header }

        let header = UIView(color: .transparent)
        let rateLabelTitle = UILabel(font: .customBold(size: 14.0), color: .white)

        header.addSubview(rateLabelTitle)
        header.addSubview(rateLabel)

        rateLabelTitle.constrain([
            rateLabelTitle.topAnchor.constraint(equalTo: header.topAnchor, constant: C.padding[2]),
            rateLabelTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor)])
        rateLabel.constrain([
            rateLabel.topAnchor.constraint(equalTo: rateLabelTitle.bottomAnchor, constant: C.padding[0]),
            rateLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -C.padding[2]),
            rateLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor)])

        rateLabelTitle.text = S.DefaultCurrency.rateLabel

        self.header = header
        return header
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rate = rates[indexPath.row]
        Store.perform(action: DefaultCurrency.SetDefault(rate.code))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
