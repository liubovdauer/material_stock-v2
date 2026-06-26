# Material Stock v2 — SAP BTP End-to-End Integration

Dieses Projekt implementiert eine vollständige End-to-End Integration auf der **SAP BTP ABAP Environment**: Die **SAP S/4HANA Cloud Material Stock API** wird per HTTP aus ABAP heraus aufgerufen, die Daten werden verarbeitet und als **OData V4 Service** exponiert — konsumierbar über eine **SAP Fiori Elements App** oder einen externen HTTP-Client (Postman, curl, Bruno).

---

## Technologien

**SAP**
- ABAP Cloud (Clean-Core-Ansatz)
- RESTful Application Programming Model (RAP) — Custom Entity + Query Provider
- CDS Custom Entity
- SAP Fiori Elements (auto-generierter List Report)
- OData V4
- SAP BTP ABAP Environment (Free Tier)

**Integration**
- SAP S/4HANA Cloud API (OData V2 Sandbox)
- HTTP (ausgehend aus ABAP)
- JSON-Deserialisierung in ABAP

**Entwicklung & Tools**
- Eclipse ADT (ABAP Development Tools)
- Git / abapGit
- SAP API Business Hub (`api.sap.com`)
- HTTP-Clients: Postman · curl · Bruno

---

## Funktionsumfang

- Ausgehender HTTP-Aufruf aus ABAP an die SAP S/4HANA Cloud Material Stock API Sandbox
- Deserialisierung der JSON-Antwort in eine ABAP-interne Tabelle
- Bereitstellung der Daten über einen RAP Query Provider mit Paging-Unterstützung
- CDS Custom Entity als Datenschema mit Referenz auf den Query Handler
- OData V4 Service via Service Definition und Service Binding
- Anzeige der Materiallagerbestände in einer SAP Fiori Elements-Anwendung
- Alternativzugriff über externen HTTP-Client (Postman, curl, Bruno)
- Umsetzung nach dem **Clean-Core-Ansatz**

---

## Architektur

<!-- ![Architekturdiagramm](docs/architecture.svg) -->

```
┌──────────────────────────┐     ┌──────────────────────────┐
│    SAP Fiori Elements    │     │  Externer HTTP-Client    │
│  List Report (Preview)   │     │  Postman · curl · Bruno  │
└────────────┬─────────────┘     └────────────┬─────────────┘
             │                                │
             └──────────────┬─────────────────┘
                            │ OData V4
             ┌──────────────▼─────────────────┐
             │     ZSB_MATERIAL_STOCK_NEU     │
             │  OData V4 Service Binding      │
             │  ZUI_MATERIAL_STOCK (Def.)     │
             └──────────────┬─────────────────┘
                            │
             ┌──────────────▼─────────────────┐
             │       ZCE_MATERIAL_STOCK       │
             │       CDS Custom Entity        │
             └──────────────┬─────────────────┘
                            │ referenziert
             ┌──────────────▼─────────────────┐
             │    ZCL_MATERIAL_STOCK_QUERY    │
             │    IF_RAP_QUERY_PROVIDER       │
             │    Paging + Konvertierung      │
             └──────────────┬─────────────────┘
                            │ HTTP-Aufruf
             ┌──────────────▼─────────────────┐
             │   ZCL_MATERIAL_STOCK_API_NEU   │
             │   API Client · JSON Deseri.    │
             └──────────────┬─────────────────┘
                            │ GET /A_MaterialStock
                            │ APIKey Header
             ┌──────────────▼─────────────────┐
             │  SAP S/4HANA Cloud API Sandbox │
             │  sandbox.api.sap.com · OData V2│
             └────────────────────────────────┘
```

---

## Projektablauf

1. Der Client (Fiori oder HTTP-Client) sendet eine Anfrage an den **OData V4 Service** `ZSB_MATERIAL_STOCK_NEU`.
2. Der Service liest die **CDS Custom Entity** `ZCE_MATERIAL_STOCK`, die das Datenschema definiert und den Query Handler referenziert.
3. Der **Query Handler** `ZCL_MATERIAL_STOCK_QUERY` (implementiert `IF_RAP_QUERY_PROVIDER`) wird automatisch aufgerufen und delegiert an den API Client.
4. Der **API Client** `ZCL_MATERIAL_STOCK_API_NEU` sendet einen ausgehenden HTTP-Request an die SAP Sandbox API: `GET /A_MaterialStock?$top=5&$format=json` mit einem `APIKey`-Header.
5. Die JSON-Antwort wird in eine ABAP-Tabelle deserialisiert.
6. Der Query Handler konvertiert die Daten in den Custom Entity Typ, wendet Paging an und gibt die Ergebnisse an den Client zurück.

---

## Artefakte

| Artefakt | Typ | Beschreibung |
|---|---|---|
| `ZCE_MATERIAL_STOCK` | CDS Custom Entity | Datenschema · referenziert Query Handler |
| `ZCL_MATERIAL_STOCK_QUERY` | ABAP Class | Query Provider · `IF_RAP_QUERY_PROVIDER` · Paging |
| `ZCL_MATERIAL_STOCK_API_NEU` | ABAP Class | HTTP-Client · JSON-Deserialisierung |
| `ZUI_MATERIAL_STOCK` | Service Definition | Exponiert `ZCE_MATERIAL_STOCK` |
| `ZSB_MATERIAL_STOCK_NEU` | Service Binding | OData V4 Binding (UI) |

---

## Externe API

**Endpoint:**
```
GET https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_MATERIAL_STOCK_SRV/A_MaterialStock?$top=5&$format=json
```

**Authentifizierung:** `APIKey` Header — kostenlos erhältlich auf [api.sap.com](https://api.sap.com) nach dem Login über „Show API Key".

---

## Voraussetzungen

- SAP BTP Trial Account mit aktiviertem **ABAP Environment** (Free Tier)
- Eclipse mit **ABAP Development Tools (ADT)** Plugin
- abapGit im ABAP-System installiert
- API-Key von [api.sap.com](https://api.sap.com) (kostenfrei)
- Optional: Postman, curl oder Bruno für den HTTP-Client-Zugriff

---

## Installation

### 1. Repository mit abapGit klonen

1. abapGit öffnen
2. „New Online" → URL eingeben:
   ```
   https://github.com/liubovdauer/material_stock-v2
   ```
3. Eigenes Paket und Transportauftrag auswählen
4. Objekte importieren und aktivieren

### 2. API-Key konfigurieren

1. Auf [api.sap.com](https://api.sap.com) einloggen
2. API „SAP S/4HANA Cloud – Material Stock" aufrufen
3. „Show API Key" → Key kopieren
4. Im API Client `ZCL_MATERIAL_STOCK_API_NEU` den Key als HTTP-Header `APIKey` eintragen

### 3. Service aktivieren

Service Binding `ZSB_MATERIAL_STOCK_NEU` aktivieren — der Fiori Elements Preview ist dann direkt in ADT verfügbar.

### 4. End-to-End testen

**Option A — Fiori Elements Preview:**
- Service Binding öffnen → „Preview" → List Report mit Materiallagerbeständen

**Option B — Externer HTTP-Client:**
```bash
curl -H "Authorization: Bearer <token>" \
  "https://<dein-btp-host>/sap/opu/odata4/.../ZSB_MATERIAL_STOCK_NEU/..."
```

---

## Lernziele

Dieses Projekt demonstriert praktische Kenntnisse in folgenden Bereichen:

- Ausgehende **HTTP-Kommunikation aus ABAP** (kein Gateway, kein RFC)
- **RAP Custom Entity** mit eigenem Query Provider statt managed BO
- Implementierung von **`IF_RAP_QUERY_PROVIDER`** inkl. Paging
- **JSON-Deserialisierung** in ABAP mit `/UI2/CL_JSON`
- **OData V4 Service** Bereitstellung ohne Datenbanktabelle
- Nutzung der **SAP API Business Hub Sandbox**
- End-to-End Verifikation über Fiori und externen HTTP-Client
- Entwicklung nach dem **Clean-Core-Ansatz** auf SAP BTP

---

## Mögliche Erweiterungen

- **Filterunterstützung:** Übergabe von OData `$filter`-Parametern an den API-Aufruf
- **Fehlerbehandlung:** Strukturierte ABAP-Exceptions im API Client und im Query Handler
- **ABAP Unit Tests:** Automatisierte Tests für API Client und Query Handler mit Mock-HTTP-Responses
- **Caching:** Zwischenspeicherung der API-Antwort in einer ABAP-Tabelle zur Reduzierung externer Aufrufe
- **Kommunikationsarrangement:** Migration von hardcodiertem APIKey zu einem SAP BTP Communication Arrangement
- **Weitere Felder:** Erweiterung der Custom Entity um zusätzliche Felder aus der API-Antwort
- **Object Page:** Detailansicht für einen einzelnen Materiallagerbestand in Fiori Elements

---

## Autorin

**Liubov Dauer** — SAP Entwicklerin  
[GitHub Profile](https://github.com/liubovdauer)

---

*Sprache: ABAP Cloud · Plattform: SAP BTP ABAP Environment · API: SAP S/4HANA Cloud Material Stock Sandbox*
