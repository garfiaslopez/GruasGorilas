//
//  CarworkshopViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 15/02/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class CarworkshopViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{

    var UsuarioEnSesion:Session = Session();
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    
    var Refresh:UIRefreshControl!;
    var CarworkshopsArray:Array<CarworkshopTemplate> = [];
    var ImagesCache = [Int:UIImage](); //Dictionary<Int, UIImage>();
    
    var SelectedCell:Int!;
    var ActualFilter:String = "ALL";

    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var CarworkshopsTableView: UITableView!

    @IBOutlet weak var typeSegment: UISegmentedControl!
    
    @IBOutlet weak var TopTableViewLayout: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nib = UINib(nibName: "CarworkshopTableViewCell", bundle: nil);
        self.CarworkshopsTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        Refresh = UIRefreshControl();
        Refresh.tintColor = UIColor.orange;
        Refresh.addTarget(self, action: #selector(CarworkshopViewController.ReloadData), for: UIControlEvents.valueChanged);
        self.CarworkshopsTableView.addSubview(Refresh);
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Talleres")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.title = "Talleres Afiliados";
        
        if(self.UsuarioEnSesion.token == "" && self.UsuarioEnSesion.name == ""){
            self.performSegue(withIdentifier: "LoginSegue", sender: self);
        }else{
            
            if (self.UsuarioEnSesion.typeuser == "operator") {
                self.typeSegment.isHidden = true;
                self.title = "Aliados Estratégicos";
                self.ActualFilter = "ALLY";
                self.TopTableViewLayout.constant = 0;
            }
            self.ReloadData();
        }
    }
    
    func ReloadData(){
        SwiftSpinner.show("Cargando Catalogo");
        
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            let GETURL = ApiUrl + "/carworkshop/by/type/" + self.ActualFilter;
            let headers: HTTPHeaders = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            Alamofire.request(GETURL, encoding: JSONEncoding.default , headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        print(data);
                        self.CarworkshopsArray = [];
                        self.ImagesCache = [:];
                        
                        for (_,carworkshop):(String,JSON) in data["carworkshops"] {
                            
                            var tmp:CarworkshopTemplate = CarworkshopTemplate();
                            
                            tmp.id = carworkshop["_id"].stringValue;
                            tmp.name = carworkshop["name"].stringValue;
                            tmp.description = carworkshop["description"].stringValue;
                            tmp.havePromo = carworkshop["promo"]["active"].boolValue;
                            tmp.promo = carworkshop["promo"]["description"].stringValue;
                            tmp.phone = carworkshop["phone"].stringValue;
                            tmp.firstPhoto = carworkshop["firstPhoto"].stringValue;
                            tmp.secondPhoto = carworkshop["secondPhoto"].stringValue;
                            tmp.thirdPhoto = carworkshop["thirdPhoto"].stringValue;
                            tmp.logo = carworkshop["logo"].stringValue;
                            tmp.categorie = carworkshop["categorie"].stringValue;
                            tmp.color = carworkshop["color"].stringValue;
                            
                            for (_,subsi):(String,JSON) in carworkshop["subsidiary_id"] {
                                
                                var SubTmp:SubsidiaryTemplate = SubsidiaryTemplate();
                                SubTmp._id = subsi["_id"].stringValue;
                                SubTmp.carworkshop_id = subsi["carworkshop_id"].stringValue;
                                SubTmp.country = subsi["country"].stringValue;
                                SubTmp.phone = subsi["phone"].stringValue;
                                SubTmp.address = subsi["address"].stringValue;
                                SubTmp.long = subsi["coords"].arrayValue[0].doubleValue;
                                SubTmp.lat = subsi["coords"].arrayValue[1].doubleValue;
                                
                                tmp.subsidiaries.append(SubTmp);
                            }
                            
                            self.CarworkshopsArray.append(tmp);
                        }
                        
                        self.CarworkshopsTableView.reloadData();
                        SwiftSpinner.hide();
                        
                    }else{
                        
                        if(data["message"] == "Corrupt Token."){
                            self.performSegue(withIdentifier: "LoginSegue", sender: self);
                        }else{
                            self.alerta("Oops!", Mensaje: data["message"].stringValue );
                            SwiftSpinner.hide();
                        }
                    }
                }else{
                    SwiftSpinner.hide();
                }
            }
            
        case .unknown, .offline:
            SwiftSpinner.hide();
            self.alerta("Sin Conexion", Mensaje: "Favor de conectarse a internet.");
        }
        
        if(self.Refresh.isRefreshing){
            self.Refresh.endRefreshing();
            self.CarworkshopsTableView.contentOffset = CGPoint(x: 0, y: -self.Refresh.frame.size.height);
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.CarworkshopsArray.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CarworkshopTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CarworkshopTableViewCell;
        
        cell.NameLabel.text = self.CarworkshopsArray[(indexPath as NSIndexPath).row].name;
        cell.CategorieLabel.text = self.CarworkshopsArray[(indexPath as NSIndexPath).row].categorie;
        
        if(self.CarworkshopsArray[(indexPath as NSIndexPath).row].havePromo){
            cell.PromoImageView.isHidden = false;
        }else{
            cell.PromoImageView.isHidden = true;
        }
        
        cell.SubsidiariesLabel.text = "\(self.CarworkshopsArray[(indexPath as NSIndexPath).row].subsidiaries.count) Sucursales";
        
        cell.PhoneLabel.text = self.CarworkshopsArray[(indexPath as NSIndexPath).row].phone;
        cell.BackgroundLogoView.backgroundColor = UIColor(hexString: self.CarworkshopsArray[(indexPath as NSIndexPath).row].color);
        
        //DOWNLOAD IMAGE:
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
            var ShouldDownload = true;
            
            if  let imageCache = self.ImagesCache[(indexPath as NSIndexPath).row] {
                ShouldDownload = false;
                DispatchQueue.main.async{
                    cell.LogoImageView.image = imageCache;
                }
            }
            if(ShouldDownload){
                let url = self.ApiUrl + "/images/" + self.CarworkshopsArray[(indexPath as NSIndexPath).row].name.replacingOccurrences(of: " ", with: "") + "/" + self.CarworkshopsArray[(indexPath as NSIndexPath).row].logo;
                print(url);
                if let checkedUrl = URL(string: url) {
                    self.getDataFromUrl(checkedUrl) { data in
                        
                        if let NewImage = UIImage(data: data! as Data){
                            self.ImagesCache[indexPath.row] = NewImage;
                            DispatchQueue.main.async {
                                cell.LogoImageView.image = NewImage;

                            }
                        }else{
                            
                            let MissingImage = UIImage(named: "MissingImage.png");
                            self.ImagesCache[(indexPath as NSIndexPath).row] = MissingImage;
                            DispatchQueue.main.async {
                                cell.LogoImageView.image = MissingImage;
                            }
                        }
                        
                    }
                }
            }
        }
        return cell;
    }
        
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.SelectedCell = (indexPath as NSIndexPath).row;
        self.performSegue(withIdentifier: "ShowDetail", sender: self);
    }
    
    @IBAction func onChangeFilter(_ sender: UISegmentedControl) {
        switch self.typeSegment.selectedSegmentIndex {
        case 1:
            self.ActualFilter = "FRANQUICIA";
        case 2:
            self.ActualFilter = "INDEPENDIENTE";
        case 3:
            self.ActualFilter = "BAJIO";
        default:
            self.ActualFilter = "ALL"
        }
        
        self.ReloadData();
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let dest = segue.destination as? DetailCarworkshopViewController {
                dest.Carworkshop = self.CarworkshopsArray[SelectedCell];
                dest.LogoImage = self.ImagesCache[SelectedCell];
            }
        }
    }
    
    func getDataFromUrl(_ urL:URL, completion: @escaping ((_ data: NSData?) -> Void)) {
        URLSession.shared.dataTask(with: urL) { (data, response, error) in
            completion(data as NSData?)
            }.resume()
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
