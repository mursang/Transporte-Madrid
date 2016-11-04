//
//  EMTViewController.swift
//  Autobuses Madrid
//
//  Created by Angel Sans Muro on 13/2/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class EMTViewController: UIViewController, UITextFieldDelegate, EMTParserDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var textfieldParada: UITextField!
    
    //init parser
    let timeParser: EMTTimeParser = EMTTimeParser.sharedInstance
    let loadingView: LoadingView = LoadingView.sharedInstance
    
    var arrayData = [EMTSearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timeParser.delegate = self
        textfieldParada.delegate = self
        
        //lateral menu
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfieldParada.resignFirstResponder()
        if let text = textfieldParada.text , text.isEmpty
        {
            return true
        }
        
        let numeroParada: String = textfieldParada.text!
        
        loadingView.show(onViewController: self)
        
        //let's call parser with a small delay, to let loadingView show.
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.timeParser.getArriveTimes(numeroParada)
        }
        
        return true
    }
    
    
    /* Time Parser Delegate*/
    func didFinishParsing(_ sender: EMTTimeParser, data: [EMTSearchResult]) {
        loadingView.hide()
        arrayData = data
        if (data.count == 0){
            //TODO: Show error!.
            return;
        }
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier! as NSString).isEqual("detailSegue"){
            let vc = segue.destination as! EMTDetailTableViewController
            vc.arrayData = arrayData
            vc.numParada = textfieldParada.text
        }
    }


}
