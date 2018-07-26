//
//  RateViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 10/6/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner


class RateViewController: UIViewController {
    
    var Order:OrderModel!;
    var UsuarioEnSesion:Session = Session();
    let ApiUrl = VARS().getApiUrl();
    var Buttons:Array<UIImageView> = [];
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;
    
    @IBOutlet weak var CopyLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var OneStar: UIImageView!
    @IBOutlet weak var TwoStar: UIImageView!
    @IBOutlet weak var ThreeStar: UIImageView!
    @IBOutlet weak var FourStar: UIImageView!
    @IBOutlet weak var FiveStar: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        Buttons.append(OneStar);
        Buttons.append(TwoStar);
        Buttons.append(ThreeStar);
        Buttons.append(FourStar);
        Buttons.append(FiveStar);
        
        if(self.Order.isPaid){
            self.alerta("Pago procesado", Mensaje: "Se ha realizado el pago de su pedido, muchas gracias.");
        }else{
            if self.Order.paymethod == "CASH" {
                self.alerta("Pago con efectivo", Mensaje: "Recuerde que el cliente le tiene que pagar en efectivo.");
            }else{
                self.alerta("Pago no procesado", Mensaje: "El pago no pudo ser procesado correctamente.");
            }
        }
        
        if(self.UsuarioEnSesion.typeuser == "operator"){
            self.CopyLabel.text = "Califique al usuario";
            self.NameLabel.text = self.Order.user.name;
            
        }else{
            self.CopyLabel.text = "Califique a su operador";
            self.NameLabel.text = self.Order.oper.name;
        }
        
        if (self.UsuarioEnSesion.typeuser == "operator") {
            let profileImg = VARS().getApiUrl() + "/profile/images/" + self.Order.user._id;
            let urlProfile = URL(string: profileImg);
            self.downloadImage(url: urlProfile!);
        }else{
            let profileImg = VARS().getApiUrl() + "/profile/images/" + self.Order.oper._id;
            let urlProfile = URL(string: profileImg);
            self.downloadImage(url: urlProfile!);
        }
        

        // Do any additional setup after loading the view.
    }
    
    
    func drawStars(_ stars:Int){
        for star in 0...stars {
            self.Buttons[star].image = UIImage(named: "StarFilled.png");
        }
        
        if(stars < 4){
            for star in (stars + 1)...(4){
                self.Buttons[star].image = UIImage(named: "StarEmpty.png");
            }
        }
        
    }

    @IBAction func openTypeForm(_ sender: Any) {
        let url: String = "https://inciatus.typeform.com/to/gSnScA";
        UIApplication.shared.openURL(URL(string:url)!);
    }
    
    func rateUser(_ rate:Int){
        
        SwiftSpinner.show("Calificando");
        let AuthUrl = ApiUrl + "/rateuser";
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        var id = "";
        if(self.UsuarioEnSesion.typeuser == "user"){
            id = self.Order.user._id;
        }else{
            id = self.Order.oper._id;
        }
        
        let DataToSend: Parameters = [
            "user_id": id,
            "rate": rate,
            ];
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default,  headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        
                        SwiftSpinner.hide();
                        
                        if let parent = self.parent as? ViewController {
                            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "RatedUser");
                            if (self.UsuarioEnSesion.typeuser == "operator") {
                                parent.performSegue(withIdentifier: "DashboardSegue", sender: parent);
                            }else{
                                parent.performSegue(withIdentifier: "MapSegue", sender: parent);
                            }
                        }
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                    }
                }else{
                    SwiftSpinner.hide();
                    self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                }
            }
        case .unknown, .offline:
            SwiftSpinner.hide();
            self.alerta("Sin conexión a internet", Mensaje: "Favor de conectarse a internet para acceder.");
            break;
        }
    }
    
    @IBAction func OneStarAction(_ sender: AnyObject) {
        self.drawStars(0);
        self.rateUser(1);
    }
    
    @IBAction func TwoStarAction(_ sender: AnyObject) {
        self.drawStars(1);
        self.rateUser(2);
        
    }
    
    @IBAction func ThreeStarAction(_ sender: AnyObject) {
        self.drawStars(2);
        self.rateUser(3);
        
    }
    
    @IBAction func FourStarAction(_ sender: AnyObject) {
        self.drawStars(3);
        self.rateUser(4);
        
    }
    
    @IBAction func FiveStarAction(_ sender: AnyObject) {
        self.drawStars(4);
        self.rateUser(5);
    
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
    
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                
                if ((self.profilePhoto) != nil) {
                    let img = UIImage(data:data as Data);
                    if (img != nil) {
                        self.profilePhoto.image = img;
                        self.profilePhoto.layer.cornerRadius = 70;
                        self.profilePhoto.layer.masksToBounds = true;
                        self.profilePhoto.layer.borderWidth = 0;
                    }else{
                        self.profilePhoto.image = UIImage(named:"ProfileDefault");
                        self.profilePhoto.layer.cornerRadius = 70;
                        self.profilePhoto.layer.masksToBounds = true;
                        self.profilePhoto.layer.borderWidth = 0;
                    }
                }
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }

}
