//
//  CercaniasParser.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 16/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation
import Fuzi

protocol CercaniasParserDelegate: class{
    func didFinishParsing(_ sender: CercaniasParser, data: CercaniasResult?, error: String?)
}

class CercaniasParser: NSObject, URLSessionDelegate {
    
    static let sharedInstance = CercaniasParser()
    var delegate: CercaniasParserDelegate?

    let baseURL = "http://horarios.renfe.com/cer/hjcer310.jsp?"
    
    var originName: String!
    var destinationName: String!
    
    
    var stylesString = "<style type='text/css'> .TA {scrollbar-3dlight-color:#666666; scrollbar-arrow-color:#666666; scrollbar-base-color:#ffffff; scrollbar-darkshadow-color:#ffffff; scrollbar-face-color:#EDEBEB; scrollbar-highlight-color:#ffffff; scrollbar-shadow-color:#666666 } body { font-size:62.5%; margin-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; } #contenedor { height:auto; margin-left:10px; font-size:1em; font-family:Arial, Helvetica, sans-serif; font-weight: normal; text-decoration: none; color: #000000; font-style: normal; } h1 { margin-left:1em; font-size: 1.3em; font-weight: normal; font-family: Arial, Helvetica, sans-serif; text-decoration: none; color: #D2200A; font-style: normal; line-height: 1.2em; font-weight: normal; margin-right: 0.5em; } h2 { margin-left:15px; font-size: 1.2em; font-family: Verdana,Arial, Helvetica, sans-serif; text-decoration: none; color: #666666; font-style: normal; font-weight: normal; } h3 { margin-left:1em; font-size: 1em; font-family: Arial, Helvetica, sans-serif; text-decoration: none; color: #666666; font-style: normal; line-height: 1.2em; font-weight: normal; margin-right: 0.5em; } h4 { margin-left:1em; font-size: 1.2em; font-family: Arial, Helvetica, sans-serif; text-decoration: none; color: #000000; font-style: normal; line-height: 1.2em; font-weight: normal; margin-right: 0.5em; } .caja_texto { BORDER-RIGHT: #cccccc 0.1em solid; BORDER-TOP: #cccccc 1px solid; FONT-SIZE: 0.8em; BORDER-LEFT: #cccccc 1px solid; BORDER-BOTTOM: #cccccc 0.1em solid; FONT-FAMILY: Arial, Helvetica, sans-serif; HEIGHT: 1.5em; BACKGROUND-COLOR: #ffffff } #menuderecho_lineagris { list-style-position: inherit; margin-left: 5px; line-height: 10px; background-image: url('/cer/gif/back_pgris.gif'); } .titulo_rojo { margin-left:1em; font-size: 1.3em; font-weight: normal; font-family: Arial, Helvetica, sans-serif; text-decoration: none; color: #D2200A; font-style: normal; line-height: 1.2em; font-weight: normal; margin-right: 0.5em; } .titulo_negro { margin-left:1em; font-size: 1.1em; font-weight: normal; font-family: Arial, Helvetica, sans-serif; text-decoration: none; color: #000000; font-style: normal; line-height: 1.2em; font-weight: normal; margin-right: 0.5em; } .titulo_gris { margin-left:1em; font-size: 1.3em; font-weight: normal; font-family: Arial, Helvetica, sans-serif; text-decoration: none; color: #666666; font-style: normal; line-height: 1.2em; font-weight: normal; margin-right: 0.5em; } #fondo_caja { background-color:#F2F2F2; height:25px; margin-left:1em; font-size: 1.1em; font-family: Arial, Helvetica, sans-serif; text-decoration: none; color: #000000; font-style: normal; line-height: 1.2em; font-weight: normal; margin-right: 0.5em; } A.linkgris { FONT-SIZE: 1.1em; COLOR: #666666; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-DECORATION: none; line-height:auto; } A.linkgris:hover { FONT-SIZE: 1.1em; COLOR: #D2200A; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-DECORATION: underline; line-height:auto; } .celda_pijama_gris { margin-left:5px; font-size: 0.8em; font-family: Arial, Helvetica, sans-serif; text-decoration: none; color: #666666; font-style: normal; line-height:normal; font-weight: normal; text-align:center; background-color:#F5F6F6; } .celda_txto_negro { margin-left:5px; font-size: 0.9em; font-family: Arial, Helvetica, sans-serif; color: #000000; font-style: normal; line-height: normal; font-weight: normal; text-align:center; } .celda_pijama_negro { margin-left:5px; font-size: 0.9em; font-family: Arial, Helvetica, sans-serif; color: #000000; font-style: normal; line-height: normal; font-weight: normal; text-align:center; background-color:#F5F6F6; } .cabe{ font:0.8em; font-family:Arial, Helvetica, sans-serif; background-color: rgb(193,51,51); color: #FFFFFF; } .rojo {font:10px Arial, Helvetica, sans-serif; color:red; background-color: rgb(191,216,216); } .azul {font:10px Arial, Helvetica, sans-serif; background-color: rgb(191,216,216);} .cabecera2 {font:11pt arial; background-color: rgb(222,219,219); color: black;} .esta {font:10px Arial, Helvetica, sans-serif; background-color: rgb(255,204,204); } .color1 {font:0.7em Arial, Helvetica, sans-serif; background-color: rgb(192,192,192);} .color2 {font:0.7em Arial, Helvetica, sans-serif; background-color: rgb(222,219,219);} .color3 {font:0.7em Arial, Helvetica, sans-serif; background-color:#e0e0e0;} .rojo1 {font:0.7em Arial, Helvetica, sans-serif; color:red; background-color: rgb(192,192,192); } .rojo2 {font:0.7em Arial, Helvetica, sans-serif; color:red; background-color: rgb(192,192,192); } .rojo3 {font:0.7em Arial, Helvetica, sans-serifl; color:red;background-color: rgb(222,219,219); } .gris {font:0.7em Arial, Helvetica, sans-serif; background-color: rgb(192,192,192); } .grismejor {font:0.7em Arial, Helvetica, sans-serif; background-color: rgb(192,192,192); color:yellow; } .azulmejor {font:0.7em Arial, Helvetica, sans-serif; background-color: rgb(191,216,216); color:yellow;} .griso {font:0.7em Arial, Helvetica, sans-serif; background-color: rgb(168,168,168); }</style>"
    
    /*Example:
     http://horarios.renfe.com/cer/hjcer310.jsp?nucleo=10&i=s&cp=NO&o=70103&d=98305&df=20161116&ho=00&hd=26&TXTInfo=
     */
    
    //TODO: Select hour.
    func getEstimatedTime(origin: String, destination: String, originName: String, destinationName: String){
        self.originName = originName
        self.destinationName = destinationName
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let stringDate = formatter.string(from: date)
        
        let dataDict = [
            "nucleo":"10",
            "i":"s",
            "o":origin,
            "d":destination,
            "df": stringDate, //TODO: select day and hour. It will load today by default.
            "ho":"00", //init hour. If it's 00 -> any time
            "hd":"26", //end hour. If it's 26 -> any time
            "TXTInfo":""
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
        request.httpMethod = "GET"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        let session = URLSession(configuration: urlconfig, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            if (data != nil && error == nil){
                do{
                    let doc = try HTMLDocument(data: data!)
                    for script in doc.xpath("//html/body[@class='TA']/div[@id='contenedor']/table"){
                        let htmlString = "<html><head><title></title>\(self.stylesString)</head><body>\(script)</body></html>"
                        
                        let myResult = CercaniasResult(html: "\(htmlString)", origin: self.originName, destination: self.destinationName)
                        self.delegate?.didFinishParsing(self, data: myResult, error: nil)
                        break
                    }
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
