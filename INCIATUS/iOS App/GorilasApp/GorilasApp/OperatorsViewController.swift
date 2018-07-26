//
//  SelectModalViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 17/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire


class OperatorsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    let Variables = VARS();
    let Save = UserDefaults.standard;
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var Operators:Array<UserTemplate> = [];
    var indexOfTableView:Int!;

    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var DataTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil);
        self.DataTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        SwiftSpinner.setTitleFont(UIFont(name: "Roboto-Regular.ttf", size: 15.0))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.ReloadData();
    }
    
    func ReloadData(){
        SwiftSpinner.show("Consultando operadores");
        
        let AuthUrl = Variables.getApiUrl() + "/user/byavailablevendors";
        
        let status = Reach().connectionStatus();
        let headers: HTTPHeaders = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        self.Operators = [];
                        
                        for (_,object):(String,JSON) in data["users"] {
                            
                            var tmp:UserTemplate = UserTemplate();
                            
                            tmp.name = object["name"].stringValue;
                            tmp.rate = object["rate"].doubleValue;
                            
                            
                            self.Operators.append(tmp);
                        }
                        
                        print("Routes \(self.Operators.count)");
                        
                        self.DataTableView.reloadData();
                        
                    }else{
                        self.alerta("Oops!", Mensaje: data["message"].stringValue );
                    }
                }else{
                    self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                }
            }
            
            
        case .unknown, .offline:
            //No internet connection:
            self.alerta("Oops!", Mensaje: "Favor de conectarse a internet");
        }
        
        SwiftSpinner.hide();
    }
    
    // MARK: - Table view data source
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Operators.count;
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45;
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath as IndexPath) as! CustomTableViewCell;
        
        cell.DescriptionLabel.text = "\(self.Operators[indexPath.row].name)";
        cell.ValueLabel.text = "Calf. \(self.Operators[indexPath.row].rate)";
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let parent = self.presentingViewController as? RequestViewController {
            parent.OptionalArray[indexOfTableView].1 = self.Operators[indexPath.row].name;
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil));
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }

}
