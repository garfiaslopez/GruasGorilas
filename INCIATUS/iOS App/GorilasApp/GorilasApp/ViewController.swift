//
//  ViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 20/12/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner
import AudioToolbox
import AirshipKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    	
    var CurrentViewController: UIViewController!;
    var CurrentSegueIdentifier: String!;
    var ActualOrder:OrderModel!;
    var UsuarioEnSesion:Session = Session();
    let ApiUrl = VARS().getApiUrl();
    
    let Save = UserDefaults.standard;
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;
    
    @IBOutlet weak var MainContainer: UIView!
    @IBOutlet weak var MenuButton: UIBarButtonItem!

    override func viewDidLoad() {
        //locationManager.startUpdatingLocation();
        
        SocketIOManager.sharedInstance.delegate = self;
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        if let controller = self.childViewControllers.first! as UIViewController? {
            self.CurrentViewController = controller;
        }
        
        reloadInitViewForTypeOfUser();

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.CheckStatusOnServer), name:NSNotification.Name.UIApplicationDidBecomeActive, object: nil);

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.UsuarioEnSesion = Session();
        if(self.UsuarioEnSesion.token == "" && self.UsuarioEnSesion.name == ""){
            self.performSegue(withIdentifier: "LoginSegue", sender: self);
        }
        
    }
    
    func logOut() {
        // change Local Variables :
        self.Save.set(nil, forKey: "UsuarioEnSesion");
        self.Save.set(false, forKey: "connectionState");
        self.Save.synchronize();
        SocketIOManager.sharedInstance.closeConnection();
        self.performSegue(withIdentifier: "LoginSegue", sender: self);
    }
    
    func reloadInitViewForTypeOfUser(){
        SocketIOManager.sharedInstance.GetLastOrder(self.UsuarioEnSesion.typeuser, user_id: self.UsuarioEnSesion._id, state: "GetLastOrder");
    }
    
    func CheckStatusOnServer(){
        if(DELEGATE.hasPushOrder){
            let GetUrl = self.ApiUrl + "/order/" + DELEGATE.Order;
            let status = Reach().connectionStatus();
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            switch status {
            case .online(.wwan), .online(.wiFi):
                Alamofire.request(GetUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            let newOrder = data["order"];
                            if(newOrder["status"].stringValue == "Searching") {
                                let Model = OrderModel(data: newOrder);
                                SocketIOManager.sharedInstance.SendState(Model._id, user_id: self.UsuarioEnSesion._id, state: "OpenOrder");
                                self.DELEGATE.hasPushOrder = false;
                                self.ActualOrder = Model;
                                self.performSegue(withIdentifier: "NewOrderSegue", sender: self);
                            }
                        }else{
                            SwiftSpinner.hide();
                            self.alerta("Oops!", Mensaje: data["message"].stringValue );
                        }
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                    }
                }
            case .unknown, .offline:
                //No internet connection:
                self.alerta("Oops!", Mensaje: "Favor de conectarse a internet");
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewOrderSegue" {
            if let dest = segue.destination as? NewOrderOpViewController {
                dest.Order = self.ActualOrder;
            }
        }
        if segue.identifier == "SearchingOpSegue" {
            if let dest = segue.destination as? SearchingOperatorViewController {
                dest.Order = self.ActualOrder;
            }
        }
        if segue.identifier == "ConfirmOrderSegue" {
            if let dest = segue.destination as? ConfirmOrderOpViewController {
                dest.Order = self.ActualOrder;
            }
        }
        if segue.identifier == "WaitingUserSegue" {
            if let dest = segue.destination as? WaitingUserViewController {
                dest.Order = self.ActualOrder;
            }
        }
        
        if segue.identifier == "AcceptedOrderSegue" {
            if let dest = segue.destination as? AcceptedOrderViewController {
                dest.Order = self.ActualOrder;
            }
        }
        
        if segue.identifier == "PayMethodSegue" {
            if let dest = segue.destination as? PayMethodViewController {
                dest.Order = self.ActualOrder;
            }
        }
        if segue.identifier == "ToOriginSegue" {
            if let dest = segue.destination as? ToOriginOpViewController {
                dest.Order = self.ActualOrder;
            }
        }
        if segue.identifier == "ToDestinySegue" {
            if let dest = segue.destination as? ToDestinyOpViewController {
                dest.Order = self.ActualOrder;
            }
        }
        
        if segue.identifier == "ArrivingSegue" {
            if let dest = segue.destination as? ArrivingViewController {
                dest.Order = self.ActualOrder;
            }
        }
        if segue.identifier == "TransportingSegue" {
            if let dest = segue.destination as? TransportingViewController {
                dest.Order = self.ActualOrder;
            }
        }
        
        if segue.identifier == "DeliveredSegue" {
            if let dest = segue.destination as? RateViewController {
                dest.Order = self.ActualOrder;
            }
        }
    }
    
    func reloadWithOrder(_ data: OrderModel) {
        
        SwiftSpinner.hide();

        if(!DELEGATE.hasPushOrder){
            
            self.SoundAndVibrate();
            self.ActualOrder = data;
            
            if (UsuarioEnSesion.typeuser == "operator") {
                
                print("Its Operator");
                
                if(self.ActualOrder != nil) {
                    switch self.ActualOrder.status {
                    case "Searching":
                        print("SEARCHING - OPERATOR");
                        self.performSegue(withIdentifier: "NewOrderSegue", sender: self);
                    case "Accepted":
                        print("Orden Accepted");
                        self.performSegue(withIdentifier: "ConfirmOrderSegue", sender: self);
                    case "Confirmed":
                        print("Orden Confirmed");
                        self.performSegue(withIdentifier: "WaitingUserSegue", sender: self);
                    case "Arriving":
                        print("Arriving Operator");
                        self.performSegue(withIdentifier: "ToOriginSegue", sender: self);
                    case "Transporting":
                        print("Transporting Operator");
                        self.performSegue(withIdentifier: "ToDestinySegue", sender: self);
                    case "Delivered":
                        print("Delivered");
                        self.performSegue(withIdentifier: "DeliveredSegue", sender: self);
                    case "AlreadyTaked":
                        print("AlreadyTaked");
                        self.alerta("Oops", Mensaje: "Alguien mas ha tomado la orden.");
                        self.performSegue(withIdentifier: "DashboardSegue", sender: self);
                    case "Expired":
                        print("Expired");
                        self.alerta("Oops", Mensaje: "La orden ha expirado, ningun operador acepto la orden.");
                        self.performSegue(withIdentifier: "DashboardSegue", sender: self);
                    case "Canceled":
                        print("AlreadyTaked");
                        self.alerta("Oops", Mensaje: "La orden ha sido cancelada.");
                        self.performSegue(withIdentifier: "DashboardSegue", sender: self);
                    default:
                        print("NORMAL STATE");
                        performSegue(withIdentifier: "DashboardSegue", sender: self);
                        
                    }
                }else{
                    performSegue(withIdentifier: "DashboardSegue", sender: self);
                }
                
            } else {
                if(self.ActualOrder != nil) {
                    switch self.ActualOrder.status {
                    case "Searching":
                        print("SEARCHING - USER");
                        self.ActualOrder = data;
                        self.performSegue(withIdentifier: "SearchingOpSegue", sender: self);
                    case "Accepted":
                        print("Orden Accepted");
                        self.performSegue(withIdentifier: "AcceptedOrderSegue", sender: self);
                    case "Confirmed":
                        print("Orden Confirmed");
                        self.performSegue(withIdentifier: "PayMethodSegue", sender: self);
                    case "Arriving":
                        print("Arriving");
                        self.performSegue(withIdentifier: "ArrivingSegue", sender: self);
                    case "Transporting":
                        print("Transporting");
                        self.performSegue(withIdentifier: "TransportingSegue", sender: self);
                    case "Delivered":
                        print("Delivered");
                        self.performSegue(withIdentifier: "DeliveredSegue", sender: self);
                    case "Canceled":
                        print("Orden Canceled");
                        if (!self.Save.bool(forKey: "NotifiedCanceled")){
                            self.alerta("Lo sentimos", Mensaje: "La orden ha sido cancelada.");
                            self.Save.set(true, forKey: "NotifiedCanceled");
                            self.Save.synchronize();
                        }
                        self.performSegue(withIdentifier: "MapSegue", sender: self);
                    case "NotAccepted":
                        print("Orden Not Accepted");
                        if (!self.Save.bool(forKey: "NotifiedNotAccepted")){
                            self.alerta("Lo sentimos", Mensaje: "Por el momento no hay operadores activos en su zona.");
                            self.Save.set(true, forKey: "NotifiedNotAccepted");
                            self.Save.synchronize();
                        }
                        self.performSegue(withIdentifier: "MapSegue", sender: self);
                        
                    default:
                        print("NORMAL STATE");
                        self.performSegue(withIdentifier: "MapSegue", sender: self);
                    }
                }else{
                    self.performSegue(withIdentifier: "MapSegue", sender: self);
                }
            }
        }
    }

    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    func alertWithCall(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let callAction = UIAlertAction(title: "Llamar", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let phoneNumber: String = "tel://5556839645";
            UIApplication.shared.openURL(URL(string:phoneNumber)!);
        }
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction);
        alertController.addAction(callAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func SoundAndVibrate(){
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate));
        AudioServicesPlaySystemSound(1016);
    }

}

