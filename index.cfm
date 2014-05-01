<!---
*
* @author: Jonathan Lucas
* @email: CommandLineDesign@gmail.com
* @description: Testing AngularJS for new FORT FrontEnd
* @version: 1.0
* @requirements: ColdFusion 9.0+
*
--->
<cftry>
	<!--- ::::::::::::::::::::: App Params ::::::::::::::::::::: --->
	<cfset angularTest.AppRoot = "/_test/angularTest">
	<!--- ::::::::::::::::::::: App Includes ::::::::::::::::::::: --->

	<!--- ::::::::::::::::::::: Page Includes ::::::::::::::::::::: --->
	
	<cfoutput>
		script name: #cgi.script_name#
		query path: #cgi.path_info#<br><br>
	</cfoutput>

	<!--- ::::::::::::::::::::: cgi Output ::::::::::::::::::::: --->
	<!doctype html>
	<html ng-app>
		<head>
			<!--- ::::::::::::::::::::: View Includes ::::::::::::::::::::: --->
			<script src="http://code.angularjs.org/angular-1.0.1.min.js"></script>
			<script type="text/javascript">
				function MainCtrl($scope){
					$scope.myName="Jonathan";
				}
			</script>
		</head>
		<body ng-controller="MainCtrl">
			{{myName}}
		</body>
	</html>



	<cfcatch><cfdump var = "#cfcatch#"></cfcatch>
</cftry>
