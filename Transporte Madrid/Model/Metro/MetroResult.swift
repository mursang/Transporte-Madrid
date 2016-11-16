//
//  MetroResult.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 13/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation

class MetroResult: NSObject, NSCoding {
    
    var estimatedTime: String!
    var indications: [String]!
    var origin: String!
    var destination: String!
    
    required init?(coder aDecoder: NSCoder) {
        self.estimatedTime = aDecoder.decodeObject(forKey: "estimatedTime") as? String
        self.indications = aDecoder.decodeObject(forKey: "indications") as? [String]
        self.origin = aDecoder.decodeObject(forKey: "origin") as? String
        self.destination = aDecoder.decodeObject(forKey: "destination") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.estimatedTime!, forKey: "estimatedTime")
        aCoder.encode(self.indications!, forKey: "indications")
        aCoder.encode(self.origin!, forKey: "origin")
        aCoder.encode(self.destination!, forKey: "destination")
    }
    
    
    init(estimatedTime: String, indications: [String], origin: String, destination: String){
        self.estimatedTime = estimatedTime
        self.indications = indications
        self.origin = origin
        self.destination = destination
    }
    
    
    
}
