var AuthServices = angular.module('AuthService',['ngRoute']);


AuthServices.constant('configData', {
    ENV: "development",
    APIURL: "http://localhost:3000",
    baseURL: "http://localhost:3000"
});

// AuthServices.constant('configData', {
//     ENV: "development",
//     APIURL: "http://45.55.200.39:3000",
//     baseURL: "http://45.55.200.39:3000"
// });


AuthServices.factory("Auth",function($http,$q,AuthToken,configData){

	var AuthFactory = {};
	AuthFactory.LoginAdmin = function(username,password){

	       var Url = configData.baseURL + "/authenticate/admin";

	          return $http.post(Url , { username: username, password: password }).success(function(data){
			console.log(data);
			AuthToken.SetToken(data.token);
			return data;
		});
	}

	AuthFactory.Login = function(username,password){

		var Url = configData.baseURL + "/authenticate";

		return $http.post(Url , {

			username: username,
			password: password

		}).success(function(data){

			console.log(data);

			AuthToken.SetToken(data.token);
			return data;

		});
	}

	AuthFactory.LogOut = function(){
		AuthToken.SetToken();
	}

	AuthFactory.isLoggedIn = function(){

		if(AuthToken.GetToken()){
			return true;
		}else{
			return false;
		}

	}

	AuthFactory.GetUser = function(){

		if (AuthToken.GetToken()) {
			return $http.get("/api/me");
		}else{
			return $q.reject({message:"User has no token"});
		}
	}

	return AuthFactory;

});


AuthServices.factory("AuthToken", function($window){

	var AuthTokenFactory = {};

	//get the token from localstorage from browser
	AuthTokenFactory.GetToken = function(){

		return $window.localStorage.getItem("token-FC");

	}
	//guardar el token en localstorage:
	AuthTokenFactory.SetToken = function(token){

		if(token){
			$window.localStorage.setItem("token-FC",token);

		}else{

			$window.localStorage.removeItem("token-FC");
		}
	}


	return AuthTokenFactory;

});


AuthServices.factory("AuthInterceptor",function($q, $location, AuthToken){

	var InterceptorFactory = {};

	InterceptorFactory.request = function(config){

		var token = AuthToken.GetToken();
		if(token){
			config.headers["Authorization"] = token;
		}
		return config;
	}

	InterceptorFactory.ResponseError = function(response){

		if(response.status == 403){
			AuthToken.SetToken();
			$location.path("/");
		}
		return $q.reject(response);
	}
	return InterceptorFactory;
});
