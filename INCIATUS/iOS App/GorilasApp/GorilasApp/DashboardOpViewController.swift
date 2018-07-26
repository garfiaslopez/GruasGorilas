//
//  DashboardOpViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 20/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SwiftSpinner
import GooglePlaces
import Alamofire
import SwiftyJSON
import CoreLocation

class DashboardOpViewController: UIViewController,CLLocationManagerDelegate {

    var DataArray:Array<DashboardTemplate> = [];
    var NoticeArray:Array<NoticeTemplate> = [];
    var Refresh:UIRefreshControl!;
    var UsuarioEnSesion:Session = Session();
    let ApiUrl = VARS().getApiUrl();
    let Save = UserDefaults.standard;

    var ActualLocation = Loc();
    let locationManager = CLLocationManager();
    var startLocation: CLLocation!
    var Timer = Foundation.Timer();

    @IBOutlet weak var OrdersLabel: UILabel!
    @IBOutlet weak var TotalOrdersLabel: UILabel!
    @IBOutlet weak var AvailableSwitch: UISwitch!
    
    @IBOutlet weak var OperatorMsgLabel: UILabel!
    
    @IBOutlet weak var DashboardCollection: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //LOCATION SETTINGS:
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        
        if let connectionState = self.Save.value(forKey: "connectionState") as? Bool{
            self.AvailableSwitch.setOn(Bool(connectionState), animated: true);
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.Timer.invalidate();
    }

    override func viewDidAppear(_ animated: Bool) {
        if (self.UsuarioEnSesion.typeuser == "operator") {
            // 60 Segundos...
            print("ACTIVATING TIMER");
            self.Timer = Foundation.Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(DashboardOpViewController.UpdateLocation), userInfo: nil, repeats: true);
            RunLoop.main.add(self.Timer, forMode: RunLoopMode.commonModes);
        }
        self.reloadDashboard();
    }
    
    func reloadDashboard(){
        SwiftSpinner.show("Cargando Historial.");
        
        let AuthUrl = ApiUrl + "/orders/byFilters";
        let NoticeUrl = ApiUrl + "/notice";
        let status = Reach().connectionStatus();
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        var idToSend = "user_id";
        if self.UsuarioEnSesion.typeuser == "operator" {
            idToSend = "operator_id";
        }
        let DataToSend: Parameters = [
            "isTotals": true,
            idToSend: self.UsuarioEnSesion._id,
            "dateFilter": "today",
            ];
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        self.TotalOrdersLabel.text = "$\(data["total"].doubleValue)";
                        self.OrdersLabel.text = "#\(data["count"].intValue)";
                        
                        Alamofire.request(NoticeUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                            
                            if response.result.isSuccess {
                                let data = JSON(data: response.data!);
                                if(data["success"] == true){
                                    self.NoticeArray = [];
                                    for (_,notice):(String,JSON) in data["notices"] {
                                        let tmp = NoticeTemplate(
                                            _id: notice["_id"].stringValue,
                                            title: notice["title"].stringValue,
                                            description: notice["description"].stringValue,
                                            created: notice["created"].stringValue);
                                        self.NoticeArray.append(tmp);
                                    }
                                    if self.NoticeArray.count > 0 {
                                        self.OperatorMsgLabel.text = self.NoticeArray[0].description;
                                    }
                                    SwiftSpinner.hide();
                                    
                                }else{
                                    SwiftSpinner.hide();
                                    if response.response?.statusCode == 403 {
                                        if let parent = self.parent as? ViewController {
                                            parent.logOut();
                                        }
                                    }else{
                                        self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                                    }
                                }
                            }else{
                                SwiftSpinner.hide();
                                self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                            }
                        }
                        
                    }else{
                        SwiftSpinner.hide();
                        if response.response?.statusCode == 403 {
                            if let parent = self.parent as? ViewController {
                                parent.logOut();
                            }
                        }else{
                            self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                        }
                    }
                }else{
                    SwiftSpinner.hide();
                    self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                }
            }
        case .unknown, .offline:
            SwiftSpinner.hide();
            self.alerta("Oops!", Mensaje: "Favor de conectarse a internet");
        }
    }
    
    @IBAction func onChangeAvailable(_ sender: AnyObject) {
        
        let state = self.AvailableSwitch.isOn;
        self.Save.set(state, forKey: "connectionState");
        self.Save.synchronize();
        
        
        var label = "";
        if(state){
            label = "Activando";
        }else{
            label = "Desactivando";
        }
        
        SwiftSpinner.show(label);
        
        let AuthUrl = ApiUrl + "/user/" + self.UsuarioEnSesion._id;
        let ConnUrl = ApiUrl + "/connection";
        let ConnCloseUrl = ApiUrl + "/connectionclose/" + self.UsuarioEnSesion._id;

        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ];
        
        var DataToSend: Parameters =  [String: AnyObject]();
        DataToSend["available"] = state;
        
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, method: .put, parameters: DataToSend, encoding: JSONEncoding.default,  headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        SwiftSpinner.hide();
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                    }
                }else{
                    SwiftSpinner.hide();
                    self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                    
                }
            }
            
            var ConnInfo: Parameters =  [String: AnyObject]();
            ConnInfo["operator_id"] = self.UsuarioEnSesion._id;
            if(state){
                Alamofire.request(ConnUrl, method: .post, parameters: ConnInfo, encoding: JSONEncoding.default,  headers: headers).responseJSON { response in
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            print(data);
                        }else{
                        }
                    }else{
                    }
                }
            } else {
                Alamofire.request(ConnCloseUrl, method: .put, encoding: JSONEncoding.default,  headers: headers).responseJSON { response in
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                        }else{
                        }
                    }else{
                    }
                }

            }
        case .unknown, .offline:
            SwiftSpinner.hide();
            self.alerta("Sin conexión a internet", Mensaje: "Favor de conectarse a internet para acceder.");
            break;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NoticeSegue" {
            if let dest = segue.destination as? NoticeViewController {
                dest.NoticeArray = self.NoticeArray;
            }
        }
    }
    
    func UpdateLocation() {
        locationManager.startUpdatingLocation()
    }
    
    ///*****/////******/////////*****/////******/////////*****/////******/////////*****/////******//////
    /// LOCATION MANAGER METHODS:
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation();
        }
    }
    
    // if the users is moving of something like that.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation();
        
        let Loc = locations.first!
        let Cord = [
            "long": Loc.coordinate.longitude,
            "lat": Loc.coordinate.latitude
        ];
        print(Loc);
        let CordObj = [
            "denomination": "Update Localization",
            "cord": Cord
        ] as [String : Any];
        let DataToSend = [
            "loc" : CordObj
        ];
        let headers = [
            "Authorization":self.UsuarioEnSesion.token
        ];
        let UserUrl = self.ApiUrl + "/user/" + self.UsuarioEnSesion._id;
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            Alamofire.request(UserUrl, method: .put, parameters: DataToSend, encoding: JSONEncoding.default,  headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        print("SUCCESS UPDATE LOCATION");
                    }else{
                        print(data["message"].stringValue);
                    }
                }else{
                    self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                }
            }
        case .unknown, .offline:
            //No internet connection:
            print("NO INTERNET CONECTION");
        }
    }
    
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            print("Ok Pressed");
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    

}
