<!--- From the API building demo at: 

http://www.bennadel.com/blog/1990-building-a-twitter-inspired-restful-api-architecture-in-coldfusion.htm 

--->



<!---
	This demo API is going to be kept super simple. It supports the
	following resources:

	GET /girls/{name}/kiss.format
	POST /girls/{name}/french-kiss.format
--->

<!---
	When processing this API request, we are going to deal with a lot
	of opportunities for failure. As such, we are going to execute
	the entire API processing in a CFTry / CFCatch such that we can
	catch the various errors that might need to be dealt with.
--->
<cftry>

	<!---
		As the API request is processed, we're going to need to
		collect information about the request and the response. This
		might valid data, this might be a collection of errors.
		Ultimately, this information is what will be used to
		formulate the response to the client.

		Username - The authorized user.
		Password - The authorized user's password.
		Resource - The resource URI requsted by the user.
		Method - The type of request (get, post).
		Data - The data returned from the API resposne.
		Errors - A collection of errors.
		Format - The format (json,xml) or the response.
		Headers - The collection of additional response HTTP headers.
		StatusCode - The HTTP status code of the response.
		StatusText - The HTTP status text of the response.
		MimeType - The MimeType of the response.
		Content - The serialized version of the response.
		Session - Session data for this user accross requests.
		RateLimit - The max number of requests the user can make per minute.
	--->
	<cfset api = {
		username = "",
		password = "",
		resource = "",
		method = cgi.request_method,
		data = "",
		errors = [],
		format = "json",
		headers = {},
		statusCode = "200",
		statusText = "OK",
		mimeType = "",
		content = "",
		session = {},
		rateLimit = 30
		} />


	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->


	<!---
		The first thing we want to do is check to see if the user
		is making a valid request. In order to use the API, the user
		must be using the "PATH_INFO". That is, they must be passing
		additional REST-resource data as the path information of
		their request:

		api.cfm/MY/RESOURCE/PATH.{FORMAT}

		As you can see, the REST-resource URI is what is comging
		after the "api.cfm" value.

		NOTE: If you were using URL-rewriting, you wouldn't need to
		use PATH_INFO. But, in order to make this as portable as
		possible, I am using it to demo the API work flow.

		NOTE: If this check fails, we will have to rely on the
		default data format (JSON) since we cannot be sure that user
		is event requesting a valid data format.
	--->

	<!---
		Check to make sure the script name and the path info are
		NOT the same. If they are, that means that no path info
		was provided.

		NOTE: This is only needed for IIS. Apache does not send the
		requested script as the PATH_INFO when none is available.
	--->
	<cfif (cgi.script_name eq cgi.path_info)>

		<!--- Set the error message. --->
		<cfset api.errors = [
			"No resource was requested. Please use PATH_INFO to define the desired resouce. Example: ./api.cfm/MY/RESOURCE/PATH.json."
			] />

		<!--- Raise a malformed request exception. --->
		<cfthrow type="BadRequest" />

	</cfif>

	<!---
		Now that we have checked that a resource was provided, let's
		check to see if it has a valid format. Here, we are checking
		that the resource has the general pattern of:

		/path/to/resource.format
	--->
	<cfif !reFind( "^/\w+(/[^/]+)*\.\w+$", cgi.path_info )>

		<!--- Set the error message. --->
		<cfset api.errors = [
			"The resource path you requested was not formatted properly. Valid resources are in the form of [/path/to/resource.format]."
			] />

		<!--- Raise a malformed request exception. --->
		<cfthrow type="BadRequest" />

	</cfif>


	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->


	<!---
		Now that we have checked that a resource we provided and is
		generally in the right format, we need to check to see if
		the format that was requested is supported by this API. The
		requested format is the last part of the resource path, after
		the period.

		NOTE: I am demonstrating this format in an API-wide
		implementation. You could also do this on a per-resource
		way in which each unique resource (and VERB) could have its
		own set of supported formats.
	--->
	<cfif reFindNoCase( "\.(json|xml)$", cgi.path_info )>

		<!---
			The format they requests is valid, so let's extract it
			and store it for the response.
		--->
		<cfset api.format = listLast( cgi.path_info, "." ) />

		<!---
			Also, now that we have the format, we can extract
			the actual resource URL, which is everything minus
			the format.
		--->
		<cfset api.resource = reReplace(
			cgi.path_info,
			"\.[^.]+$",
			"",
			"one"
			) />

	<cfelse>

		<!--- The requested format is not currently supported. --->

		<!--- Set the error message. --->
		<cfset api.errors = [
			"The format you requested [#listLast( cgi.path_info, '.' )#] is not currently supported by this API. Only JSON and XML formats are supported."
			] />

		<!--- Raise a not acceptable format exception. --->
		<cfthrow type="NotAcceptable" />

	</cfif>


	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->


	<!---
		Now that we know that the user is making a proper API
		request, we need to make sure that the user is authorized
		to make this API request. For this demo, we are going to
		require all requests GET and POST to be authorized (we're
		not going to be authenticating against any database).
	--->

	<!--- Get the request data. --->
	<cfset requestData = getHTTPRequestData() />

	<!---
		When we check for authorization, there are a number of
		things that can go wrong:

		- Authorization was not provided
		- Authorization is not formed properly
		- Authorization is not valid

		As such, we are going to perform this in its own try/catch
		block and proceed as if the best case scenario is met.
	--->
	<cftry>

		<!--- Get the authorization entry from the request data. --->
		<cfset authorization = requestData.headers.authorization />

		<!---
			Get the encoded credentials. This is the base64 encoded
			part of the authentication string. We can think of this
			as the second item in a space-delimited list:

			Example:
			Basic YmVuQGJlbm5hZGVsLmNvbTpJTG92ZUNvbGRGdXNpb24=
		--->
		<cfset credentials = toString(
			toBinary(
				listLast( authorization, " " )
				)
			) />

		<!---
			At this point, our credentials should be a colon-
			delimited list of "username:password." In this approach,
			we are using listGetAt() rather than listFirst() and
			listLast() to ensure that if the list is not the right
			length, an exception will be raised.
		--->
		<cfset api.username = listGetAt( credentials, 1, ":" ) />
		<cfset api.password = listGetAt( credentials, 2, ":" ) />


		<!---
			For this demo, we are going to be very lose with the
			authorizations. All we are going to require is that the
			user has some sort of username and password. We're not
			going to authorize against any database.
		--->
		<cfif !(
			len( api.username ) &&
			len( api.password )
			)>

			<!---
				The credentials are not valid. Throw an error. This
				will get caught along with any other error raised
				during authorization.
			--->
			<cfthrow type="Unauthorized" />

		</cfif>


		<!---
			Catch any exceptions that were raised during
			authentication. This could be from a malformed request
			or from invalid / missing credentials.
		--->
		<cfcatch>
		
			<!--- Set the error message for the response. --->
			<cfset api.errors = [
				"Please provide a valid username and password (for this demo, any username and password will do)."
				] />

			<!---
				Raise an unauthorization exception. We cannot
				simply REThrow the error since we don't know how
				it was initially triggered.
			--->
			<cfthrow type="Unauthroized" />

		</cfcatch>

	</cftry>


	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->


	<!---
		Now that we have authenticated the user, let's get the user's
		session out of the application. Since we might have some race
		conditions here, let's lock this down to the user's username.

		The session allows us to maintain information about the user
		across requests to help create a better user experience.
	--->

	<cflock
		name="session-#api.username#"
		type="exclusive"
		timeout="5">

		<!---
			Check to see if the session object is already created in
			the application cache.

			NOTE: We'd probably want to do something like this in a
			database or other caching mechanism to limit the side
			that the application can get.
		--->
		<cfif !structKeyExists( application.sessions, api.username )>

			<!--- Create a new session of this user. --->
			<cfset application.sessions[ api.username ] = {
				requests = []
				} />

		</cfif>

		<!---
			At this point, we know that the session either already
			exists or was just created. In any case, get the existing
			session reference.
		--->
		<cfset api.session = application.sessions[ api.username ] />

	</cflock>


	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->


	<!---
		Now that we have the user's session, we need to check to see
		if they are staying in their rate limit. For now, their rate
		limit is gonna be 30 requests per minute. These requests will
		be stored in their requests array in date/time order.

		Since this is altering shared data, we are gonna want to lock
		the this down down a single user.
	--->
	<cflock
		name="session-#api.username#"
		type="exclusive"
		timeout="5">

		<!---
			First, we want to append this request date/time stamp to
			the end of the requests array.
		--->
		<cfset arrayAppend( api.session.requests, now() ) />

		<!---
			Next, we want to delete any requests from the user's
			session that were made greater than 60 seconds ago.
		--->

		<cfloop condition="arrayLen( api.session.requests )">

			<!---
				Check to see if the first item is greater than 60
				seconds ago.
			--->
			<cfif (dateDiff( "s", api.session.requests[ 1 ], now() ) gt 60)>

				<!--- Delete the first item. --->
				<cfset arrayDeleteAt( api.session.requests, 1 ) />

			<cfelse>

				<!---
					We have cleared out any requests that are beyond
					this rate-limitting window (and therefore will
					not be used for rate limitting calculations). As
					such, break out of this loop.
				--->
				<cfbreak />

			</cfif>

		</cfloop>


		<!--- Add a header for the current rate limit in effect. --->
		<cfset api.headers[ "X-RateLimit-Limit" ] = api.rateLimit />

		<!---
			Add a header for the number of requests the user has
			left in this time frame. We can calculate this by the
			rate limit minus the number of elements in the request
			array.
		--->
		<cfset api.headers[ "X-RateLimit-Remaining" ] = max(
			(api.rateLimit - arrayLen( api.session.requests )),
			0
			) />

		<!---
			Now, we know that all of the requests stored within this
			array were made within the last 60 seconds. Check to see
			if there are more than is allowed by the rate limit.
		--->
		<cfif (arrayLen( api.session.requests ) gt api.rateLimit)>

			<!---
				The user has exceeded the allowed rate limit. Set the
				error message.
			--->
			<cfset api.errors = [
				"You have exceeded your rate limit. Please try again in a little while."
				] />

			<!--- Raise a bad request error. --->
			<cfthrow type="BadRequest" />

		</cfif>

	</cflock>


	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->


	<!---
		At this point, we have a resource and a format. Now, we
		just need to make sure the resource is valid and has the
		necessary data in the request.
	--->

	<cfswitch expression="#listFirst( api.resource, '/' )#">
		<!--- Girls. --->
		<cfcase value="girls">
			<cfinclude template="api.girls.cfm" />
		</cfcase>

		<!--- Unknown resource. --->
		<cfdefaultcase>

			<!---
				The user has asked for a resource that doesn't exist.
				Don't worry about setting an error message at this
				point because this is such a generic error - we can
				put the message in the catch.
			--->
			<cfthrow type="NotFound" />

		</cfdefaultcase>

	</cfswitch>


	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->


	<!---
		If we have made it this far, then our API request has
		been succesfully processed (everything went off without
		raising an exception). Store the current request in
		the session.

		We can use the previous resource and POST information in
		order to prevent the user from submitting two duplicate
		requests in a row (if we want to).
	--->
	<cflock
		name="session-#api.username#"
		type="exclusive"
		timeout="5">

		<!--- Store the resource that the user was working with. --->
		<cfset api.session.prevResource = api.resource />

		<!---
			Store the previous FORM information. We only need to
			worry about the form data since POST is the only type
			of method that can mutate information.
		--->
		<cfset api.session.prevForm = duplicate( form ) />

		<!--- Store the previous response. --->
		<cfset api.session.prevData = api.data />

	</cflock>


	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->


	<!---
		Catch any exceptions raised during API processing. Since we
		were raising exceptions with explicit Types, we are going to
		want to response to those types on a case-by-case basis.
	--->


	<!---
		Catch any unauthorized errors in which the user did not
		provide the appropirate credentials.
	--->
	<cfcatch type="Unauthroized">

		<!---
			If the current page requires authentication (status code
			401), then set authorization header. This just let's the
			client know what kind of authorization is supported.

			NOTE: If using the browser to access API directly,
			cancel out of the first prompt box if is asking for NTLM
			authentication (based on your server configuration).
		--->
		<cfset api.headers[ "WWW-Authenticate" ] = "basic realm=""API Demo""" />

		<!--- Set the status code and response text. --->
		<cfset api.statusCode = "401" />
		<cfset api.statusText = "Unauthorized" />

		<!--- Overwrite the data key with the errors. --->
		<cfset api.data = api.errors />

	</cfcatch>


	<!---
		Catch any bad requests (these are malformed requests either
		due to resource definition or invalid request data or rate
		limit filtering).
	--->
	<cfcatch type="BadRequest">

		<!--- Set the status code and response text. --->
		<cfset api.statusCode = "400" />
		<cfset api.statusText = "Bad Request" />

		<!--- Overwrite the data key with the errors. --->
		<cfset api.data = api.errors />

	</cfcatch>


	<!---
		Catch any unacceptable requests (these are requests for
		response formats that are not currently supported by the
		API).
	--->
	<cfcatch type="NotAcceptable">

		<!--- Set the status code and response text. --->
		<cfset api.statusCode = "406" />
		<cfset api.statusText = "Not Acceptable" />

		<!--- Overwrite the data key with the errors. --->
		<cfset api.data = api.errors />

	</cfcatch>


	<!---
		Catch any not found resources. This could be due to the fact
		that the resource is simply invalid or that the requested
		resource has been removed / deleted.
	--->
	<cfcatch type="NotFound">
		<!--- Set the status code and response text. --->
		<cfset api.statusCode = "404" />
		<cfset api.statusText = "Not Found" />

		<!---
			Create the data key. This time, however, since we have a
			resource, let's include it in on the data.
		--->
		<cfset api.data = {
			resource = api.resource,
			errors = [ "The requested resource could not be found." ]
			} />

	</cfcatch>


	<!---
		Catch any method not allowed errors. This happens when a user
		tried to access a resource using a VERB (ex. GET) that was
		not supported on the given resource.
	--->
	<cfcatch type="MethodNotAllowed">

		<!--- Set the status code and response text. --->
		<cfset api.statusCode = "405" />
		<cfset api.statusText = "Method Not Allowed" />

		<!---
			Create the data key. This time, however, since we have
			a resource, let's include it in on the data.
		--->
		<cfset api.data = {
			resource = api.resource,
			errors = [ "The requested resource does not support this verb [#api.method#]." ]
			} />

	</cfcatch>


	<!---
		Note that we are not going to catch any unexpected errors.
		Really, we shouldn't get any random errors. If we do,
		we'll just let the server handle that so everything gets
		logged properly.
	--->
</cftry>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!---
	Now that we have processed the response, let's figure out
	how we need to present it to the user. All responses will
	be in text format - we just need to figure out how that is
	going to work.

	NOTE: Since we validated teh response format earlier in the
	workflow, we don't have to provide any default logic at this
	point - we know we support the given format.
--->
<cfswitch expression="#api.format#">

	<cfcase value="json">

		<!---
			For JSON, we are just going to use ColdFusion's native
			JSON serializer.
		--->
		<cfset api.content = serializeJSON(
			api.data
			) />

		<!--- Set the content's mime-type. --->
		<cfset api.mimeType = "application/json" />

	</cfcase>

	<cfcase value="xml">

		<!---
			For XML, we're just going to use ColdFusion's native WDDX
			serializer. This isn't really the type of XML we want...
			but this will keep the demo simple.
		--->
		<cfwddx
			output="api.content"
			action="cfml2wddx"
			input="#api.data#"
			/>

		<!--- Set the content's mime-type. --->
		<cfset api.mimeType = "text/xml" />

	</cfcase>

</cfswitch>


<!---
	At this point, we have converted the response data into a
	response content string, no matter what. Now, we just need
	to convert that to a binary value so we can stream it to
	the client.
--->
<cfset responseBinary = toBinary(
	toBase64(
		api.content
		)
	) />


<!---
	Loop over any additional headers that we need to return.
	These might be rate-limit headers, authorization headers, etc..
--->
<cfloop
	item="headerName"
	collection="#api.headers#">

	<!--- Pass back the given header. --->
	<cfheader
		name="#headerName#"
		value="#api.headers[ headerName ]#"
		/>

</cfloop>

<!--- Report the status code and text. --->
<cfheader
	statuscode="#api.statusCode#"
	statustext="#api.statusText#"
	/>

<!---
	Tell the client how much data to expect so that it knows when
	to close the connection with the server.
--->
<cfheader
	name="content-length"
	value="#arrayLen( responseBinary )#"
	/>


<!--- Stream the content back to the client. --->
<cfcontent
	type="#api.mimeType#"
	variable="#responseBinary#"
	/>
