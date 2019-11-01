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
    
    func stringWithSignificantDigit(significantDigit: Int = 2) -> String
    {
        if(self >= 1.0)
        {
            return asRoundedString(digits: 2)
        }
        let number = NumberFormatter()
        number.usesSignificantDigits = true
        number.minimumFractionDigits = 2
        number.maximumSignificantDigits = significantDigit
        number.roundingMode = .halfEven
        return number.string(from: NSNumber(value: self)) ?? "0.0"
    }
}
