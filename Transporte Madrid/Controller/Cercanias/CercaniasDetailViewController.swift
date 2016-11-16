//
//  CercaniasDetailViewController.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 16/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit

class CercaniasDetailViewController: UIViewController {

    var cercaniasResult: CercaniasResult?
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkFavorite()
        webView.loadHTMLString(self.cercaniasResult!.htmlString, baseURL: nil)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func checkFavorite(){
        let prefs = UserDefaults.standard
        if let data = prefs.object(forKey: Constants.CercaniasKeys.favoriteKey) as? Data{
            let array = NSKeyedUnarchiver.unarchiveObject(with: data) as! [CercaniasResult]
            for fav in array{
                if (fav.origin! == self.cercaniasResult?.origin! && fav.destination! == self.cercaniasResult?.destination!){
                    self.favoriteButton.isSelected = true
                    return
                }
            }
        }
        self.favoriteButton.isSelected = false
    }
    @IBAction func favoriteAction(_ sender: Any) {
        let prefs = UserDefaults.standard
        if let arrayFavs = prefs.object(forKey: Constants.CercaniasKeys.favoriteKey) as? Data{
            var favsArray = NSKeyedUnarchiver.unarchiveObject(with: arrayFavs) as! [CercaniasResult]
            if (favoriteButton.isSelected){ //we want to delete this fav.
                let index = favsArray.index(where: {fav in
                    if (fav.origin! == cercaniasResult?.origin! && fav.destination! == cercaniasResult?.destination!){
                        return true
                    }
                    return false
                })
                favsArray.remove(at: index!)
                let data = NSKeyedArchiver.archivedData(withRootObject: favsArray)
                prefs.set(data, forKey: Constants.CercaniasKeys.favoriteKey)
                favoriteButton.isSelected = false
            }else{ // we want to add it.
                let myFav = self.cercaniasResult!
                favsArray.append(myFav)
                let data = NSKeyedArchiver.archivedData(withRootObject: favsArray)
                prefs.set(data, forKey: Constants.CercaniasKeys.favoriteKey)
                favoriteButton.isSelected = true
            }
        }else{
            var favsArray = [CercaniasResult]()
            let myFav = self.cercaniasResult!
            favsArray.append(myFav)
            let data = NSKeyedArchiver.archivedData(withRootObject: favsArray)
            prefs.set(data, forKey: Constants.CercaniasKeys.favoriteKey)
            favoriteButton.isSelected = true
        }
        prefs.synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
