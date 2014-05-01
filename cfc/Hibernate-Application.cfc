<cfcomponent hint="CFHibernate Demo" output="false">

<cfscript>
    this.name = "ORM Demo";
    //turn on orm 
    this.ormenabled = true;    
    this.datasource = "ORMDemo";
    
    //add some additional settings
    this.ormsettings = { cfclocation = "com", dialect="MySQLwithInnoDB" 
                       };
    
    //if this is a development server...
    this.developmentServer = true;
    
    if(this.developmentServer)
    {
      this.ormsettings.dbcreate = "dropcreate";        this.ormsettings.logSQL = true;
    }
</cfscript>

<cffunction name="onRequestStart" access="public" hint="Request start processing" returnType="boolean" output="false">
    <cfargument name="targetPage" type="string" hint="The page requested" required="true"/>    
    <cfif StructKeyExists(URL, "reload")> 
        <cfset ApplicationStop() />
        
        <cflocation url="#arguments.targetPage#">
        <cfreturn false />
    </cfif>
    
    <cfreturn true>
</cffunction>

</cfcomponent>