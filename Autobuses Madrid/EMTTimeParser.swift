//
//  EMTTimeParser.swift
//  Autobuses Madrid
//
//  Class that parses the time from EMT buses given a stop id.
//  We will pass to the delegate the parser's result.
//
//
//  Created by Angel Sans Muro on 13/2/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit

protocol EMTParserDelegate: class{
    func didFinishParsing(_ sender: EMTTimeParser, data: [EMTSearchResult])
}

class EMTTimeParser: NSObject, XMLParserDelegate {
    
    var delegate: EMTParserDelegate?
    
    static let sharedInstance = EMTTimeParser()
    
    let serviceClient = Constants.TimeParser.serviceClient
    let passKey = Constants.TimeParser.passKey
    let serviceURL = Constants.TimeParser.serviceURL
    
    //We are going to use the arrive stop service in this parser.
    let serviceDetail = "getArriveStop?"
    
    var elements: [EMTSearchResult]
    
    var currentElement = String()

    var idLine = String()
    var destination = String()
    var timeLeftBus = String()

    override init(){
        elements = [EMTSearchResult]()
    }
    
    func getArriveTimes(_ stopNumber: String){
        //GET /geo/servicegeo.asmx/getArriveStop?idClient=string&passKey=string&idStop=string&statistics=string&cultureInfo=string
        let finalURL = serviceURL+serviceDetail+"idClient="+serviceClient+"&passKey="+passKey+"&idStop="+stopNumber+"&statistics=&cultureInfo="
        
        let parser = XMLParser(contentsOf: URL(string: finalURL)!)
        parser?.delegate = self
        parser?.parse()
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        currentElement = elementName as String
        if ((elementName as String).isEqual("Arrive")){
            idLine = ""
            destination = ""
            timeLeftBus = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // - idLine
        // - Destination
        // - TimeLeftBus
        
        //Optional (to do): PositionXBus, PositionYBus, IdBus, DistanceBus
        if currentElement.isEqual("idLine"){
            idLine.append(clearString(string))
        }else if currentElement.isEqual("Destination"){
            destination.append(clearString(string))
        }else if currentElement.isEqual("TimeLeftBus"){
            timeLeftBus.append(clearString(string))
        }
    }
    
    //Aux func
    func clearString(_ string:String)->String{
        var trimmedString = string.trimmingCharacters(in: CharacterSet.whitespaces)
        trimmedString = trimmedString.replacingOccurrences(of: "\n", with: "")
        return trimmedString
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if ((elementName as NSString).isEqual(to: "Arrive")){
            if idLine.isEqual(nil){
                idLine = ""
            }
            if destination.isEqual(nil){
                destination = ""
            }
            if timeLeftBus.isEqual(nil){
                timeLeftBus = ""
            }
            
            let myResult = EMTSearchResult(destination: destination, idLine: idLine, timeLeftBus: timeLeftBus)
            elements.append(myResult)
        }
    }
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        delegate?.didFinishParsing(self, data: elements)
    }

    
    
    
}

