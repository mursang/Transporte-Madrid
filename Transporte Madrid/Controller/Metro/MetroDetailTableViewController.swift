//
//  MetroDetailTableViewController.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 14/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit

class MetroDetailTableViewController: UITableViewController {

    var metroResult: MetroResult?
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkFavorite()
        
    }
    
    func checkFavorite(){
        let prefs = UserDefaults.standard
        if let data = prefs.object(forKey: Constants.MetroKeys.favoriteKey) as? Data{
            let array = NSKeyedUnarchiver.unarchiveObject(with: data) as! [MetroResult]
            for fav in array{
                if (fav.origin! == self.metroResult?.origin! && fav.destination! == self.metroResult?.destination!){
                    self.favoriteButton.isSelected = true
                    return
                }
            }
        }
        self.favoriteButton.isSelected = false
    }

    @IBAction func favoriteAction(_ sender: Any) {
        let prefs = UserDefaults.standard
        if let arrayFavs = prefs.object(forKey: Constants.MetroKeys.favoriteKey) as? Data{
            var favsArray = NSKeyedUnarchiver.unarchiveObject(with: arrayFavs) as! [MetroResult]
            if (favoriteButton.isSelected){ //we want to delete this fav.
                let index = favsArray.index(where: {fav in
                    if (fav.origin! == metroResult?.origin! && fav.destination! == metroResult?.destination!){
                        return true
                    }
                    return false
                })
                favsArray.remove(at: index!)
                let data = NSKeyedArchiver.archivedData(withRootObject: favsArray)
                prefs.set(data, forKey: Constants.MetroKeys.favoriteKey)
                favoriteButton.isSelected = false
            }else{ // we want to add it.
                let myFav = self.metroResult!
                favsArray.append(myFav)
                let data = NSKeyedArchiver.archivedData(withRootObject: favsArray)
                prefs.set(data, forKey: Constants.MetroKeys.favoriteKey)
                favoriteButton.isSelected = true
            }
        }else{
            var favsArray = [MetroResult]()
            let myFav = self.metroResult!
            favsArray.append(myFav)
            let data = NSKeyedArchiver.archivedData(withRootObject: favsArray)
            prefs.set(data, forKey: Constants.MetroKeys.favoriteKey)
            favoriteButton.isSelected = true
        }
        prefs.synchronize()
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Tiempo estimado de trayecto"
        case 1:
            return "Indicaciones de ruta"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return metroResult!.indications.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeLeftCell") as! MetroTimeLeftTableViewCell
            cell.timeLeftLabel.text = metroResult!.estimatedTime
            return cell
        case 1:
            let indication = metroResult?.indications[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "indicationCell") as! MetroIndicationsTableViewCell
            cell.indicationLabel.text = indication!
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
