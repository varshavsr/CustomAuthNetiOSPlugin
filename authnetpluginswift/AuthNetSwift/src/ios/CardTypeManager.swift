//
//  CardTypeManager.swift
//  AuthorizeNetSwift
//
//  Created by varsha s rao on 04/06/18.
//  Copyright © 2018 Sonata-Software. All rights reserved.
//

import Foundation

/*Regex reference: https://www.regular-expressions.info/creditcard.html
 For JCB actual validation rule is "^(?:2131|1800|35\d{3})\d{11}$" as the \d character presence makes json response invalid, I have escaped with \\d which has to be decoded while parsing.
 */
struct CardTypeData: Codable {
    var cardTypes: [CardTypes]?
    
    enum CodingKeys: String, CodingKey {
        case cardTypes = "CardTypes"
    }
}

struct CardTypes: Codable {
    let idType: String?
    let idTypeCode: Int?
    let validationRule: String?
    
    enum CodingKeys: String, CodingKey {        
        case idType = "IdType"
        case idTypeCode = "IdTypeCode"
        case validationRule = "ValidationRule"
    }
}

class CardTypeManager {
    var cardTypeData: CardTypeData?
    static let shared = CardTypeManager()
    init() {
        //Updating cardTypeData fromjson to obj
        let jsonRequestData = loadOfflineAsData(fileName: "CardTypesData")
        do{
            let jsonDecoder = JSONDecoder()
            self.cardTypeData  = try jsonDecoder.decode(CardTypeData.self, from: jsonRequestData)
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
