Class api.memoria.testing Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "UTF-8";

XData UrlMap
{
<Routes>
            <Route Url="/test/:id" Method="GET" Call="test" Cors="false" />
</Routes>
}

/// API Get for api/character 
ClassMethod test(id) As %Status
{
            set mm = ##class(api.memoria.client).%New()
            set reply = mm.MGet("https://rickandmortyapi.com/api/character/"_id,"character-"_id,10)
            write reply
            quit $$$OK
}

}
