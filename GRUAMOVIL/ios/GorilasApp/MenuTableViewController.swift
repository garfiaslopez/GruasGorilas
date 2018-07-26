//
//  MenuTableViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 08/01/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MenuTableViewController: UITableViewController {
    
    let Save = UserDefaults.standard;
    var UsuarioEnSesion:Session = Session();
    var ViewControllers:Array<UIViewController> = [];
    var ViewDescription:Array<[String:String]> = [];
    var ActualView:Int = 0;
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var ProfileImageView: UIImageView!
    
    override func viewDidLoad() {

        super.viewDidLoad();

        let nib = UINib(nibName: "MenuTableViewCell", bundle: nil);
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        self.reloadData();

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.reloadData();
    }
    
    func reloadData(){
        
        self.UsuarioEnSesion = Session();
        
        
        let profileImg = VARS().getApiUrl() + "/profile/images/" + self.UsuarioEnSesion._id;
        let urlProfile = URL(string: profileImg);
        self.downloadImage(url: urlProfile!);
        
        if (self.NameLabel != nil) {
            self.NameLabel.text = self.UsuarioEnSesion.name;
            self.EmailLabel.text = self.UsuarioEnSesion.email;
        }

        
        
        self.ViewDescription = [];
        self.ViewControllers = [];
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        
        let StatusView = storyboard.instantiateViewController(withIdentifier: "StatusViewNav");
        let SchedulesView = storyboard.instantiateViewController(withIdentifier: "SchedulesViewNav");
        let TalleresView = storyboard.instantiateViewController(withIdentifier: "TalleresViewNav");
        // let TarifasView = storyboard.instantiateViewController(withIdentifier: "TarifasViewNav");
        let HistoryView = storyboard.instantiateViewController(withIdentifier: "HistoryViewNav");
        // let PromosView = storyboard.instantiateViewController(withIdentifier: "PromosViewNav");
        let ProfileView = storyboard.instantiateViewController(withIdentifier: "ProfileViewNav");
        // let PaydataView = storyboard.instantiateViewController(withIdentifier: "PaydataViewNav");
        let HelpView = storyboard.instantiateViewController(withIdentifier: "HelpViewNav");
        let AboutView = storyboard.instantiateViewController(withIdentifier: "AboutViewNav");
        
        if(UsuarioEnSesion.typeuser == "operator"){
            self.ViewDescription.append(["name":"Dashboard","icon":"ChartBar.png"]);
            self.ViewDescription.append(["name":"Cotizaciones/Reservaciones","icon":"CalendarMenu.png"]);
            self.ViewDescription.append(["name":"Comercios/Talleres Afiliados","icon":"Tools.png"]);
        }else{
            self.ViewDescription.append(["name":"Solicitar Grúa","icon":"Location.png"]);
            self.ViewDescription.append(["name":"Cotizaciones/Reservaciones","icon":"CalendarMenu.png"]);
            self.ViewDescription.append(["name":"Comercios/Talleres Afiliados","icon":"Tools.png"]);
        }
        self.ViewControllers.append(StatusView);
        self.ViewControllers.append(SchedulesView);
        self.ViewControllers.append(TalleresView);
        
//        self.ViewDescription.append(["name":"Tarifas","icon":"Money.png"]);
//        self.ViewControllers.append(TarifasView);
        
        self.ViewDescription.append(["name":"Historial","icon":"History.png"]);
        self.ViewControllers.append(HistoryView);
        
        //self.ViewDescription.append(["name":"Promociones","icon":"Offer.png"]);
        //self.ViewControllers.append(PromosView);
        
        self.ViewDescription.append(["name":"Perfil","icon":"Profile.png"]);
        self.ViewControllers.append(ProfileView);
        
//        if(UsuarioEnSesion.typeuser == "user"){
//            self.ViewDescription.append(["name":"Datos de pago","icon":"DebtCard.png"]);
//            self.ViewControllers.append(PaydataView);
//        }
        
        self.ViewDescription.append(["name":"Acerca de","icon":"Info.png"]);
        self.ViewControllers.append(AboutView);
        
        self.ViewDescription.append(["name":"Soporte y Comentarios","icon":"Help.png"]);
        self.ViewControllers.append(HelpView);
        
        self.ViewDescription.append(["name":"Cerrar Sesión","icon":"Power.png"]);
        
        self.tableView.reloadData();
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ViewDescription.count;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! MenuTableViewCell;
        
        cell.NameLabel.text = self.ViewDescription[(indexPath as NSIndexPath).row]["name"];
        let image = UIImage(named: self.ViewDescription[(indexPath as NSIndexPath).row]["icon"]!);
        cell.IconImageView.image = image;
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let swreveal = self.parent as? SWRevealViewController {
            if (indexPath as NSIndexPath).row != self.ViewDescription.count - 1 {
                if(ActualView != (indexPath as NSIndexPath).row) {
                    self.ActualView = (indexPath as NSIndexPath).row;
                    swreveal.pushFrontViewController(self.ViewControllers[(indexPath as NSIndexPath).row], animated: true);
                }else{
                    swreveal.revealToggle(nil);
                }
            }else{
                self.logOut();
                self.Save.set(nil, forKey: "UsuarioEnSesion");
                self.Save.synchronize();
                SocketIOManager.sharedInstance.closeConnection();
                
                if self.ActualView == 0 {
                    if let nav = swreveal.frontViewController as? MainNavigationViewController {
                        if let front = nav.viewControllers.first as? ViewController {
                            front.performSegue(withIdentifier: "LoginSegue", sender: front);
                        }
                    }
                } else {
                    self.ActualView = 0;
                    swreveal.pushFrontViewController(self.ViewControllers[0], animated: true);
                }

            }
        }
    }
    
    func logOut() {
        // in Server:
        let AuthUrl = VARS().getApiUrl() + "/authenticate/logoutuser";
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ];
        var idToSend = "user_id";
        if self.UsuarioEnSesion.typeuser == "operator" {
            idToSend = "operator_id";
        }
        let DataToSend: Parameters = [
            idToSend: self.UsuarioEnSesion._id
        ];
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            Alamofire.request(AuthUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default,  headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        print(data);
                    }else{
                    }
                }else{
                }
            }        default:
            break;
        }
        
        // change Local Variables :
        self.Save.set(false, forKey: "connectionState");
        self.Save.synchronize();
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                if ((self.ProfileImageView) != nil) {
                    let img = UIImage(data:data as Data);
                    if img != nil {
                        self.ProfileImageView.image = img;
                        self.ProfileImageView.layer.cornerRadius = 35;
                        self.ProfileImageView.layer.masksToBounds = true;
                        self.ProfileImageView.layer.borderWidth = 0;
                    }else{
                        self.ProfileImageView.image = UIImage(named:"ProfileDefault");
                        self.ProfileImageView.layer.cornerRadius = 35;
                        self.ProfileImageView.layer.masksToBounds = true;
                        self.ProfileImageView.layer.borderWidth = 0;
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

