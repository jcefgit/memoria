Class api.memoria.panel Extends %CSP.Page
{

/// Pages
ClassMethod OnPage() As %Status
{
    set sql="select storeid, ttl, reply from api_memoria.store order by storeid"
    set rs = ##class(%SQL.Statement).%New()
    set st = rs.%Prepare(.sql)
    set res = rs.%Execute()
    if $Data(%request.Data("storeid",1))
    { set storeid= %request.Data("storeid",1) }
    else {
        set storeid = ""
    }
        &html<<!DOCTYPE html5>
            <html>
                <head>
                <style>
                    body {font-family: Verdana, Geneva, Tahoma, sans-serif; }
                    .row { display: flex }
                    .left { width: 200px; background-color: lightcyan; height:100%; padding: 5px;}
                    .right { width: 80%; background-color: beige;  }
                    .reply { margin: 10px; display: block; background-color: azure; word-break:break-all;}
                </style>
                #(..HyperEventHead())#
                <script type="text/javascript">
                    function borraCache(id)
                    { 
                     #(..HyperEventCall("api.memoria.panel.borraCacheStore","id",1))#
                     window.location.replace('#(%request.URL)#')
                    }
                </script>
                </head>
                <body>
                    <h3>Memoria panel</h3>
                    <div class="row">
                        <div class="left">
                            <b>StorageId</b>
                            <hr>
                            <table>>
                                while res.%Next() { w "<tr><td><a href='api.memoria.panel.cls?storeid="_res.storeid_"'>"_res.storeid_"</td></tr>",!  }
                &html< </table>
                        </div>
                        <div class="right">>
                        if $L(storeid)>0
                         { w " StoreId : <b>" _  storeid _"</b>" }
                &html<  <div class="reply" id="reply"> >
                                w $P(..traeReply(storeid),"|||",2)
                &html<</div>> 
                    set datas = "borraCache('"_ storeid _"')"
                    if $L(storeid) { w "<button onclick="""_ datas _""">Borrar datos</button>" }
                &html<  </div>
                    </div>
                </body>
            </html> >
        quit $$$OK
}

ClassMethod traeReply(id) As %String
{
    try {
        set salida=##class(api.memoria.store).%OpenId(id)
        set retorno = salida.ttl_"|||"_salida.reply.Read()
    }catch ex {
        set retorno = $SYSTEM.Status.GetOneErrorText(ex)
    }
    quit retorno
}

ClassMethod borraCacheStore(id) As %Status
{
    set del = ##class(api.memoria.store).%DeleteId(id)
    if del=1 { return id_" borrado!" } else { return id_" no se pudo borrar!" }
    quit del
}

}
