//
//  EMTQRCustomView.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 8/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import Foundation
import QRCodeReader

class EMTQRCustomView: UIView, QRCodeReaderDisplayable {
    lazy var overlayView: UIView = {
        let ov = ReaderOverlayView()
        ov.backgroundColor                           = .clear
        ov.clipsToBounds                             = true
        ov.translatesAutoresizingMaskIntoConstraints = false
        return ov
    }()
    
    let cameraView: UIView = {
        let cv = UIView()
        cv.clipsToBounds                             = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        return cv
    }()
    
    lazy var cancelButton: UIButton? = {
        let cb = UIButton()
        cb.translatesAutoresizingMaskIntoConstraints = false
        cb.setTitleColor(.gray, for: .highlighted)
        return cb
    }()
    lazy var switchCameraButton: UIButton? = {
        let scb = SwitchCameraButton()
        scb.translatesAutoresizingMaskIntoConstraints = false
        return scb
    }()

    lazy var toggleTorchButton: UIButton? = {
        let ttb = ToggleTorchButton()
        
        ttb.translatesAutoresizingMaskIntoConstraints = false
        ttb.setImage(UIImage(named: "flash_off"), for: .normal)
        ttb.setImage(UIImage(named: "flash_on"), for: .selected)
        ttb.addTarget(self, action: #selector(torchAction), for: .touchUpInside)
        return ttb
    }()
    
    func torchAction(sender: UIButton){
        sender.isSelected = !sender.isSelected
    }
    
    
    func setupComponents(showCancelButton: Bool, showSwitchCameraButton: Bool, showTorchButton: Bool) {
        translatesAutoresizingMaskIntoConstraints = false
        
        addComponents()
        
        cancelButton?.isHidden       = !showCancelButton
        switchCameraButton?.isHidden = !showSwitchCameraButton
        toggleTorchButton?.isHidden  = !showTorchButton
        
        guard let cb = cancelButton, let scb = switchCameraButton, let ttb = toggleTorchButton else { return }
        
        let views = ["cv": cameraView, "ov": overlayView, "cb": cb, "scb": scb, "ttb": ttb]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cv]|", options: [], metrics: nil, views: views))
        
        if showCancelButton {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cv][cb(40)]|", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[cb]-|", options: [], metrics: nil, views: views))
        }
        else {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cv]|", options: [], metrics: nil, views: views))
        }
        
        if showSwitchCameraButton {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scb(50)]", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[scb(70)]|", options: [], metrics: nil, views: views))
        }
        
        if showTorchButton {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[ttb(50)]", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[ttb(70)]", options: [], metrics: nil, views: views))
        }
        
        for attribute in Array<NSLayoutAttribute>([.left, .top, .right, .bottom]) {
            addConstraint(NSLayoutConstraint(item: overlayView, attribute: attribute, relatedBy: .equal, toItem: cameraView, attribute: attribute, multiplier: 1, constant: 0))
        }
    }
    
    private func addComponents() {
        addSubview(cameraView)
        addSubview(overlayView)
        
        if let scb = switchCameraButton {
            addSubview(scb)
        }
        
        if let ttb = toggleTorchButton {
            addSubview(ttb)
        }
        
        if let cb = cancelButton {
            addSubview(cb)
        }
    }
}
