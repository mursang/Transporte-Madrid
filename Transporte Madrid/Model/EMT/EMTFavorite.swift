//
//  EMTFavorite.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 7/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation

class EMTFavorite: NSObject, NSCoding {
    
    var stopNumber: String?
    var linesArray: [String]?
    
    required init?(coder aDecoder: NSCoder) {
        self.stopNumber = aDecoder.decodeObject(forKey: "stopNumber") as? String
        self.linesArray = aDecoder.decodeObject(forKey: "linesArray") as? [String]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.stopNumber!, forKey: "stopNumber")
        aCoder.encode(self.linesArray!, forKey: "linesArray")
    }
    
    init(stopNumber: String, linesArray: [String]){
        self.stopNumber = stopNumber
        self.linesArray = linesArray
    }

}
