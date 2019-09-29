//
//  Double+Extensions.swift
//  electrawallet
//
//  Created by ECA Caribou on 27/09/2019.
//  Copyright © 2019 Electra Foundation. All rights reserved.
//

import Foundation

extension Double {
    func asRoundedString(digits: Int = 8) -> String
    {
        let number = NumberFormatter()
        number.numberStyle = .decimal
        number.minimumFractionDigits = digits
        number.maximumFractionDigits = digits
        number.roundingMode = .halfEven
        return number.string(from: NSNumber(value: self)) ?? "0.0"
    }
}
