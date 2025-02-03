Class api.memoria.store Extends %Persistent
{

Property storeid As %String;

Property reply As %Stream.GlobalCharacter;

Property ttl As %Integer [ InitialExpression = 0, Required ];

Property createdate As %BigInt [ InitialExpression = {$ZDT($NOW(),-2)}, Required ];

Index pk On storeid [ IdKey, PrimaryKey, Unique ];

Storage Default
{
<Data name="storeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>reply</Value>
</Value>
<Value name="3">
<Value>ttl</Value>
</Value>
<Value name="4">
<Value>createdate</Value>
</Value>
</Data>
<DataLocation>^api.memoria.storeD</DataLocation>
<DefaultData>storeDefaultData</DefaultData>
<IdLocation>^api.memoria.storeD</IdLocation>
<IndexLocation>^api.memoria.storeI</IndexLocation>
<StreamLocation>^api.memoria.storeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
