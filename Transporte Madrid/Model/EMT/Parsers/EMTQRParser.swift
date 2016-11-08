//
//  EMTQRParser.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 7/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation
import Fuzi

protocol EMTQRParserDelegate: class{
    func gotStopNumberFromQR(_ sender: EMTQRParser, stopNumber: String?, error: String?)
}

class EMTQRParser: NSObject{
    
    static let sharedInstance = EMTQRParser()
    var delegate: EMTQRParserDelegate?
    
    var currentElement = String()
    
    func getStopNumberFromStringURL(url: String){
        guard let myURL = URL(string: url) else {
            self.delegate?.gotStopNumberFromQR(self, stopNumber: nil, error: "Parece que la URL no es válida")
            return
        }
        
        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            self.parseHTML(code: myHTMLString)
        } catch _ {
           self.delegate?.gotStopNumberFromQR(self, stopNumber: nil, error: "Ha habido un problema con el QR. Por favor, vuelve a intentarlo.")
           return
        }
    }
    
    func parseHTML(code: String){
        do {
            // if encoding is omitted, it defaults to NSUTF8StringEncoding
            let doc = try HTMLDocument(string: code, encoding: String.Encoding.utf8)
            
            // XPath query to find it
            let xpathQuery = "/html/body[@class='body-sticky']/div[@class='wrap wrap-sticky']/div[@class='slider-menu-container']/div[@class='content']/div[@id='sliderVertical']/div[@class='slider-td-slide']/div[@id='slider-swipe-area']/div[@class='btn-slider-vertical-map']/div[@class='header-sd-default']/h1/span[@class='header-sd-title']/text()"
            let result = doc.xpath(xpathQuery)
            if (result.count == 0){
                self.delegate?.gotStopNumberFromQR(self, stopNumber: nil, error: "Parece que el QR no es válido.")
                return
            }
            
            let myCompleteString = result[0].stringValue
            let array = myCompleteString.components(separatedBy: " - ")
            let myNumber = array[0]
            self.delegate?.gotStopNumberFromQR(self, stopNumber: myNumber, error: nil)
        } catch let error {
            print(error)
        }
    }
}
