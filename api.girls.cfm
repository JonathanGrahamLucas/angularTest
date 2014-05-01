<!---
    Now that we are in the Girls resource, let's figure out what
    specific resource the user is looking for. Here are the resources
    that this module currently supports:
 
    GET /girls/{name}/kiss
    POST /girls/{name}/french-kiss
--->

<cfif reFindNoCase( "^/girls/[\w-]+/kiss$", api.resource )>
    <!--- Include action. --->
    <cfinclude template="api.girls.kiss.cfm" />
 
<cfelseif reFindNoCase( "^/girls/[\w-]+/french-kiss$", api.resource )>
    <!--- Include action. --->
    <cfinclude template="api.girls.frenchkiss.cfm" />
 
<cfelse>
 
    <!---
        The requested resource was not supported in this module.
        Throw an exception. Don't worry about adding any additional
        error information - this is such a generic error, it can be
        handled in a central manner.
    --->
    <cfoutput>Not Found</cfoutput>
    <cfabort>
    <cfthrow type="NotFound" />
 
</cfif>