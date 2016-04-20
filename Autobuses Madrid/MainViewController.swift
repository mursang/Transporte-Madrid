//
//  MainViewController.swift
//  Autobuses Madrid
//
//  Created by Angel Sans Muro on 13/2/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MainViewController: UIViewController,UITextFieldDelegate, BusesTimeParserDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var textfieldParada: UITextField!
    //init parser
    let timeParser:TimeParser = TimeParser.sharedInstance
    
    var arrayData:NSArray = NSArray()
    
    var loadingView: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timeParser.delegate = self
        textfieldParada.delegate = self

        let loadingViewWidth = self.view.bounds.size.width/4
        loadingView = NVActivityIndicatorView(frame: CGRectMake(self.view.bounds.size.width/2-loadingViewWidth/2, self.view.bounds.size.height/2-loadingViewWidth/2, loadingViewWidth, loadingViewWidth), type: .BallPulseSync, color: UIColor(red: Constants.BlueColor.red/255.0,green:Constants.BlueColor.green/255.0,blue: Constants.BlueColor.blue/255.0, alpha:1.0), padding: 0)
        self.view.addSubview(loadingView!)
        
        //para abrir el menú lateral
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textfieldParada.resignFirstResponder()
        if let text = textfieldParada.text where text.isEmpty
        {
            //el textfield esta vacio
            print("ERROR, EL TEXTFIELD ESTÁ VACÍO")
            return true
        }
        
        let numeroParada: String = textfieldParada.text!
        
        //cargando..
        loadingView?.startAnimation()
        
        //llamamos al parser con un pequeño delay, para que de tiempo al loadingView a ponerse.
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
             self.timeParser.calculaTiempos(numeroParada)
        }
        
        return true
    }
    
    
    /* Time Parser Delegate*/
    //Una vez el parseo termina, hacemos el segue a la vista de detalle.
    func didFinishParsing(sender: TimeParser, data: NSArray) {
        loadingView?.stopAnimation()
        arrayData = data;

        if (data.count == 0){
            //TODO: Mostrar error.
            return;
        }
        self.performSegueWithIdentifier("detailSegue", sender: self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier! as NSString).isEqual("detailSegue"){
            //pasamos el array de datos.
            
            let vc:DetailTableViewController = segue.destinationViewController as! DetailTableViewController
            vc.arrayData = arrayData
            vc.numParada = textfieldParada.text
        }
    }


}
