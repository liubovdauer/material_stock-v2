# material_stock-v2
Die Aufgabe bestand darin, eine End-to-End Integration auf SAP BTP zu implementieren, 
die die SAP S/4HANA Cloud Material Stock API per HTTP aufruft, 
die Daten in einem ABAP-Service verarbeitet und als OData V4 Service exponiert, 
der entweder über Fiori Elements oder einen externen HTTP-Client konsumiert werden kann.

Ich habe: einen API Client (ZCL_MATERIAL_STOCK_API_NEU) implementiert, 
der per HTTP die SAP Sandbox API aufruft und die JSON-Antwort in eine ABAP-Tabelle deserialisiert. 
Einen Query Handler (ZCL_MATERIAL_STOCK_QUERY) der das Interface IF_RAP_QUERY_PROVIDER implementiert und 
beim Fiori-Aufruf automatisch den API Client aufruft, 
die Ergebnisse in den Custom Entity Typ konvertiert und mit Paging an Fiori zurückgibt. 

Eine CDS Custom Entity (ZCE_MATERIAL_STOCK) die das Datenschema definiert und den Query Handler referenziert. 
Eine Service Definition (ZUI_MATERIAL_STOCK) die die Custom Entity exponiert und 
ein Service Binding (ZSB_MATERIAL_STOCK_NEU) das den OData V4 Service für Fiori bereitstellt.
The Task
Create an SAP BTP Trial account and activate the ABAP Environment (free tier).
Using ABAP Development Tools (ADT) in Eclipse, create your own package and implement a custom ABAP class that calls the SAP S/4HANA Cloud Material Stock API sandbox and reads material stock data:
GET https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_MATERIAL_STOCK_SRV/A_MaterialStock?$top=5&$format=json
The API requires an APIKey header which you can obtain for free at api.sap.com after logging in (button "Show API Key").
Expose the result as an OData service via a service definition and service binding.
Verify end-to-end that the data can be consumed – either
via the auto-generated Fiori Elements preview, or
via a plain HTTP call from outside the system (Postman / curl / Bruno).
