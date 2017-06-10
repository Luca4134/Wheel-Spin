//
//  WordManager.swift
//  WordSelector
//
//  Created by Luca on 6/5/17.
//  Copyright © 2017 Luca. All rights reserved.
//

import UIKit

class WordManager {
    static let sharedInstance = WordManager()
    
    init() {
        guard
            let dictionary = UserDefaults.standard.value(forKey: "wordList")
        else {
            return
        }
        wordDictionary = dictionary as! [String : [String]]
    }
    var wordDictionary: [String : [String]] = [:]
    var currentlySelectedWords: [String] = []
}
