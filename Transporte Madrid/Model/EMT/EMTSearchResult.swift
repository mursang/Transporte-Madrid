//
//  EMTSearchResult.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 4/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation

class EMTSearchResult {
    
    var destination: String!
    var idLine: String!
    var timeLeftBus: String!
    var timeInSeconds: Int!
    
    init(destination: String, idLine:String, timeLeftBus: String){
        self.destination = destination
        self.idLine = idLine
        self.timeInSeconds = Int(timeLeftBus)
        parseTime(time: timeLeftBus)
    }
    
    //aux function to convert seconds to human-readable text
    func parseTime(time: String){
        let seconds = Int(time)
        let minutes = Int(round(Double(seconds!/60)))
        
        if (minutes > 20){
            self.timeLeftBus = "> 20 minutos"
        }else if(minutes == 1){
            self.timeLeftBus = "\(minutes) minuto"
        }else if(minutes == 0){
            self.timeLeftBus = "Autobús cerca de parada"
        }else{
            self.timeLeftBus = "\(minutes) minutos"
        }
    }
    
}
