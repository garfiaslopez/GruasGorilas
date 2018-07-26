var Services = angular.module('Service',['ngRoute']);


Services.service('MainVars', function() {
  var User = {};
  var SetUserData = function(user){
  	User = user;
};
  var GetUserData = function(){
  	return User;
  };

  return {
    SetUser: SetUserData,
    GetUser: GetUserData
  };
});


// Services.factory("Socket",function($http,$q,socketFactory,configData){
//     var myIoSocket = io.connect(configData.APIURL);
//     mySocket = socketFactory({
//         ioSocket: myIoSocket
//     });
//     return mySocket;
// });

Services.factory("UserAdminServ",function($http,$q,configData){

	var Obj = {};
	var Url = configData.APIURL + "/useradmin"


	Obj.Create = function(Data){

		return $http.post(Url, {

			username: Data.username,
			password: Data.password

		}).success(function(data){
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;

		return $http.put(UpdateUrl,{
			username: Data.username,
			password: Data.password
		}).success(function(data){
			return data;
		});
	}
	Obj.Delete = function(Id){

		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});

Services.factory("UserServ",function($http,$q,configData){

	var Obj = {};
	var Url = configData.APIURL + "/user"

	Obj.All = function(){
		return $http.get(Url + "/by/users").success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;

		return $http.put(UpdateUrl,{
			username: Data.username,
			password: Data.password
		}).success(function(data){
			return data;
		});
	}
	Obj.Delete = function(Id){

		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}

    Obj.Block = function(id){
        return $http.post(configData.APIURL + "/blockuser", {
            user_id: id
        }).success(function(data){
            return data;
        });
    }

	return Obj;
});


Services.factory("VendorServ",function($http,$q,configData){

	var Obj = {};

	console.log(configData);
	var Url = configData.APIURL + "/user"

	Obj.Create = function(Data){
        console.log("ON CREATE FUNC");
		return $http.post(Url, {
			email: Data.email,
            group: Data.group,
            tow: Data.tow,
			type: Data.type,
			password: Data.password,
			name: Data.name,
			phone: Data.phone,
			birthdate: Data.birthdate,
            driverLicense: Data.driverLicense,
			othercontact: {
				name: Data.othercontact.name,
				phone: Data.othercontact.phone
			},
            typeuser:"operator"
		}).success(function(data){
            console.log(data);
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(Url + "/by/vendors").success(function(data){
			return data;
		});
	}

    Obj.Block = function(id){
        return $http.post(configData.APIURL + "/blockuser", {
			operator_id: id
		}).success(function(data){
			return data;
		});
	}

	Obj.AllByGroup = function(id){
		return $http.get(Url + "/by/group/" + id).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;

		return $http.put(UpdateUrl,{
			username: Data.username,
			password: Data.password
		}).success(function(data){
			return data;
		});
	}
	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});

Services.factory("RouteExampleServ",function($http,$q,configData){

	var Obj = {};
	console.log(configData);
	var Url = configData.APIURL + "/routeexample"

	Obj.Create = function(Data){
		return $http.post(Url, {
			origin: Data.origin,
			destiny: Data.destiny,
			price: Data.price
		}).success(function(data){
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;

		return $http.put(UpdateUrl,{
            origin: Data.origin,
			destiny: Data.destiny,
			price: Data.price
		}).success(function(data){
			return data;
		});

	}
	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});


Services.factory("CarworkshopServ",function($http,$q,configData){

	var Obj = {};
	console.log(configData);
	var Url = configData.APIURL + "/carworkshop"

    Obj.Create = function(Data){
        console.log("ON Create TALLER SERVICE");
        console.log(Data);

		var fd = new FormData();
		for (var key in Data){
            fd.append(key, Data[key]);
		}
		return $http.post(Url,fd,{
            transformRequest: angular.identity,
            headers: {'Content-Type': undefined}
        }).success(function(data){
			return data;
		});
    }

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;
        var fd = new FormData();
		for (var key in Data){
            fd.append(key, Data[key]);
		}
		return $http.put(UpdateUrl,fd,{
            transformRequest: angular.identity,
            headers: {'Content-Type': undefined}
        }).success(function(data){
			return data;
		});
	}

    Obj.UpdatePromo = function(Id,Data){
        var UpdateUrl = Url +'/'+ Id;

        var data = {
            promo: {
                description: Data.description,
                active: Data.active
            }
        }
		return $http.put(UpdateUrl,data).success(function(data){
			return data;
		});
    }

	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});

Services.factory("SubsidiaryServ",function($http,$q,configData){

	var Obj = {};
	var Url = configData.APIURL + "/subsidiary"

	Obj.Create = function(Data){
		return $http.post(Url, {
			country: Data.country,
			phone: Data.phone,
			lat: Data.lat,
            long: Data.long,
            carworkshop_id: Data.carworkshop_id,
            address: Data.address
		}).success(function(data){
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;
		return $http.put(UpdateUrl,{
            country: Data.country,
			phone: Data.phone,
			lat: Data.lat,
            long: Data.long,
            carworkshop_id: Data.carworkshop_id,
            address: Data.address
		}).success(function(data){
			return data;
		});

	}
	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});


Services.factory("CouponServ",function($http,$q,configData){

	var Obj = {};
	var Url = configData.APIURL + "/coupon"

	Obj.Create = function(Data){
		return $http.post(Url, {
			code: Data.code,
			discount: Data.discount,
			description: Data.description,
            expiration: Data.expiration,
            isActive: Data.isActive
		}).success(function(data){
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;
		return $http.put(UpdateUrl,{
            code: Data.code,
			discount: Data.discount,
			description: Data.description,
            expiration: Data.expiration,
            isActive: Data.isActive
		}).success(function(data){
			return data;
		});

	}
	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});

Services.factory("NoticeServ",function($http,$q,configData){

	var Obj = {};
	var Url = configData.APIURL + "/notice"

	Obj.Create = function(Data){
		return $http.post(Url, {
			title: Data.title,
			description: Data.description
		}).success(function(data){
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){
		var UpdateUrl = Url +'/'+ Id;
		return $http.put(UpdateUrl,{
			title: Data.title,
			description: Data.description
		}).success(function(data){
			return data;
		});

	}
	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});



Services.factory("HelpServ",function($http,$q,configData){

	var Obj = {};
	var Url = configData.APIURL + "/help"

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}

	return Obj;
});


Services.factory("HistoryServ",function($http,$q,configData){
	var Obj = {};
	var BaseUrl = configData.APIURL + '/orders/byFilters';

	Obj.AllWithFilter = function(filter){
		return $http.post(BaseUrl,filter).success(function(data){
			return data;
		});
	};

    var AvailableUrl = configData.APIURL + '/users/byavailable';

    Obj.AllAvailable = function(){
        return $http.get(AvailableUrl).success(function(data){
            return data;
        });
    }
    Obj.Connections = function(operator_id) {

    }

    Obj.Delete = function(Id){
        var DeleteUrl = configData.APIURL + '/order' +'/'+ Id;
        return $http.delete(DeleteUrl).success(function(data){
            return data;
        });
	};

    Obj.Available = function(Id){
        return $http.post(configData.APIURL + "/availableoperator", {
            operator_id: Id
        }).success(function(data){
            return data;
        });
    }

    Obj.RestartServer = function(){
        return $http.post(configData.APIURL + "/restartserver", {
        }).success(function(data){
            return data;
        });
    }

	return Obj;
});



Services.factory("GroupServ",function($http,$q,configData){
	var Obj = {};
	var Url = configData.APIURL + "/group"

	Obj.Create = function(Data){
		return $http.post(Url,Data).success(function(data){
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;

		return $http.put(UpdateUrl,Data).success(function(data){
			return data;
		});
	}
	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});




Services.factory("TowServ",function($http,$q,configData){
	var Obj = {};
	var Url = configData.APIURL + "/tow"

	Obj.Create = function(Data){
		return $http.post(Url,Data).success(function(data){
			return data;
		});
	}

    Obj.ByGroup = function(id) {
        return $http.get(Url + '/bygroup/' + id).success(function(data){
            return data;
        });
    }

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;

		return $http.put(UpdateUrl,Data).success(function(data){
			return data;
		});
	}
	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});


Services.factory("ConectionServ",function($http,$q,configData){
	var Obj = {};
	var BaseUrl = configData.APIURL + '/connections';

	Obj.AllByOperator = function(operator){
		return $http.get(BaseUrl + '/' + operator ).success(function(data){
			return data;
		});
	};

	return Obj;

});
