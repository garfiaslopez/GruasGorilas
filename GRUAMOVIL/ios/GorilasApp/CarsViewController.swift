//
//  CarsViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 17/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner


class CarsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var Cars:Array<CarTemplate> = [];
    var indexOfTableView:Int!;
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var DataTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "OrderTableViewCell", bundle: nil);
        self.DataTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        SwiftSpinner.setTitleFont(UIFont(name: "Montserrat", size: 17.0))

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.ReloadData();
    }
    
    func ReloadData(){
        SwiftSpinner.show("Consultando autos");
        
        self.Cars = [];
        
        var first:CarTemplate = CarTemplate();

        first._id = "0";
        first.brand = "Auto Compacto";
        first.plates = "ABC-123";
        first.model = "2017";
        first.color = "Indistinto";
        
        self.Cars.append(first);
        
        
        let AuthUrl = self.ApiUrl + "/cars/" + self.UsuarioEnSesion._id;
        let status = Reach().connectionStatus();
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        
                        for (_,car):(String,JSON) in data["cars"] {
                            
                            var tmp:CarTemplate = CarTemplate();
                            
                            tmp._id = car["_id"].stringValue;
                            tmp.brand = car["brand"].stringValue;
                            tmp.plates = car["plates"].stringValue;
                            tmp.model = car["model"].stringValue;
                            tmp.color = car["color"].stringValue;
                            
                            self.Cars.append(tmp);
                        }
                        self.DataTableView.reloadData();
                        SwiftSpinner.hide();
                        
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
        
    }
    

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Cars.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:OrderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! OrderTableViewCell;
        
        cell.TitleLabel.text = "\(self.Cars[(indexPath as NSIndexPath).row].brand) - \(self.Cars[(indexPath as NSIndexPath).row].model)";
        cell.SubtitleLabel.text = "\(self.Cars[(indexPath as NSIndexPath).row].plates)";
        cell.IconImageView.image = UIImage(named: "Car");
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let parent = self.presentingViewController as? RequestViewController {
            parent.Request.car = self.Cars[(indexPath as NSIndexPath).row];
            parent.OptionalArray[indexOfTableView].1 = self.Cars[(indexPath as NSIndexPath).row].brand;
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func AddCarModal(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "AddCarSegue", sender: self);
    }
    
    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    
    
}
