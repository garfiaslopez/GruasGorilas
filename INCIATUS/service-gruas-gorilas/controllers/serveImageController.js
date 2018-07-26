//MODELS
var fs = require('fs');
var mkdirp = require('mkdirp');

module.exports = {

	Get: function(req,res,next){
        var dir = __dirname.substring(0, __dirname.indexOf('\controllers'));
        var maindirectory = 'uploads/photos/' + req.params.carworkshop.replace(/\s/g, '') + '/' + req.params.filename;
        var fulldirectory = dir + maindirectory;
        fs.readFile(fulldirectory, function (err, file) {
            if (err) {
				res.send(500,JSON.stringify({success: false , message: "Error fallo alguna validacion."}));;
            }
            res.writeHead(200);
            res.write(file);
            res.end();
            return next();
        });
	},
	UploadProfileImage: function(req,res,next){
		var dir = __dirname.substring(0, __dirname.indexOf('\controllers'));
		var maindirectory = 'uploads/photos/profiles';
		var fulldirectory = dir + maindirectory;
		mkdirp(fulldirectory, function(err) {
			if(err){
				res.json({success: false , message: "Error creando directorio para imagenes."});;
			}else{
				if (req.files.profilePhoto) {
					var filedirectory = fulldirectory + '/' + req.files.profilePhoto.name.replace(/\s/g, '');
					fs.readFile(req.files.profilePhoto.path, function (err, data) {
						if (err) {
							console.log(err);
							res.json({success: false , message: "Error al subir imagen."});;
						}
						fs.writeFile(filedirectory, data, function (err) {
							if (err) {
								res.json({success: false , message: "Error al subir imagen."});;
							}
							res.json({success: true , message: "Imagen cargada exitosamente."});;
						});
					});
				}else{
					res.json({success: false , message: "Imagen no detectada."});;
				}
			}
		});
	},
	GetProfileImage: function(req,res,next) {
		var dir = __dirname.substring(0, __dirname.indexOf('\controllers'));
		var maindirectory = 'uploads/photos/profiles/' + req.params.user_id + '.jpeg';
		var fulldirectory = dir + maindirectory;
		fs.readFile(fulldirectory, function (err, file) {
			if (err) {
				console.log(err);
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.writeHead(200);
			res.write(file);
			res.end();
			return next();
		});
	}
}
