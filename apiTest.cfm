<!--- Create a base API url. --->
<!--- Modified this to include stage port number for testing. --->
<cfset local.baseAPIUrl = (
	"http://" 
	& cgi.server_name
	& ":8887"
	& getDirectoryFromPath( cgi.script_name ) 
	& "api.cfm"
	) />
<cfdump var="#local.baseAPIURL#">
<cfset local.thispageURL = (
	"http://" 
	& cgi.server_name
	& ":8887"
	& getDirectoryFromPath( cgi.script_name ) 
	& "apitest.cfm"
	) />
<cfif structKeyExists(URL, "resetApp") AND URL.resetApp EQ 1>
	<!--- Return User on Reset --->
	<cfset applicationstop()/>
	<cflocation url="#local.thispageURL#" addtoken="false">
	<cfabort>
</cfif>

<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<h2>
	GET Request
</h2>

<!--- Get the GET request. --->
<cfhttp
	result="result"
	method="get"
	url="#local.baseAPIUrl#/girls/Sarah/kiss.json"
	username="ben"
	password="banana!"
	/>

<cfdump var="#result#">
<br />
<cfdump var="#toString( result.fileContent )#">


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->

<br />
<hr />
<br />

<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<h2>
	GET Request Not Found
</h2>

<!--- Get the GET request. --->
<cfhttp
	result="result"
	method="get"
	url="#local.baseAPIUrl#/girls/Julia/kiss.json"
	username="ben"
	password="banana!"
	/>

<cfdump var="#result#">
<br />
<cfdump var="#toString( result.fileContent )#">


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->

<br />
<hr />
<br />

<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<h2>
	POST Request
</h2>

<!--- Get the POST request. --->
<cfhttp
	result="result"
	method="post"
	url="#local.baseAPIUrl#/girls/Tricia/french-kiss.json"
	username="ben"
	password="bananas!">

	<cfhttpparam
		type="formfield"
		name="approach"
		value="gentle"
		/>

</cfhttp>

<cfdump var="#result#">
<br />
<cfdump var="#toString( result.fileContent )#">


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->

<br />
<hr />
<br />

<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<h2>
	Second POST Request (For Duplicate Check)
</h2>

<!--- Get the POST request. --->
<cfhttp
	result="result"
	method="post"
	url="#local.baseAPIUrl#/girls/Tricia/french-kiss.json"
	username="ben"
	password="bananas!">

	<cfhttpparam
		type="formfield"
		name="approach"
		value="gentle"
		/>

</cfhttp>

<cfdump var="#result#">
<br />
<cfdump var="#toString( result.fileContent )#">


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->

<br />
<hr />
<br />

<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<h2>
	Invalid POST Request
</h2>

<!--- Get the POST request. --->
<cfhttp
	result="result"
	method="post"
	url="#local.baseAPIUrl#/girls/Tricia/french-kiss.json"
	username="ben"
	password="bananas!">

	<!--- Invalid form data. --->
	<cfhttpparam
		type="formfield"
		name="approach"
		value="rough"
		/>

</cfhttp>

<cfdump var="#result#">
<br />
<cfdump var="#toString( result.fileContent )#">