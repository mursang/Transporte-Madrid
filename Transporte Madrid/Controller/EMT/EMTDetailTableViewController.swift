//
//  EMTDetailTableViewController.swift
//  Autobuses Madrid
//
//  Created by Angel Sans Muro on 13/2/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit

class EMTDetailTableViewController: UITableViewController, EMTParserDelegate {
    
    var arrayData: [EMTSearchResult]?
    var numParada: String?
    var orderedData: [String:[EMTSearchResult]]?
    var sortedKeys: [String]?
    var timeParser = EMTTimeParser.sharedInstance
    
    let prefs = UserDefaults.standard
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = numParada
        checkFavorite()
        setUpTableViewData(arrayData!)
    
    }
    override func viewWillAppear(_ animated: Bool) {
        timeParser.delegate = self
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        LoadingView.sharedInstance.show(onTableViewController: self)
        timeParser.getArriveTimes(self.numParada!)
    }
    
    func didFinishParsing(_ sender: EMTTimeParser, data: [EMTSearchResult]) {
        LoadingView.sharedInstance.hideFromTableView()
        self.arrayData = data
        self.setUpTableViewData(data)
    }
    
    func checkFavorite(){
        if let data = prefs.object(forKey: Constants.EMTKeys.favoriteKey) as? Data{
            let array = NSKeyedUnarchiver.unarchiveObject(with: data) as! [EMTFavorite]
            for fav in array{
                if (fav.stopNumber! == self.numParada!){
                    self.favoriteButton.isSelected = true
                    return
                }
            }
        }
        self.favoriteButton.isSelected = false
    }
    
    func setUpTableViewData(_ array:[EMTSearchResult]){
        sortedKeys = [String]()
        orderedData = [String:[EMTSearchResult]]()
        
        for element in array{
            if (!orderedData!.keys.contains(element.idLine)){
                orderedData![element.idLine] = [element]
            }else{
                var array = orderedData![element.idLine]
                array!.append(element)
                array!.sort(by: {$0.timeInSeconds < $1.timeInSeconds})
                orderedData![element.idLine] = array!
            }
        }
        
        
        sortedKeys = Array(orderedData!.keys).sorted(by: <)
        self.tableView.reloadData()
    }

    @IBAction func favoriteAction(_ sender: AnyObject) {
        if let arrayFavs = prefs.object(forKey: Constants.EMTKeys.favoriteKey) as? Data{
            var favsArray = NSKeyedUnarchiver.unarchiveObject(with: arrayFavs) as! [EMTFavorite]
            if (favoriteButton.isSelected){ //we want to delete this fav.
                let index = favsArray.index(where: {$0.stopNumber == numParada})
                favsArray.remove(at: index!)
                let data = NSKeyedArchiver.archivedData(withRootObject: favsArray)
                prefs.set(data, forKey: Constants.EMTKeys.favoriteKey)
                favoriteButton.isSelected = false
            }else{ // we want to add it.
                let myFav = EMTFavorite(stopNumber: numParada!, linesArray: Array(orderedData!.keys))
                favsArray.append(myFav)
                let data = NSKeyedArchiver.archivedData(withRootObject: favsArray)
                prefs.set(data, forKey: Constants.EMTKeys.favoriteKey)
                favoriteButton.isSelected = true
            }
        }else{
            var favsArray = [EMTFavorite]()
            let myFav = EMTFavorite(stopNumber: numParada!, linesArray: Array(orderedData!.keys))
            favsArray.append(myFav)
            let data = NSKeyedArchiver.archivedData(withRootObject: favsArray)
            prefs.set(data, forKey: Constants.EMTKeys.favoriteKey)
            favoriteButton.isSelected = true
        }
        prefs.synchronize()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return orderedData!.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedKey = sortedKeys![section]
        let arrayElements = orderedData![selectedKey]
        
        return arrayElements!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let selectedKey = sortedKeys![section]
        let string = "Línea \(selectedKey)"
        return string
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRect(x: 0,y: 0,width: tableView.bounds.size.width,height: 30))
        headerView.backgroundColor = UIColor(red: Constants.BlueColor.red/255.0, green: Constants.BlueColor.green/255.0, blue: Constants.BlueColor.blue/255.0, alpha: 0.9)
        
        let label:UILabel = UILabel(frame: CGRect(x: 10,y: 0,width: tableView.bounds.size.width,height: 30))
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        headerView .addSubview(label)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DetailTimeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTimeTableViewCell
        
        let selectedKey = sortedKeys![indexPath.section]
        let selectedItem = orderedData![selectedKey]![indexPath.row]
        
        cell.timeLabel.text = selectedItem.timeLeftBus
        cell.destinoLabel.text = "Destino : \(selectedItem.destination!)"
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
