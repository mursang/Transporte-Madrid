//
//  ErrorView.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 7/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation

class ErrorView {
    var viewController: UIViewController?
    var alert: UIAlertController?
    
    init(title: String, message: String, viewController: UIViewController){
        alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert!.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
        self.viewController = viewController
    }
    
    func show(){
        self.viewController!.present(self.alert!, animated: true, completion: nil)
    }
    
}
