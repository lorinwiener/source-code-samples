(function(){

	var app = angular.module('commutingCostComparisonApp', []);

	app.controller('CommutingCostComparisonController', ['$scope', function($scope) {
		
		// Constants

		// Fuel efficiency in mpg
		$scope.non_turbo_fuel_efficiency = 24;
		$scope.turbo_fuel_efficiency = 21;

		// Default values
		$scope.avg_fuel_cost = "2.39";
		$scope.miles_per_year = 12000;
		$scope.days_per_year = 365;

		$scope.calculate = function() {			

			$scope.non_turbo_fuel_cost = ((Number($scope.avg_fuel_cost) * $scope.miles_per_year) / $scope.non_turbo_fuel_efficiency);

			$scope.turbo_fuel_cost = ((Number($scope.avg_fuel_cost) * $scope.miles_per_year) / $scope.turbo_fuel_efficiency);
		
		}

		$scope.calculate();

	}]);


})();
