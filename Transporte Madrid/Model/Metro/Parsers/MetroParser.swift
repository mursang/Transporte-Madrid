//
//  MetroParser.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 13/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation
import Fuzi

protocol MetroParserDelegate: class{
    func didFinishParsing(_ sender: MetroParser, data: MetroResult?, error: String?)
}

class MetroParser: NSObject, URLSessionDelegate {
    
    static let sharedInstance = MetroParser()
     var delegate: MetroParserDelegate?
    
    let baseURL = "https://www.metromadrid.es/es/viaja_en_metro/trayecto_recomendado/resultado.html?"
    
    var originName: String!
    var destinationName: String!
    
    func getMetroData(idOrigin: String, idDestination: String, originName: String, destinationName: String){
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
            "vhreshold":"15285171",
            "_vmsro_":"511465053",
            "vmesro":"16401"
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
        self.makeConnection(url: myFinalURL)
    }
    
    func makeConnection(url: String){
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForRequest = 10
        urlconfig.timeoutIntervalForResource = 20

        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.setValue("https://www.metromadrid.es/es/index.html", forHTTPHeaderField: "Referer")
        request.httpMethod = "GET"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            if (data != nil && error == nil){
                do{
                    let doc = try HTMLDocument(data: data!)
                    
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
            }else{
                self.delegate?.didFinishParsing(self, data: nil, error: "UPS! Algo ha fallado.. Vuelve a intentarlo.")
                return
            }
        })
        task.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    

}
