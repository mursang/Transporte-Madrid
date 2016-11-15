//
//  MetroViewController.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 10/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit
import Fuzi

class MetroViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MetroParserDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var originTextfield: UITextField!
    @IBOutlet weak var destinationTextfield: UITextField!
    
    var tableViewSelector: UITableView!
    var selectedTextfield: UITextField?
    
    var arrayStopsMetro: [MetroStop]!
    var filteredStopsMetro: [MetroStop]!
    var selectedOriginStop: MetroStop?
    var selectedDestinationStop: MetroStop?
    
    let metroParser = MetroParser.sharedInstance
    
    var resultData: MetroResult?
    
    @IBOutlet weak var favoritesTableView: UITableView!
    var arrayFavorites = [MetroResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredStopsMetro = [MetroStop]()
        setUpMetroStops()
        
        originTextfield.delegate = self
        destinationTextfield.delegate = self
        originTextfield.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        destinationTextfield.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        setUpTableView()
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self

        //lateral menu
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        metroParser.delegate = self
        //check for new favorites.
        let prefs = UserDefaults.standard
        if let data = prefs.object(forKey: Constants.MetroKeys.favoriteKey) as? Data{
            let array = NSKeyedUnarchiver.unarchiveObject(with: data) as! [MetroResult]
            self.arrayFavorites = array
            self.favoritesTableView.reloadData()
        }
    }
    
    func didFinishParsing(_ sender: MetroParser, data: MetroResult?, error: String?) {
        LoadingView.sharedInstance.hide()
        if error != nil{
            self.showErrorAlertWithMessage(string: error!)
            return
        }
        self.resultData = data!
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    func showErrorAlertWithMessage(string: String){
        LoadingView.sharedInstance.hide()
        let alert = UIAlertController(title: "Ups!", message: string, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func calculateTime(_ sender: Any) {
        
        if selectedOriginStop == nil || selectedDestinationStop == nil{
            self.showErrorAlertWithMessage(string: "Los campos origen y destino no pueden estar vacíos.")
            return
        }
        
        LoadingView.sharedInstance.show(onViewController: self)
        
        //let's parse URL from QR in order to get stop number
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        self.metroParser.delegate = self
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.metroParser.getMetroData(idOrigin: self.selectedOriginStop!.id, idDestination: self.selectedDestinationStop!.id, originName: self.originTextfield.text!, destinationName: self.destinationTextfield.text!)
        }
    }
    
    
    
    func setUpMetroStops(){
        arrayStopsMetro = [MetroStop]()
        let path = Bundle.main.path(forResource: "arrays", ofType: "xml")
        let content = try! String.init(contentsOfFile: path!)
        do {
            let document = try XMLDocument(string: content)
            var arrayNames = [String]()
            var arrayIds = [String]()
            
            
            if let root = document.root {
                // Accessing all child nodes of root element
                for element in root.children {
                    let att = element.attributes
                    if (att["name"] == "array_estaciones_metro"){
                        for child in element.children{
                            var string = child.stringValue
                            string = string.replacingOccurrences(of: "<item>", with: "")
                            string = string.replacingOccurrences(of: "</item>", with: "")
                            arrayNames.append(string)
                        }
                    }else if(att["name"] == "array_id_estaciones_metro"){
                        for child in element.children{
                            var string = child.stringValue
                            string = string.replacingOccurrences(of: "<item>", with: "")
                            string = string.replacingOccurrences(of: "</item>", with: "")
                            arrayIds.append(string)
                        }
                    }
                    
                }
                
                for i in 0 ..< arrayNames.count{
                    let stop = MetroStop(name: arrayNames[i], id: arrayIds[i])
                    arrayStopsMetro.append(stop)
                }
            }
        } catch let error {
            print(error)
        }

    }
    
    func textFieldChanged(_ textField: UITextField) {
        self.filteredStopsMetro.removeAll()
        let myText = textField.text!
        let copyArray = arrayStopsMetro
        
        self.filteredStopsMetro = copyArray!.filter({stop in
            let string = stop.name as NSString
            if string.range(of: myText, options: .caseInsensitive).location == 0{
                return true
            }
            return false
        })
        
        self.tableViewSelector.reloadData()
    }
    
    func setUpTableView() {
        tableViewSelector = UITableView()
        tableViewSelector.tag = 0
        tableViewSelector.dataSource = self
        tableViewSelector.delegate = self
        tableViewSelector.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        tableViewSelector.isHidden = true
        tableViewSelector.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableViewSelector)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.filteredStopsMetro.removeAll()
        tableViewSelector.reloadData()
        let tableViewHeight = self.view.frame.height
        selectedTextfield = textField
        //show tableView
        switch textField.tag {
        case 0:
            //origin
            tableViewSelector.isHidden = false
            let convertedFrame = originTextfield.convert(originTextfield.frame, to: self.view)
            tableViewSelector.frame = CGRect(x: 0, y: convertedFrame.origin.y+originTextfield.frame.height, width: self.view.bounds.size.width, height: CGFloat(tableViewHeight))
            break
        case 1:
            //destination
            tableViewSelector.isHidden = false
            let convertedFrame = destinationTextfield.convert(destinationTextfield.frame, to: self.view)
            tableViewSelector.frame = CGRect(x: 0, y: convertedFrame.origin.y+destinationTextfield.frame.height, width: self.view.bounds.size.width, height: CGFloat(tableViewHeight))
            break
        default:
            break
        }
        return true
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return filteredStopsMetro.count
        case 1:
            return arrayFavorites.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 0:
            return 45
        case 1:
            return 70
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 0:
            let cell = tableView.cellForRow(at: indexPath)
            if (selectedTextfield?.tag == 0){
                self.selectedOriginStop = filteredStopsMetro[indexPath.row]
            }else{
                self.selectedDestinationStop = filteredStopsMetro[indexPath.row]
            }
            self.selectedTextfield!.text = cell!.textLabel?.text
            self.selectedTextfield?.resignFirstResponder()
            selectedTextfield = nil
            self.tableViewSelector.isHidden = true
            break
        case 1:
            //perform search!
            let object = arrayFavorites[indexPath.row]
            self.originTextfield.text = object.origin!
            self.destinationTextfield.text = object.destination!
            
            let originStop = arrayStopsMetro.filter({$0.name == object.origin!}).first!
            let destinationStop = arrayStopsMetro.filter({$0.name == object.destination!}).first!
            selectedOriginStop = originStop
            selectedDestinationStop = destinationStop
            self.calculateTime(self)
            break
        default:
            return
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            let stop = filteredStopsMetro[indexPath.row]
            cell?.textLabel?.text = stop.name
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "metroFavoriteCell") as! MetroFavoriteTableViewCell
            let object = arrayFavorites[indexPath.row]
            let string = "\(object.origin!) - \(object.destination!)"
            cell.routeLabel.text = string
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailSegue"){
            let vc = segue.destination as! MetroDetailTableViewController
            vc.metroResult = self.resultData
        }
    }
    

}
