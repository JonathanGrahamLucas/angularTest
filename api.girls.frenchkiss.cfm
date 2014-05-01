<!---
	This action gets a kiss from the girl defined in the given
	resource path.

	GET: /girls/{name}/french-kiss
--->

<!---
	Make sure that user has made the supported method request.
	This resource only responds to POST requests.
--->
<cfif (api.method neq "post")>

	<!--- Throw a method not allowed error. --->
	<cfthrow type="MethodNotAllowed" />

</cfif>


<!---
	Now that we have confirmed that this resource is a POST resource,
	let's configure out FORM post variables.
--->
<cfparam name="form.approach" type="string" default="" />


<!--- Validate the form data. --->
<cfif (form.approach neq "gentle")>

	<cfset arrayAppend(
		api.errors,
		"Come on man, be gentle with it."
		) />

</cfif>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!---
	Check to see if there were any problems with the form data.
	If so, then there is something wrong with the request.
--->
<cfif arrayLen( api.errors )>

	<!---
		The user posted a bad request. Raise an malformed request
		exception. The errors define above will be used when handling
		this request error.
	--->
	<cfthrow type="BadRequest" />

</cfif>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!---
	Now that we know we are working with valid data, let's make sure
	the user is not accidentally double-posting this information.
	Let's compare this post to the previous post.
--->
<cflock
	name="session-#api.username#"
	type="exclusive"
	timeout="5">

	<!---
		Check to see if this is the same resource AND the same
		approach as the previous successful post.

		NOTE: We don't have to check for FORM keys since the previous
		resource will indicate which form variables will be there.
	--->
	<cfif (
		structKeyExists( api.session, "prevResource" ) &&
		(api.session.prevResource eq api.resource) &&
		(api.session.prevForm.approach eq form.approach)
		)>

		<!---
			Since this is a duplicate of the previous POST, let's
			just return the previous data result.
		--->
		<cfset api.data = api.session.prevData />

		<!---
			Add a custom response header to indicate that the
			request as simply a re-response of the previous post.
			This is not required from a functional standpoint, but
			it's nice to give the client as much information as
			possible.

			NOTE: Custom headers should begin with "X-" to indicate
			that they are custom (not part of any HTTP specification).
		--->
		<cfset api.headers[ "X-Duplicate-Post" ] = api.resource />

		<!---
			Exit out of this processing branch (allowing the rest of
			the API request to be executed with the previous data).
		--->
		<cfexit method="exitTemplate" />

	</cfif>

</cflock>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Get the name of the targeted girl from the resource path. --->
<cfset girl = listGetAt( api.resource, 2, "/" ) />

<!---
	Check to see if the girl's name is valid. Imagine that we would
	be hitting a database at this point; but, for our purposes, we
	are only going to support a few girl names.
--->
<cfif listFindNoCase( "Sarah,Tricia,Joanna", girl )>

	<!---
		For our simple demo, we are just going to return a simple
		string as our response data.
	--->
	<cfset api.data = "Mmmm, nice french-kiss from #girl#!" />

<cfelse>

	<!---
		The requeste girl is not currently supported; throw a not
		found error. Don't worry about adding any additional error
		information - this is such a generic error, it can be handled
		in a central manner.
	--->
	<cfthrow type="NotFound" />

</cfif>