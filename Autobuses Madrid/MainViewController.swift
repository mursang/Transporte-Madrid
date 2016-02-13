//
//  MainViewController.swift
//  Autobuses Madrid
//
//  Created by Angel Sans Muro on 13/2/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit

class MainViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var textfieldParada: UITextField!
    //init parser
    let timeParser:TimeParser = TimeParser.sharedInstance
    
    var arrayData:NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //notificacion para cuando el parser ha terminado
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "parserEnded:",
            name: "parserEnded",
            object: nil)
        
        textfieldParada.delegate = self

        
        //para abrir el menú lateral
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
    //método que se llama desde TimeParser cuando termina el parseo
    func parserEnded(notification: NSNotification){
        
        let dicTemp:NSDictionary = notification.userInfo!
        let array:NSArray = dicTemp["info"] as! NSArray
        arrayData = array
        self.performSegueWithIdentifier("detailSegue", sender: self)
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
        
        //llamamos al parser con el numero de parada
        //TODO: PONER UN CARGANDO
        timeParser.calculaTiempos(numeroParada)
        
        
        return true
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
        }
    }


}
