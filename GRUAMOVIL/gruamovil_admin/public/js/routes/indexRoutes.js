angular.module('RouteIndex',['ngRoute','HomeCtrl','AboutCtrl','ServicesCtrl','GalleryCtrl','ContactCtrl']).config(function($routeProvider, $locationProvider){
	
		$routeProvider.when('/Home',{
			templateUrl: '/public/pages/index/home.html',
			controller: 'HomeController',
			controllerAs: 'Home'
		}).when('/About',{
			templateUrl:'public/pages/index/about.html',
			controller:'AboutController',
			controllerAs:'About'

		}).when('/Services',{
			templateUrl:'../public/pages/index/services.html',
			controller:'ServiciosController',
			controllerAs:'Services'
		}).when('/Gallery',{
			templateUrl:'../public/pages/index/gallery.html',
			controller:'GaleriaController',
			controllerAs:'Gallery'
		}).when('/Contact',{
			templateUrl:'../public/pages/index/contact.html',
			controller:'ContactoController',
			controllerAs:'Contact'
		});

	$locationProvider.html5Mode(true);

});