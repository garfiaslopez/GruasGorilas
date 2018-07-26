angular.module('RouterCtrl',['ngRoute','DashboardCtrl','UserCtrl','UserAdminCtrl','VendorCtrl','RouteExampleCtrl','CouponCtrl','CarworkshopCtrl','NoticeCtrl','HistoryCtrl','HelpCtrl','GroupCtrl','TowCtrl']).config(function($routeProvider, $locationProvider){

	$routeProvider.when('/Dashboard',{
		templateUrl: '/public/pages/admin/dashboard.html',
		controller: 'DashboardController',
		controllerAs: 'Dashboard'
	}).when('/UserAdmin',{
		templateUrl: '/public/pages/admin/useradmin.html',
		controller: 'UserAdminController',
		controllerAs: 'UserAdmin'
	}).when('/User',{
		templateUrl: '/public/pages/admin/user.html',
		controller: 'UserController',
		controllerAs: 'User'
	}).when('/Groups',{
		templateUrl: '/public/pages/admin/group.html',
		controller: 'GroupController',
		controllerAs: 'Group'
	}).when('/Tows',{
		templateUrl: '/public/pages/admin/tow.html',
		controller: 'TowController',
		controllerAs: 'Tow'
	}).when('/Vendor',{
		templateUrl: '/public/pages/admin/vendor.html',
		controller: 'VendorController',
		controllerAs: 'Vendor'
	}).when('/RouteExample',{
		templateUrl: '/public/pages/admin/routeexample.html',
		controller: 'RouteExampleController',
		controllerAs: 'RouteExample'
	}).when('/Coupon',{
		templateUrl: '/public/pages/admin/coupon.html',
		controller: 'CouponController',
		controllerAs: 'Coupon'
	}).when('/Carworkshop',{
		templateUrl: '/public/pages/admin/carworkshop.html',
		controller: 'CarworkshopController',
		controllerAs: 'Carworkshop'
	}).when('/Notice',{
		templateUrl: '/public/pages/admin/notice.html',
		controller: 'NoticeController',
		controllerAs: 'Notice'
	}).when('/History',{
		templateUrl:'../public/pages/admin/history.html',
		controller:'HistoryController',
		controllerAs:'History'
	}).when('/Help',{
		templateUrl:'../public/pages/admin/help.html',
		controller:'HelpController',
		controllerAs:'Help'
	});

	$locationProvider.html5Mode(true);

});
