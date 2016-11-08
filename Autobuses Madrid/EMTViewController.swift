//
//  EMTViewController.swift
//  Autobuses Madrid
//
//  Created by Angel Sans Muro on 13/2/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AVFoundation
import QRCodeReader

class EMTViewController: UIViewController, UITextFieldDelegate, EMTParserDelegate, QRCodeReaderViewControllerDelegate, EMTQRParserDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var textfieldParada: UITextField!
    @IBOutlet weak var qrButton: UIButton!
    
    //init parser
    let timeParser: EMTTimeParser = EMTTimeParser.sharedInstance
    let loadingView: LoadingView = LoadingView.sharedInstance
    
    var arrayData = [EMTSearchResult]()
    var arrayFavorites = [EMTFavorite]()
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    //QR Reader
    //lazy var to avoid cpu overload during the init
    /*lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.cancelButtonTitle = "Cancelar"
        $0.showSwitchCameraButton = false
        $0.showTorchButton = true
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
    })*/
    lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        let readerView = QRCodeReaderContainer(displayable: EMTQRCustomView())
        $0.readerView = readerView
        $0.cancelButtonTitle = "Cancelar"
        $0.showSwitchCameraButton = false
        $0.showTorchButton = true
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
    })
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textfieldParada.delegate = self
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self

        //lateral menu
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
    @IBAction func QRAction(_ sender: Any) {
        readerVC.delegate = self
        readerVC.completionBlock = {(result: QRCodeReaderResult?) in
            if let myURL = result?.value {
                //result should be something like: http://t.adtag.fr/czsey87clyk5
                LoadingView.sharedInstance.show(onViewController: self)
                //let's parse URL from QR in order to get stop number
                let delay = 0.2 * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    let parser = EMTQRParser.sharedInstance
                    parser.delegate = self
                    parser.getStopNumberFromStringURL(url: myURL)
                }
            }
        }
        readerVC.modalPresentationStyle = .formSheet
        self.present(readerVC, animated: true, completion: nil)
    }
    
    func gotStopNumberFromQR(_ sender: EMTQRParser, stopNumber: String?, error: String?) {
        LoadingView.sharedInstance.hide()
        if (error != nil){
            let error = ErrorView(title: "ERROR", message: error!, viewController: self)
            error.show()
            return
        }
        //let's parse times
        self.textfieldParada.text = stopNumber
        self.timeParser.getArriveTimes(stopNumber!)
    }
    
    //QR Delegate
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        timeParser.delegate = self
        
        //check for new favorites.
        let prefs = UserDefaults.standard
        if let data = prefs.object(forKey: Constants.EMTKeys.favoriteKey) as? Data{
            let array = NSKeyedUnarchiver.unarchiveObject(with: data) as! [EMTFavorite]
            self.arrayFavorites = array
            self.favoritesTableView.reloadData()
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
            let error = ErrorView(title: "ERROR", message: "Parece que la parada no es válida.", viewController: self)
            error.show()
            return;
        }
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Favorites
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayFavorites.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell") as! EMTFavoriteTableViewCell
        let fav = arrayFavorites[indexPath.row]

        cell.stopNumberLabel.text = "Parada número: \(fav.stopNumber!)"
        var linesString = "Líneas:"
        for string in fav.linesArray!{
            linesString = "\(linesString) \(string),"
        }
        //remove last ","
        linesString = linesString.substring(to: linesString.index(before: linesString.endIndex))
        cell.linesLabel.text = linesString
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get times!
        let selectedFav = arrayFavorites[indexPath.row]
        self.textfieldParada.text = selectedFav.stopNumber!
        loadingView.show(onViewController: self)
        let delay = 0 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.timeParser.getArriveTimes(selectedFav.stopNumber!)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            let selectedFav = arrayFavorites[indexPath.row]
            //DELETE!!
            self.favoritesTableView.beginUpdates()
            self.favoritesTableView.deleteRows(at: [indexPath], with: .automatic)
            
            let prefs = UserDefaults.standard
            let data = prefs.object(forKey: Constants.EMTKeys.favoriteKey) as! Data
            var array = NSKeyedUnarchiver.unarchiveObject(with: data) as! [EMTFavorite]
            let index = array.index(where: {$0.stopNumber! == selectedFav.stopNumber!})
            array.remove(at: index!)
            let newData = NSKeyedArchiver.archivedData(withRootObject: array)
            prefs.set(newData, forKey: Constants.EMTKeys.favoriteKey)
            prefs.synchronize()
            self.arrayFavorites = array
            self.favoritesTableView.endUpdates()
        }
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Eliminar"
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
