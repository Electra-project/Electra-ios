//
//  CoinGeckoApiHelper.swift
//  electrawallet
//
//  Created by ECA Caribou on 27/09/2019.
//  Copyright © 2019 Electra Foundation. All rights reserved.
//

import Foundation


// MARK: - CoingeckoResult
struct CoingeckoResult: Codable {
    let name: String?
    let tickers: [CGHTicker]?
}

// MARK: - Ticker
struct CGHTicker: Codable {
    let base: CGHBase?
    let target: String?
    let market: CGHMarket?
    let last, volume: Double?
    let convertedLast, convertedVolume: [String: Double]?
    let trustScore: String?
    let bidAskSpreadPercentage: Double?
    let timestamp, lastTradedAt, lastFetchAt: Date?
    let isAnomaly, isStale: Bool?
    let tradeURL: String?
    let coinID: CGHCoinID?
    
    enum CodingKeys: String, CodingKey {
        case base, target, market, last, volume
        case convertedLast = "converted_last"
        case convertedVolume = "converted_volume"
        case trustScore = "trust_score"
        case bidAskSpreadPercentage = "bid_ask_spread_percentage"
        case timestamp
        case lastTradedAt = "last_traded_at"
        case lastFetchAt = "last_fetch_at"
        case isAnomaly = "is_anomaly"
        case isStale = "is_stale"
        case tradeURL = "trade_url"
        case coinID = "coin_id"
    }
}

enum CGHBase: String, Codable {
    case eca = "ECA"
}

enum CGHCoinID: String, Codable {
    case electra = "electra"
}

// MARK: - Market
struct CGHMarket: Codable {
    let name, identifier: String?
    let hasTradingIncentive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name, identifier
        case hasTradingIncentive = "has_trading_incentive"
    }
}

// MARK: - Helper functions for creating encoders and decoders
class CGHelper
{
    static func newJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        return decoder
    }
    
    static func newJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            encoder.dateEncodingStrategy = .iso8601
        }
        return encoder
}


}
