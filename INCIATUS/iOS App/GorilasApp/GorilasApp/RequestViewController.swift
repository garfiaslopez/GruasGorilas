//
//  RequestViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 20/02/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON
import DatePickerDialog

class RequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
   
    let Variables = VARS();
    let Save = UserDefaults.standard;
    let Format = Formatter();
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    
    var OptionalArray: Array<(String, String)> = [];
    var Request:RequestModel = RequestModel();

    var Timer = Foundation.Timer();
    var isCLicked = false;
    var SelectedDate = Date();

    var isQuotation = false;
    var isSchedule = false;
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var OriginLabel: UILabel!
    @IBOutlet weak var DestinyLabel: UILabel!
    @IBOutlet weak var DateSegmented: UISegmentedControl!
    @IBOutlet weak var RequestButton: UIButton!
    @IBOutlet weak var OptionalTableView: UITableView!
    @IBOutlet weak var DateTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "[z] Arista", size: 20)!, NSForegroundColorAttributeName:UIColor.white];
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil);
        self.OptionalTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        self.OriginLabel.text = self.Request.origin.address;
        self.CreateOptionalArray();
        
        self.DateTextField.delegate = self;
        self.DateTextField.isUserInteractionEnabled = false;
        self.DateTextField.text = "Lo mas pronto posible.";
        
        if(self.isQuotation) {
            self.NavigationBar.topItem?.title = "COTIZAR";
        }else{
            self.NavigationBar.topItem?.title = "SOLICITAR";
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Request")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    func CreateOptionalArray() {
        self.OptionalArray = [];
        self.OptionalArray.append(("Auto","Seleccionar"));
        self.OptionalArray.append(("Condiciones","Seleccionar"));
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.DestinyLabel.text = self.Request.destiny.address;
        self.OptionalTableView.reloadData();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CarsSegue" {
            if let dest = segue.destination as? CarsViewController {
                dest.indexOfTableView = (self.OptionalTableView.indexPathForSelectedRow! as NSIndexPath).row;
            }
        }
        
        if segue.identifier == "ConditionsSegue" {
            if let dest = segue.destination as? ConditionsViewController {
                dest.indexOfTableView = (self.OptionalTableView.indexPathForSelectedRow! as NSIndexPath).row;
            }
        }
        
        if segue.identifier == "OperatorsSegue" {
            if let dest = segue.destination as? OperatorsViewController {
                dest.indexOfTableView = (self.OptionalTableView.indexPathForSelectedRow! as NSIndexPath).row;
            }
        }
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OptionalArray.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Informacion Adicional";
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell;
        
        cell.DescriptionLabel.text = OptionalArray[(indexPath as NSIndexPath).row].0;
        cell.ValueLabel.text = OptionalArray[(indexPath as NSIndexPath).row].1;
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45;
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.OptionalArray[(indexPath as NSIndexPath).row].0 {
        case "Auto":
            self.performSegue(withIdentifier: "CarsSegue", sender: self);
        case "Condiciones":
            self.performSegue(withIdentifier: "ConditionsSegue", sender: self);
        case "Operador":
            self.performSegue(withIdentifier: "OperatorsSegue", sender: self);
        default:
            print("Nothig To do");
        }
    }
    
    
    
    @IBAction func RequestNow(_ sender: AnyObject) {
        
        if (self.Request.condition.count > 0 && self.Request.car.brand != "") {
            print("Pass first condition");
            if (self.isCLicked == false) {
                self.isCLicked = true;
                
                SwiftSpinner.show("Enviando Peticion...");
                let OrderUrl = Variables.getApiUrl() + "/order";
                DispatchQueue.main.async {
                    let status = Reach().connectionStatus();
                    switch status {
                    case .online(.wwan), .online(.wiFi):
                        let headers: HTTPHeaders = [
                            "Authorization": self.UsuarioEnSesion.token
                        ]
                        
                        Alamofire.request(OrderUrl, method: .post, parameters: self.GetObjectToRequest(), encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                            
                            if response.result.isSuccess {
                                let data = JSON(data: response.data!);
                                if(data["success"] == true){
                                    let OrderId = data["order"]["_id"].stringValue;
                                    
                                    self.Save.set(false, forKey: "NotifiedNotAccepted");
                                    self.Save.set(false, forKey: "NotifiedCanceled");
                                    self.Save.synchronize();
                                    
                                    SocketIOManager.sharedInstance.SendState(OrderId, user_id: self.UsuarioEnSesion._id, state: "SearchForVendor");
                                    SwiftSpinner.hide();
                                    
                                    self.dismiss(animated: true, completion: nil);
                                    
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
                        SwiftSpinner.hide();
                        self.alerta("Oops!", Mensaje: "Favor de conectarse a internet");
                    }
                }
            }
        }else{
            self.alerta("Oops!", Mensaje: "Favor de seleccionar un auto y sus condiciones actuales");
        }
    }
    
    func GetObjectToRequest() -> [String: AnyObject] {
        
        var DataToSend: Parameters =  [String: AnyObject]();
        DataToSend["user_id"] = self.UsuarioEnSesion._id as AnyObject?;
        
        if (self.DateSegmented.selectedSegmentIndex == 1){
            DataToSend["isSchedule"] = true;
            DataToSend["dateSchedule"] = self.SelectedDate.forServer;
        }
        if (self.isQuotation) {
            DataToSend["isQuotation"] = true;
        }
        
        var OriginDict:[String: AnyObject] = [String: AnyObject]();
        OriginDict["denomination"] = self.Request.origin.address as AnyObject?;
        let dictCordOrigin = [self.Request.origin.long, self.Request.origin.lat];
        OriginDict["cord"] = dictCordOrigin as AnyObject;
        
        var DestinyDict:[String: AnyObject] = [String: AnyObject]();
        DestinyDict["denomination"] = self.Request.destiny.address as AnyObject?;
        let dictCordDestiny = [self.Request.destiny.long, self.Request.destiny.lat];
        DestinyDict["cord"] = dictCordDestiny as AnyObject;
        
        DataToSend["origin"] = OriginDict as AnyObject?;
        DataToSend["destiny"] = DestinyDict as AnyObject?;
        
        if(self.Request.condition.count > 0){
            var ConditionsString = "";
            for condition in self.Request.condition {
                ConditionsString = ConditionsString + condition + ", ";
            }
            
            DataToSend["conditions"] = ConditionsString as AnyObject?;
        }
        
        var CarDict:[String: AnyObject] = [String: AnyObject]();
        CarDict["model"] = self.Request.car.model as AnyObject?;
        CarDict["brand"] = self.Request.car.brand as AnyObject?;
        CarDict["color"] = self.Request.car.color as AnyObject?;
        CarDict["plate"] = self.Request.car.plates as AnyObject?;
        
        DataToSend["carinfo"] = CarDict as AnyObject?;
        
        return DataToSend as [String : AnyObject];
    }

    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func ChangeRequestMode(_ sender: AnyObject) {
        if self.DateSegmented.selectedSegmentIndex == 0 {
            self.isSchedule = false;
            self.DateTextField.text = "Lo mas pronto posible.";
            self.DateTextField.isUserInteractionEnabled = false;
        } else {
            self.isSchedule = true;
            self.SelectedDate = self.Format.Today();
            self.DateTextField.text = self.Format.FullDatePretty.string(from: self.Format.Today());
            self.DateTextField.isUserInteractionEnabled = true;
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        DatePickerDialog().show(title: "Selecciona Una Fecha y Hora", doneButtonTitle: "Seleccionar", cancelButtonTitle: "Cancelar", defaultDate: self.SelectedDate, minimumDate: self.Format.Today(),datePickerMode: UIDatePickerMode.dateAndTime){
            (date) -> Void in
            if((date) != nil) {
                self.SelectedDate = date! as Date;
                self.DateTextField.text = self.Format.FullDatePretty.string(from: self.SelectedDate);
            }

        }
        return false;
    }
    
    @IBAction func OpenModalDestiny(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "DestinyModalSegue", sender: self);
    }
    @IBAction func DismissButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }

    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }

}
