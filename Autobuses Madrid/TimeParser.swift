//
//  TimeParser.swift
//  Autobuses Madrid
//
//
//  Clase Singleton que parsea los tiempos de los autobuses dado un id de parada
//  A través del delegate, se puede detectar la finalización del parseo y el array resultado
//
//
//  Created by Angel Sans Muro on 13/2/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit

protocol BusesTimeParserDelegate: class{
    func didFinishParsing(sender: TimeParser, data: NSArray)
}

class TimeParser: NSObject, NSXMLParserDelegate {
    
    var delegate: BusesTimeParserDelegate?
    
    static let sharedInstance = TimeParser()
    
    let serviceClient = Constants.TimeParser.serviceClient
    let passKey = Constants.TimeParser.passKey
    let serviceURL = "https://servicios.emtmadrid.es:8443/geo/servicegeo.asmx/"
    
    //servicio que vamos a usar. En este parser, el tiempo que le queda al autobús.
    let serviceDetail = "getArriveStop?"
    
    //Diccionario con todos los datos parseados.
    var elements: NSMutableDictionary
    //Array para almacenar los diccionarios de datos parseados
    var arrayFinal: NSMutableArray
    
    //Elemento siendo parseado
    var element = NSString()
    //Datos:
    var idLine = NSMutableString()
    var destination = NSMutableString()
    var timeLeftBus = NSMutableString()
    
    override init(){
        elements = NSMutableDictionary()
        arrayFinal = NSMutableArray()
    }
    
    
    func calculaTiempos(numeroParada: String){
        //conformamos la URL para realizar la llamada al servicio:
        //GET /geo/servicegeo.asmx/getArriveStop?idClient=string&passKey=string&idStop=string&statistics=string&cultureInfo=string
        let URLFinal = serviceURL+serviceDetail+"idClient="+serviceClient+"&passKey="+passKey+"&idStop="+numeroParada+"&statistics=&cultureInfo="
        
        //limpiamos array
        arrayFinal = []
        //realizamos la conexión y el parseo:
        let parser = NSXMLParser(contentsOfURL: NSURL(string: URLFinal)!)
        parser?.delegate = self
        parser?.parse()
        
    }
    
    

    // - Detecto el inicio del elemento "Arrive"
    // - Parseo su contenido y almaceno
    // - Detecto el final del elemento "Arrive"
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        //actualizamos el elemento siendo parseado
        element = elementName
        if ((elementName as NSString).isEqualToString("Arrive")){
            elements = [:]
            idLine = ""
            destination = ""
            timeLeftBus = ""
        }
        
        
    }
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        //Nos interesan los campos:
        // - idLine
        // - Destination
        // - TimeLeftBus
        
        //Opcionales (para mejoras): PositionXBus, PositionYBus, IdBus, DistanceBus
        if element.isEqualToString("idLine"){
            idLine.appendString(clearString(string))
        }else if element.isEqualToString("Destination"){
            destination.appendString(clearString(string))
        }else if element.isEqualToString("TimeLeftBus"){
            timeLeftBus.appendString(clearString(string))
        }
    }
    
    //esta función sirve para limpiar los string parseados.
    //esto es, quitar los "\n" y los espacios.
    func clearString(string:String)->String{
        //quitamos espacios
        var trimmedString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        //quitamos "\n"
        trimmedString = trimmedString.stringByReplacingOccurrencesOfString("\n", withString: "")
        
        return trimmedString
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if ((elementName as NSString).isEqualToString("Arrive")){
            if idLine.isEqual(nil){
                idLine = ""
            }
            if destination.isEqual(nil){
                destination = ""
            }
            if timeLeftBus.isEqual(nil){
                timeLeftBus = ""
            }
            
            //guardamos los elementos
            elements.setObject(idLine, forKey: "idLine")
            elements.setObject(destination, forKey: "destination")
            elements.setObject(timeLeftBus, forKey: "timeLeftBus")
            
            //guardamos los elementos en el array final para manejarlo.
            arrayFinal.addObject(elements)
        }
        
        
    }
    
    
    //notificamos al delegate de que el parseo ha terminado y pasamos el array con resultados
    func parserDidEndDocument(parser: NSXMLParser) {
        delegate?.didFinishParsing(self, data: arrayFinal)
    }

    
    
    
}

