//
//  ConditionsViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 17/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON

class ConditionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var ConditionsArray: Array<Array<String>> = [];
    var titleHeader: Array<String> = [];
    var indexOfTableView:Int!;
    var Selected: JSON =  ["I": ["A": true], "a":["B": false]];

    @IBOutlet weak var DataTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad();
        
        let nib = UINib(nibName: "ConditionsTableViewCell", bundle: nil);
        self.DataTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        self.DataTableView.allowsMultipleSelection = true;
        
        titleHeader.append("Estado General");
        titleHeader.append("Condiciones (Seleccione las necesarias)");
        
        ConditionsArray.append(["Perfecto (Solo traslado)","Descompuesto","Siniestrado (Choque)"]);
        ConditionsArray.append(["Ruedas giran libres","Falta una o mas ruedas","No tengo llaves de encendido","Falla de motor"]);
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ConditionsArray.count;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConditionsArray[section].count;
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel();
        title.font = UIFont(name: "Montserrat", size: 17)!;
        title.textColor = UIColor.darkText;
        let header = view as! UITableViewHeaderFooterView;
        header.textLabel?.font = title.font;
        header.textLabel?.textColor = title.textColor;
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleHeader[section];
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        if (indexPath.row == 0 && indexPath.section == 0){
            let i = IndexPath(row: indexPath.row + 1, section: indexPath.section);
            if let newCell = tableView.cellForRow(at: i) {
                newCell.accessoryType = .none;
            }
            tableView.deselectRow(at: i, animated: true);
            
            let idos = IndexPath(row: indexPath.row + 2, section: indexPath.section);
            if let newCelldos = tableView.cellForRow(at: idos) {
                newCelldos.accessoryType = .none;
            }
            tableView.deselectRow(at: idos, animated: true);
        }
        
        if (indexPath.row == 1 && indexPath.section == 0){
            let i = IndexPath(row: indexPath.row - 1, section: indexPath.section);
            if let newCell = tableView.cellForRow(at: i) {
                newCell.accessoryType = .none;
            }
            tableView.deselectRow(at: i, animated: true);
            
            let idos = IndexPath(row: indexPath.row + 1, section: indexPath.section);
            if let newCelldos = tableView.cellForRow(at: idos) {
                newCelldos.accessoryType = .none;
            }
            tableView.deselectRow(at: idos, animated: true);
        }
        
        if (indexPath.row == 2 && indexPath.section == 0){
            let i = IndexPath(row: indexPath.row - 1, section: indexPath.section);
            if let newCell = tableView.cellForRow(at: i) {
                newCell.accessoryType = .none;
            }
            tableView.deselectRow(at: i, animated: true);
            let idos = IndexPath(row: indexPath.row - 2, section: indexPath.section);
            if let newCelldos = tableView.cellForRow(at: idos) {
                newCelldos.accessoryType = .none;
            }
            tableView.deselectRow(at: idos, animated: true);
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ConditionsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! ConditionsTableViewCell;
        cell.ConditionLabel.text = "\(self.ConditionsArray[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])";
        return cell
    }
    
    @IBAction func SaveAction(_ sender: Any) {
        if let parent = self.presentingViewController as? RequestViewController {
            var conditions:Array<String> = [];
            
            if let selecteds = self.DataTableView.indexPathsForSelectedRows {
                
                print("SELECTED STRINGS");
                print(selecteds);
                
                for indexpath in selecteds {
                    conditions.append(self.ConditionsArray[(indexpath as NSIndexPath).section][(indexpath as NSIndexPath).row]);
                }
                parent.Request.condition = conditions;
                let firstIndex = self.DataTableView.indexPathsForSelectedRows?.first;
                parent.OptionalArray[indexOfTableView].1 = self.ConditionsArray[(firstIndex! as NSIndexPath).section][(firstIndex! as NSIndexPath).row];
            }
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    

}
