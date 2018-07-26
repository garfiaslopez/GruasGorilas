//MODELS
var MobileDetect = require('mobile-detect');
module.exports = {
	redirectToAppstore: function(req,res,next){
        var md = new MobileDetect(req.headers['user-agent']);
        if(md.os() === 'iOS') {
            res.redirect('https://itunes.apple.com/us/app/grúas-gorilas/id1153437033?mt=8', next);
        }else if(md.os() === 'AndroidOS'){
            res.redirect('https://play.google.com/store/apps/details?id=com.gruas.gorilas', next);
        }else{
            res.redirect('https://www.inciatus.mx', next);
        }
	}
}
