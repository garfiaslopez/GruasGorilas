//
//  RouteExampleViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 08/01/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class RouteExampleViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let Variables = VARS();
    let Save = UserDefaults.standard;
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var Routes:Array<RouteExampleTemplate> = [];
    
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var RoutesTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil);
        self.RoutesTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        SwiftSpinner.setTitleFont(UIFont(name: "Roboto-Regular.ttf", size: 15.0))
    }

    
    override func viewDidAppear(_ animated: Bool) {
        self.ReloadData();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_RouteExamples")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    func ReloadData(){
        SwiftSpinner.show("Consultando tarifas");

        let AuthUrl = Variables.getApiUrl() + "/routeexample";
        
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
                        
                        self.Routes = [];
                        
                        for (_,route):(String,JSON) in data["routes"] {
                            
                            var tmp:RouteExampleTemplate = RouteExampleTemplate();
                            
                            tmp.origin = route["origin"].stringValue;
                            tmp.destiny = route["destiny"].stringValue;
                            tmp.price = route["price"].doubleValue;
                            
                            self.Routes.append(tmp);
                        }
                        
                        print("Routes \(self.Routes.count)");
                        
                        self.RoutesTableView.reloadData();
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
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Routes.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell;

        cell.DescriptionLabel.text = "\(self.Routes[(indexPath as NSIndexPath).row].origin) - \(self.Routes[(indexPath as NSIndexPath).row].destiny)";
        cell.ValueLabel.text = "$\(self.Routes[(indexPath as NSIndexPath).row].price)";
        
        return cell
    }

}
