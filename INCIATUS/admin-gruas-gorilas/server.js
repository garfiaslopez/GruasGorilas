
var express = require("express");
var app = express();

var bodyParser = require("body-parser");
var morgan = require("morgan");

//Config File
process.env.NODE_ENV = process.env.NODE_ENV || 'test';

var config = require('./config/config');

var port = process.env.PORT || config.port;

//APP CONFIGURATION:
function headers(req,res,next){
	res.setHeader('Access-Control-Allow-Origin', '*');
	res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTION');
	res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type, \ authorization');
	next();
}

app.use(bodyParser.urlencoded({extended:true}));
//app.use(bodyParser.json());
app.use(headers);
app.use(morgan("dev"));

//SET THE ROUTES OF ALL:
require("./app/routes/setroutes")(__dirname,app,express);


//START SERVER:
app.listen(port);
console.log("Server started at port: " + port);
