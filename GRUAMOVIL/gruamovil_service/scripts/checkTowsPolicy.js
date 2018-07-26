var mongoose = require("mongoose");
var Schema = mongoose.Schema;
process.env.NODE_ENV = process.env.NODE_ENV || 'development';
var config = require('../config/config');
var dbMongo = mongoose.connect(config.dbMongo);
var moment = require('moment');

var TowModel = require("../models/tow");
var GroupModel = require("../models/group");

var api_key = config.mailgunKey;
var domain = config.mailgunUrl;
var mailgun = require('mailgun-js')({apiKey: api_key, domain: domain});

function sendMail(msg) {
    var data = {
      from: 'App Gorilas <soporte@gorilasapp.com.mx>',
      to: 'Gruas Gorilas <operaciones@gruasgorilas.com.mx>',
      subject: 'Poliza de grua pronto a vencer!',
      html: msg
    };
    mailgun.messages().send(data, function (error, body) {
        console.log("Mensaje enviado");
    });
}

var today = moment();
var finalDate = moment();
finalDate.add(15, 'days');

var Query = {};
Query['expirationDate'] = {
    $gte: today.toDate(),
    $lte: finalDate.toDate()
};

console.log(Query);
TowModel.find(Query).populate('group').exec(function(err, Tows) {
    if(err){
        console.log("ERROR GETTING TOWS");
        console.log(err);
    }
    if(Tows) {
        Tows.forEach(function(tow){
            var towDate = moment(tow.expirationDate);
            var diff = finalDate.diff(towDate, 'days');
            var text =  'La grua con placas: ' + tow.plate +
                        ', Numero economico: '+ tow.economicNumber +
                        ', Numero: '+ tow.serialNumber +
                        ', Poliza de: ' + tow.policyCompany +
                        ', Numero de poliza: ' + tow.policyNumber +
                        ', Perteneciente al grupo: ' + tow.group.name +
                        ', del responsable: ' + tow.group.responsibleName +
                        ', le queda:  ' + diff + '  dias de vigencia, favor de reportar que pronto caducará.';
            sendMail(text);
        });
    }else{
        console.log("Empty tows");
    }
});
