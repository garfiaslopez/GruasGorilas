//
//  AddCarViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 09/03/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class AddCarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var Cars:Array<CarTemplate> = [];
    var DismissView = false;
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    
    @IBOutlet weak var MarcaTextfield: UITextField!
    @IBOutlet weak var ModeloTextfield: UITextField!
    @IBOutlet weak var ColorTextfield: UITextField!
    @IBOutlet weak var PlacasTextfield: UITextField!
    @IBOutlet weak var SeguroTextfield: UITextField!
    @IBOutlet weak var SeguroMarcaTextfield: UITextField!
    @IBOutlet weak var CarsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let nib = UINib(nibName: "CarTableViewCell", bundle: nil);
        self.CarsTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        self.CarsTableView.allowsSelection = false;
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(AddCarViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(AddCarViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Profile_AddCar")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.ReloadData();
    }
    
    func ReloadData(){
        SwiftSpinner.show("Consultando autos");
        
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
                        
                        self.Cars = [];
                        
                        for (_,car):(String,JSON) in data["cars"] {
                            
                            var tmp:CarTemplate = CarTemplate();
                            
                            tmp._id = car["_id"].stringValue;
                            tmp.brand = car["brand"].stringValue;
                            tmp.plates = car["plates"].stringValue;
                            tmp.model = car["model"].stringValue;
                            tmp.color = car["color"].stringValue;
                            tmp.secure = car["secure"].stringValue;
                            tmp.secureBrand = car["secureBrand"].stringValue;
                            
                            self.Cars.append(tmp);
                        }
                        self.CarsTableView.reloadData();
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CarTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CarTableViewCell;
        
        cell.TitleLabel.text = "\(self.Cars[(indexPath as NSIndexPath).row].brand) - \(self.Cars[(indexPath as NSIndexPath).row].model)";
        cell.DescriptionLabel.text = "\(self.Cars[(indexPath as NSIndexPath).row].plates)";
        cell.SeguroLabel.text = "\(self.Cars[(indexPath as NSIndexPath).row].secure)";
        cell.SeguroMarcaLabel.text = "\(self.Cars[(indexPath as NSIndexPath).row].secureBrand)";
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCar(id: self.Cars[indexPath.row]._id);
            self.Cars.remove(at: indexPath.row);
            self.CarsTableView.deleteRows(at: [indexPath], with: .left);
        }
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteCar(id: String) {
        let AuthUrl = self.ApiUrl + "/car/" + id;
        let status = Reach().connectionStatus();
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        switch status {
        case .online(.wwan), .online(.wiFi):
            Alamofire.request(AuthUrl, method: .delete, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        SwiftSpinner.hide();
                        self.ReloadData();
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
    
    @IBAction func SaveCar(_ sender: AnyObject) {
        if(self.MarcaTextfield.text != "" && self.ModeloTextfield.text != "" && self.ColorTextfield.text != "" && self.PlacasTextfield.text != ""){
            SwiftSpinner.show("Guardando auto");
            let AuthUrl = self.ApiUrl + "/car";
            let status = Reach().connectionStatus();
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            
            var seguro = "";
            var marcaSeguro = "";
            
            if let ms = self.SeguroMarcaTextfield.text {
                marcaSeguro = ms;
            }
            if let s = self.SeguroTextfield.text {
                seguro = s;
            }
            
            let DataToSend = [
                "user_id": self.UsuarioEnSesion._id,
                "brand": self.MarcaTextfield.text!,
                "plates": self.PlacasTextfield.text!,
                "model": self.ModeloTextfield.text!,
                "color": self.ColorTextfield.text!,
                "secure": seguro,
                "secureBrand": marcaSeguro
            ]
            switch status {
            case .online(.wwan), .online(.wiFi):
                Alamofire.request(AuthUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
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

            
            if(self.DismissView){
                self.dismiss(animated: true, completion: nil);
            }else{
                self.MarcaTextfield.text = "";
                self.ModeloTextfield.text = "";
                self.ColorTextfield.text = "";
                self.PlacasTextfield.text = "";
                self.SeguroTextfield.text = "";
                self.SeguroMarcaTextfield.text = "";
                self.ReloadData();
                self.DismissKeyboard();
            }
        }else{
            self.alerta("Oops!", Mensaje: "Favor de rellenar los campos necesarios");
        }
    }
    
    @IBAction func CancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func KeyboardDidShow(){
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddCarViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func KeyboardDidHidden(){
        //quita los gestos para que no halla interferencia despues
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer )
            }
        }
    }
    func DismissKeyboard(){
        self.MarcaTextfield.resignFirstResponder();
        self.ModeloTextfield.resignFirstResponder();
        self.PlacasTextfield.resignFirstResponder();
        self.ColorTextfield.resignFirstResponder();
        self.SeguroTextfield.resignFirstResponder();
        self.SeguroMarcaTextfield.resignFirstResponder();
    }

}
