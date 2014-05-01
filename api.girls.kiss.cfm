<!---
    This action gets a kiss from the girl defined in the given
    resource path.
 
    GET: /girls/{name}/kiss
--->
 
<!---
    Make sure that user has made the supported method request.
    This resource only responds to GET requests.
--->
<cfif (api.method neq "get")>
 
    <!--- Throw a method not allowed error. --->
    <cfthrow type="MethodNotAllowed" />
 
</cfif>
 
 
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
    <cfset api.data = "Mmmm, nice kiss from #girl#!" />
 
<cfelse>

    <!---
        The requested girl is not currently supported; throw a not
        found error. Don't worry about adding any additional error
        information - this is such a generic error, it can be handled
        in a central manner.
    --->
    <cfthrow type="NotFound" />
 
</cfif>