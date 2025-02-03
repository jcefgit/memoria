Class api.memoria.client Extends %RegisteredObject
{

/// URL of the API to read/capture
Property url As %String(MAXLEN = 300) [ Required ];

Property reply As %Stream.GlobalCharacter [ Private ];

/// SSL configuration on IRIS by default pm.community.intersystems.com (dummy)
Property ssl As %String [ InitialExpression = "pm.community.intersystems.com" ];

Property https As %String [ Private ];

Property server As %String [ Private ];

Property toGet As %String(MAXLEN = 500) [ Private ];

Property net As %Net.HttpRequest;

/// contentType of data, by dafault application/json
Property contentType As %String(MAXLEN = 100) [ InitialExpression = "application/json" ];

/// MGet execute the API Call and validate if the key exists on storage, if not, just make the call
/// url to call (https://myapi.com/my/endpoint)
/// key into database (endpoint) is used to identify the url as unique
/// ttl time-to-live before make the call again in seconds
Method MGet(url = "", key, ttl = 0) As %String
{
    set preParse = ..parseUrl(url)

    if preParse="OK"{

        set store = ..Storage(key)

        if store {
            quit store.Read()
        } else {
            set replyExit = ..getData(key, ttl)
        }
    }
    quit replyExit
}

/// Obtain information from the API URL (http or https, server name and others)
Method parseUrl(url) As %String
{
        set tipo=$P(url,"://",1), ..server=$P($P(url,"://",2),"/",1), restoUrl=$P(url,"://",2), ..toGet="/"_$P(restoUrl,"/",2,*) 
        if tipo="https" { set ..https="Y" } else { set ..https="N"}
        quit "OK"
}

/// Storage validate if the result exist in the database, clean if the data is past or create a new data
/// key is the key value in the database
Method Storage(key) As %String
{
    set timeNow = $ZDT($NOW(),-2)
    try {
        set mm = ##class(mnemea.store).%OpenId(key)
        if $ISOBJECT(mm) {
            if mm.ttl = 0  { return mm.reply } 
            else 
            { 
                if timeNow <= (mm.createdate+mm.ttl){  return mm.reply } 
                else {  k mm set tsc= ##class(mnemea.store).%DeleteId(key)  return ""  }
            } 
        } else { return ""   }
    } catch ex {
        w $SYSTEM.Status.GetErrorText(ex)
    }
    quit ""
}

/// getData execute the call to the external API
Method getData(key, ttl) As %String
{
    try {
        set ..net = ##class(%Net.HttpRequest).%New()
        set ..net.Server = ..server
        set ..net.ContentType = ..contentType
        
        if ..https="Y" {
            set ..net.SSLConfiguration = ..ssl
            set ..net.Https=1
        }

        do ..net.Get(..toGet)
        set reply = ..net.HttpResponse.Data
        set replyExit= reply.Read()
        if reply'="" { 
            do ..toStore(key, ttl, replyExit) 
        }
        return replyExit
    } catch ex {
        return $SYSTEM.Status.GetErrorText(ex)
    }
     quit "error"
}

/// toStore create a new data into store table
Method toStore(key As %String, ttl As %Integer, reply) As %Status
{
    try {
        set mm = ##class(mnemea.store).%New()
        set mm.storeid = key
        set mm.ttl = ttl
        do mm.reply.Write(reply)
        set tsc = mm.%Save()
        if $$$ISERR(tsc) { w $SYSTEM.Status.GetErrorText(tsc) }
    } catch ex {
        w $SYSTEM.Status.GetErrorText(ex)
    }
    quit tsc
}

/// addHeader for additional headers in request
Method addHeader(h, v) As %Status
{
    do ..net.SetHeader(h,v)
    quit $$$OK
}

Method %OnNew() As %Status
{
    set ..net = ##class(%Net.HttpRequest).%New()
    quit $$$OK
}

}
