//
//  MetroParser.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 13/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation
import Fuzi
import WebKit

protocol MetroParserDelegate: class{
    func didFinishParsing(_ sender: MetroParser, data: MetroResult?, error: String?)
}

class MetroParser: NSObject, URLSessionDelegate, WKNavigationDelegate {
    
    static let sharedInstance = MetroParser()
     var delegate: MetroParserDelegate?
    
    let baseURL = "https://www.metromadrid.es/es/viaja_en_metro/trayecto_recomendado/resultado.html?"
    
    var originName: String!
    var destinationName: String!
    
    var specialChar: String?
    var specialValue: String?

    
    override init(){
        super.init()
    }
    
    //we need this special char, that changes over time, in order to make connections to metro's webpage.
    func getSpecialChar(withHTML: String){
                do{
                    let doc = try HTMLDocument(string: withHTML, encoding: .utf8)
                    // XPath query to get indications and time
                    for script in doc.xpath("//html/body/div[@id='contenedora']/div[@id='contenido']/div[@id='col1']/div[@class='bloq_fotos']/div[@class='dos2']/div[@class='acotacion2']/div[@class='origen_dest']/form/fieldset[@class='destino']/div[@class='clear'][5]/input[@type='hidden'][2]") {
                        self.specialChar = script.attr("name")!
                        self.specialValue = script.attr("value")!
                    }
                }catch let error{
                    print(error.localizedDescription)
        }
    }
    
    func getMetroData(idOrigin: String, idDestination: String, originName: String, destinationName: String, webView: WKWebView){
        if (self.specialValue == nil || self.specialChar == nil){
            self.delegate?.didFinishParsing(self, data: nil, error: "UPS! Inténtalo de nuevo. Ha habido un problema conéctandonos con el servidor.")
            return
        }
        
        webView.navigationDelegate = self
        
        
        self.originName = originName
        self.destinationName = destinationName
        /*
         https://www.metromadrid.es/es/viaja_en_metro/trayecto_recomendado/resultado.html?rbOrigen=estacion&idOrigen=1102&calle=+Introduce+una+calle...&numeroOrigen=n%C2%BA&cmbCiudadOrigen=Madrid&lugar=+Introduce+un+lugar...&rbDestino=estacion&idDestino=519&calle2=+Introduce+una+calle...&numeroDestino=n%C2%BA&cmbCiudadDestino=Madrid&lugar2=+Introduce+un+lugar...&Simple=0&vimplemas=15609&buscar=Buscar
         */
        let dataDict = [
            "rbOrigen":"estacion",
            "idOrigen":idOrigin,
            "cmbCiudadOrigen":"Madrid",
            "rbDestino":"estacion",
            "idDestino":idDestination,
            "cmbCiudadDestino":"Madrid",
            "Simple":"0",
            "buscar":"Buscar",
            "calle":"+Introduce+una+calle...",
            "numeroOrigen":"n%C2%BA",
            "lugar":"+Introduce+un+lugar...",
            "calle2":"+Introduce+una+calle...",
            "numeroDestino":"n%C2%BA",
            "lugar2":"+Introduce+un+lugar...",
            "\(self.specialChar!)":"\(self.specialValue!)"
        ]
        
        var myFinalURL = baseURL
        var first:Bool = true
        for key in dataDict{
            if (first){
                myFinalURL = "\(myFinalURL)\(key.key)=\(dataDict[key.key]!)"
            }else{
               myFinalURL = "\(myFinalURL)&\(key.key)=\(dataDict[key.key]!)"
            }
            first = false
        }
        
        // we need Javascript here too, so we need to load the request on the webview.
        let request = NSMutableURLRequest(url: URL(string: myFinalURL)!)
        request.setValue("https://www.metromadrid.es/es/index.html", forHTTPHeaderField: "Referer")
        request.httpMethod = "GET"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        webView.load(request as URLRequest)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.innerHTML", completionHandler: {result, error in
            self.parse(returnedHTML: result as! String)
        })
    }
    
    func parse(returnedHTML: String){
                do{
                    let doc = try HTMLDocument(string: returnedHTML, encoding: .utf8)
                    //let doc = try HTMLDocument(data: data!)
                    var indicationsArray = [String]()
                    
                    // XPath query to get indications and time
                    for script in doc.xpath("//html/body/div[@id='contenedora']/div[@id='contenido']/div[@class='trayecto_det'][2]/div[@class='dcha impresionDescripcionTrayecto']/ul[2]/li/strong") {
                        var string = script.stringValue
                        string = string.replacingOccurrences(of: "<strong>", with: "")
                        string = string.replacingOccurrences(of: "</strong>", with: "")
                        indicationsArray.append(string)
                    }
                    if (indicationsArray.count == 0){
                        self.delegate?.didFinishParsing(self, data: nil, error: "UPS! Algo ha fallado.. Vuelve a intentarlo.")
                        return
                    }
                    let timeLeft = indicationsArray.last!
                    indicationsArray.removeLast()
                    let myObject = MetroResult(estimatedTime: timeLeft, indications: indicationsArray, origin: self.originName, destination: self.destinationName)
                    self.delegate?.didFinishParsing(self, data: myObject, error: nil)
                }catch let error{
                    print(error)
                }
    }
}
