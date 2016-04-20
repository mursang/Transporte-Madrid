//
//  DetailTableViewController.swift
//  Autobuses Madrid
//
//  Created by Angel Sans Muro on 13/2/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    var arrayData:NSArray = NSArray()
    var numParada:String?
    var sortedData:NSArray = NSArray()
    
    var arrayLineas:NSMutableArray = NSMutableArray()
    var ocurrenciasDic:NSMutableDictionary = NSMutableDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = numParada
        print(arrayData)
        
        calculateLineas(arrayData)
        
    }
    
    func calculateLineas(array:NSArray){
        //Calculamos el numero de secciones y ocurrencias en funcion del numero de lineas que tengo.
        for object in array as! [NSDictionary]{
            let idLinea:String = object["idLine"] as! String
            if !arrayLineas.containsObject(idLinea){
                arrayLineas.addObject(idLinea)
            }
            
            if let val:String = ocurrenciasDic[idLinea] as? String{ //existe
                //sumo 1 al value
                var intVal = Int(val)!
                intVal += 1
                ocurrenciasDic[idLinea] = String(intVal)
            }else{ //no existe
                //lo creo con 1 ocurrencia
                ocurrenciasDic[idLinea] = "1"
            }
            
        }
        
        //ordenamos el array por la key "idLine" del diccionario.
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "idLine", ascending: true)
        sortedData = array.sortedArrayUsingDescriptors([descriptor])
        
        
        print("finishedCalculateLineas: \(ocurrenciasDic)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("numberOfSections")
        return arrayLineas.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let idLinea:String = arrayLineas[section] as! String
        let num:String = ocurrenciasDic[idLinea] as! String
        return Int(num)!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let idLinea:String = arrayLineas[section] as! String
        let string = "Línea \(idLinea)"
        
        return string
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRectMake(0,0,tableView.bounds.size.width,30))
        headerView.backgroundColor = UIColor(red: Constants.BlueColor.red/255.0, green: Constants.BlueColor.green/255.0, blue: Constants.BlueColor.blue/255.0, alpha: 0.9)
        
        let label:UILabel = UILabel(frame: CGRectMake(10,0,tableView.bounds.size.width,30))
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(18)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        headerView .addSubview(label)
        return headerView
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:DetailTimeTableViewCell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath) as! DetailTimeTableViewCell
        


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
