//
//  CercaniasResult.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 16/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation

class CercaniasResult: NSObject, NSCoding {
    
    var htmlString: String!
    var origin: String!
    var destination: String!
    
    required init?(coder aDecoder: NSCoder) {
        self.htmlString = aDecoder.decodeObject(forKey: "html") as? String
        self.origin = aDecoder.decodeObject(forKey: "origin") as? String
        self.destination = aDecoder.decodeObject(forKey: "destination") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.htmlString!, forKey: "html")
        aCoder.encode(self.origin!, forKey: "origin")
        aCoder.encode(self.destination!, forKey: "destination")
    }

    
    init(html: String, origin: String, destination: String){
        self.htmlString = html
        self.origin = origin
        self.destination = destination
    }

    
}
