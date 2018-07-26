var MobileDetect = require('mobile-detect');

module.exports = function(root,app,express){

	function AdministerPage(req,res){
		res.sendFile(root + '/public/pages/admin.html');
	}

	function LoginPage(req,res){
		res.sendFile(root + '/public/pages/login.html');
	}

	function MainPage(req,res){

		res.sendFile(root + '/public/pages/index.html');

	}

	function AppstoreRedirect(req, res, next){

		var md = new MobileDetect(req.headers['user-agent']);
		if(md.os() === 'iOS') {
			res.redirect(301, 'https://itunes.apple.com/us/app/grúas-gorilas/id1153437033?mt=8')

		}else if(md.os() === 'AndroidOS'){
			res.redirect(301, 'https://play.google.com/store/apps/details?id=com.gruas.gorilas')
		}else{
			console.log("QUE PEDOO");
			res.redirect(301, 'http://inciatus.mx')
		}
	}

	//STATIC ROUTES:
	app.use("/public", express.static(root + "/public"));
	app.use("/bower_components", express.static(root + "/bower_components"));

	app.get('/',AdministerPage);

	app.get('/appstore',AppstoreRedirect);

	app.get("/login",LoginPage);

	//put the index to homepage
	app.get("/dashboard",AdministerPage);


	app.get('*',AdministerPage);


}
