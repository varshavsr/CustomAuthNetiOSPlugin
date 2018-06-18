//
//  Utilities.swift
//  AuthorizeNetSwift
//
//  Created by varsha s rao on 04/06/18.
//  Copyright © 2018. All rights reserved.
//

import Foundation

func loadOfflineAsData(fileName: String) -> Data {
    if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            return data
        } catch let error {
            print(error.localizedDescription)
        }
    }
    return Data()
}
