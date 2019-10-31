//
//  AboutViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-04-05.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController {

    private let titleLabel = UILabel(font: .customBold(size: 17.0), color: .white)
    private let logo = UIImageView(image: #imageLiteral(resourceName: "eca_white").withRenderingMode(.alwaysTemplate))
    private let website = AboutCell(text: S.About.website, image: #imageLiteral(resourceName: "website"))
    private let twitter = AboutCell(text: S.About.twitter, image: #imageLiteral(resourceName: "twitter"))
    private let telegram = AboutCell(text: S.About.telegram, image: #imageLiteral(resourceName: "telegram"))
    private let discord = AboutCell(text: S.About.discord, image: #imageLiteral(resourceName: "discord"))
    private let privacy = UIButton(type: .system)
    private let footer = UILabel(font: .customBody(size: 13.0), color: .white)
    override func viewDidLoad() {
        navigationItem.titleView = titleLabel
        addSubviews()
        addConstraints()
        setData()
        setActions()
    }

    private func addSubviews() {
        view.addSubview(logo)
        view.addSubview(website)
        view.addSubview(discord)
        view.addSubview(twitter)
        view.addSubview(telegram)
        view.addSubview(privacy)
        view.addSubview(footer)
    }

    private func addConstraints() {
        logo.contentMode = .scaleAspectFit
        logo.constrain([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: C.padding[4]),
            logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            logo.heightAnchor.constraint(equalTo: logo.widthAnchor, multiplier: logo.image!.size.height/logo.image!.size.width)
            ])
        website.constrain([
            website.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            website.bottomAnchor.constraint(equalTo: discord.topAnchor, constant: C.padding[-2]),
            website.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        discord.constrain([
            discord.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            discord.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            discord.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        twitter.constrain([
            twitter.topAnchor.constraint(equalTo: discord.bottomAnchor, constant: C.padding[2]),
            twitter.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            twitter.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        telegram.constrain([
            telegram.topAnchor.constraint(equalTo: twitter.bottomAnchor, constant: C.padding[2]),
            telegram.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            telegram.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        privacy.constrain([
            privacy.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacy.topAnchor.constraint(equalTo: telegram.bottomAnchor, constant: C.padding[2])])
        footer.constrain([
            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footer.topAnchor.constraint(equalTo: privacy.bottomAnchor) ])
    }

    private func setData() {
        view.layer.contents =  #imageLiteral(resourceName: "Background").cgImage
        logo.tintColor = .darkBackground
        titleLabel.text = S.About.title
        privacy.setTitle(S.About.privacy, for: .normal)
        privacy.titleLabel?.font = UIFont.customBody(size: 13.0)
        privacy.tintColor = .primaryButton
        footer.textAlignment = .center
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            footer.text = String(format: S.About.footer, version, build)
        }
    }

    private func setActions() {
        website.button.tap = strongify(self) { myself in
            myself.presentURL(string: "https://electraproject.org")
        }
        twitter.button.tap = strongify(self) { myself in
            myself.presentURL(string: "https://twitter.com/ElectracoinECA")
        }
        telegram.button.tap = strongify(self) { myself in
            myself.presentURL(string: "https://t.me/Electracoin")
        }
        discord.button.tap = strongify(self) { myself in
            myself.presentURL(string: "https://discord.gg/Dk4b2Tp")
        }
        privacy.tap = strongify(self) { myself in
            myself.presentURL(string: "https://electraproject.org/privacy-policy/")
        }
    }

    private func presentURL(string: String) {
        let vc = SFSafariViewController(url: URL(string: string)!)
        self.present(vc, animated: true, completion: nil)
    }
}
