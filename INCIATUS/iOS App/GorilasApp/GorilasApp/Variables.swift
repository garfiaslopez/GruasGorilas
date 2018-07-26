//
//  Variables.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 21/12/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//
import Foundation
import UIKit
import SwiftyJSON

class VARS {
    
    let MaxToTopConstrait = CGFloat(-141);
    let MinToTopConstrait = CGFloat(16);
    let PrimaryYellow = UIColor(red: 249/255, green: 189/255, blue: 39/255, alpha: 1);
    let PrimaryYellowDisable = UIColor(red: 249/255, green: 189/255, blue: 39/255, alpha: 0.60);
    
    func getApiUrl() -> String {
        
        // return "http://192.168.1.79:3000";
        
        // Servidor:
        return "http://10.33.116.25:3000";
    }
    func getConektaPublicKey() -> String {
        
        // DEV:
        return "AIzaSyD605kdM8LFM8lH9lMs72V_JcDAW6MvYiM";
        
        // PROD:
        //return "key_Ukmunmcs1dMUqxWf93vmyCg";
        
    }
    func getGoogleKey() -> String {
        return "AIzaSyAQQUYDW9EPcYfrXxbzAnMfoULJzYTalA8";
    }
    func getMailgunUrl() -> String {
        return "https://api.mailgun.net/v3/inciatus.mx/messages";
    }
    func getMailgunKey() -> String {
        return "key-d3b4220e9454ff1ceb516820dee68cdf";
    }
    
}


class Network {
    
}


struct Condition {
    var CarGeneralStatus = "";
    
}
struct Loc {
    var address:String = "";
    var long:Double = 0.0;
    var lat:Double = 0.0;
}



struct Session {
    
    var _id:String = "";
    var token:String = "";
    var phone:String = "";
    var name:String = "";
    var email:String = "";
    var typeuser:String = "";
    
    init(){
        
        if let UsuarioRecover = UserDefaults.standard.dictionary(forKey: "UsuarioEnSesion") {
            if let value = UsuarioRecover["_id"] as? NSString {
                _id = value as String;
            }
            if let value = UsuarioRecover["token"] as? NSString {
                token = value as String;
            }
            if let value = UsuarioRecover["phone"] as? NSString {
                phone = value as String;
            }
            if let value = UsuarioRecover["name"] as? NSString {
                name = value as String;
            }
            if let value = UsuarioRecover["email"] as? NSString {
                email = value as String;
            }
            if let value = UsuarioRecover["typeuser"] as? NSString {
                typeuser = value as String;
            }
        }
        
    }
}

struct RequestModel {
    var origin:Loc = Loc();
    var destiny:Loc = Loc();
    var user:Session = Session();
    var condition:Array<String> = [];
    var oper:UserTemplate = UserTemplate();
    var date:String = "";
    var car:CarTemplate = CarTemplate();
    var isSchedule:Bool = false;
}

struct OrderModel {
    
    var _id:String = "";
    var order_id:String = "";
    var origin:Loc = Loc();
    var destiny:Loc = Loc();
    var conditions:String = "";
    var oper:UserTemplate = UserTemplate();
    var user:UserTemplate = UserTemplate();
    var date:String = "";
    var carinfo:String = "";
    var paymethod: String = "";
    var total: Double = 0.0
    var status: String = "Nothing";
    var isPaid: Bool = false;
    var tow: String = "";
    var group: String = "";
    var isQuotation: Bool = false;
    var isSchedule: Bool = false;
    var dateSchedule: Date = Date();
    
    init(){
    }
    
    init(data: JSON) {
        
        print("RAW ORDER");
        print(data);
        
        self._id = data["_id"].stringValue;
        self.date = data["date"].stringValue;
        self.order_id = data["order_id"].stringValue;
        self.isPaid = data["isPaid"].boolValue;
        self.isSchedule = data["isSchedule"].boolValue;
        self.isQuotation = data["isQuotation"].boolValue;
        self.dateSchedule = Formatter().ParseMomentDate(data["dateSchedule"].stringValue);
        self.paymethod = data["paymethod"].stringValue;
        self.total = data["total"].doubleValue;
        
        // UTF8 -> ISO-8859-1  (Latin1)
        
        let OriginDen:String = data["origin"]["denomination"].stringValue;
        let DestinyDen:String = data["destiny"]["denomination"].stringValue;
        var convertedOrigin: Array<CChar> = Array(repeating: 32, count: (OriginDen.characters.count + 1));
        var convertedDestiny: Array<CChar> = Array(repeating: 32, count: (DestinyDen.characters.count + 1));
        OriginDen.getCString(&convertedOrigin, maxLength: (OriginDen.characters.count + 1), encoding: .isoLatin1);
        DestinyDen.getCString(&convertedDestiny, maxLength: (DestinyDen.characters.count + 1), encoding: .isoLatin1);

        self.origin = Loc(address: String(cString: convertedOrigin),
                          long: data["origin"]["cord"][0].doubleValue,
                          lat: data["origin"]["cord"][1].doubleValue);
        self.destiny = Loc(address: String(cString: convertedDestiny),
                           long: data["destiny"]["cord"][0].doubleValue,
                           lat: data["destiny"]["cord"][1].doubleValue);
        self.status = data["status"].stringValue;
        self.conditions = data["conditions"].stringValue;
        self.carinfo = data["carinfo"]["brand"].stringValue + " " + data["carinfo"]["model"].stringValue + ", " +
            data["carinfo"]["color"].stringValue + ", " + data["carinfo"]["plate"].stringValue;
        
        self.user = UserTemplate(name: data["user_id"]["name"].stringValue, rate: data["user_id"]["rate"]["average"].doubleValue, phone: data["user_id"]["phone"].stringValue, _id: data["user_id"]["_id"].stringValue, typeuser: data["user_id"]["typeuser"].stringValue,lat:0.0,long:0.0);
        
        self.oper = UserTemplate(name: data["operator_id"]["name"].stringValue, rate: data["operator_id"]["rate"]["average"].doubleValue, phone: data["operator_id"]["phone"].stringValue, _id: data["operator_id"]["_id"].stringValue, typeuser: data["operator_id"]["typeuser"].stringValue,lat:data["operator_id"]["loc"]["cord"][1].doubleValue,long:data["operator_id"]["loc"]["cord"][0].doubleValue);
        
        self.tow = "Numero: \(data["tow"]["economicNumber"].stringValue), Placas: \(data["tow"]["plate"].stringValue)";
        self.group = "\(data["group"]["name"])";
        
    }
}

struct PaymethodModel {
    var tokenization:String = "";
    var termination:String = "";
    var brand:String = "";
}

struct UserTemplate {
    var name:String = "";
    var rate:Double = 0.0;
    var phone:String = "";
    var _id:String = "";
    var typeuser:String = "";
    var lat:Double = 0.0;
    var long:Double = 0.0;
}

struct NoticeTemplate {
    var _id:String = "";
    var title:String = "";
    var description:String = "";
    var created:String = "";
}


struct CarTemplate {
    var _id:String = "";
    var brand:String = "";
    var plates:String = "";
    var model:String = "";
    var color:String = "";
}

struct RouteExampleTemplate {
    var origin:String = "";
    var destiny:String = "";
    var price:Double = 0.0;
}


struct SubsidiaryTemplate {
    var _id:String = "";
    var carworkshop_id:String="";
    var country:String="";
    var phone:String="";
    var address:String="";
    var long:Double=0.0;
    var lat:Double=0.0;
}

struct CarworkshopTemplate {
    var name:String = "";
    var id:String = "";
    var logo:String = "";
    var categorie:String = "";
    var description:String = "";
    var phone:String = "";
    var color:String = "";
    var havePromo:Bool = false;
    var promo:String = "";
    var firstPhoto:String="";
    var secondPhoto:String="";
    var thirdPhoto:String="";
    var subsidiaries:Array<SubsidiaryTemplate> = [];
}

struct DashboardTemplate {
    var color:UIColor = UIColor.clear;
    var icon:String = "tickets.png";
    var total:String = "$0.0";
    var count:String = "0";
    var description:String = "Servicios";
}



