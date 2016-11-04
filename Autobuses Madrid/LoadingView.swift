//
//  LoadingView.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 4/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation
import NVActivityIndicatorView


class LoadingView {
    
    var myLoadingView: NVActivityIndicatorView?
    static let sharedInstance = LoadingView()
    var controller: UIViewController?
    
    init(){
        myLoadingView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), type: .ballPulseSync, color: UIColor(red: Constants.BlueColor.red/255.0,green:Constants.BlueColor.green/255.0,blue: Constants.BlueColor.blue/255.0, alpha:1.0), padding: 0)
    }
    
    func show(onViewController: UIViewController){
        self.controller = onViewController
        let loadingViewWidth = onViewController.view.bounds.size.width/4
        
        myLoadingView!.frame = CGRect(x: onViewController.view.bounds.size.width/2-loadingViewWidth/2, y: onViewController.view.bounds.size.height/2-loadingViewWidth/2, width: loadingViewWidth, height: loadingViewWidth)
        onViewController.view.addSubview(myLoadingView!)
        onViewController.view.isUserInteractionEnabled = false
    }
    
    func hide(){
        myLoadingView!.stopAnimating()
        myLoadingView!.removeFromSuperview()
        self.controller?.view.isUserInteractionEnabled = true
    }
}
