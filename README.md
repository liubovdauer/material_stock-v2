# Material Stock v2 — Vollständiges RAP Business Object auf SAP BTP

Dieses Projekt implementiert eine vollständige End-to-End Integration auf der **SAP BTP ABAP Environment** mit einem **managed RAP Business Object mit Draft-Unterstützung**: Die **SAP S/4HANA Cloud Material Stock API** wird per HTTP abgerufen, die Daten werden in einer **SAP HANA Datenbanktabelle** gespeichert und über zwei **OData V4 Services** exponiert — für Fiori Elements und für externe HTTP-Clients.

> Dies ist die erweiterte Version von `material_stock` (Custom Entity Ansatz). Hier wird ein vollständiges RAP BO mit DB-Tabellen, Behavior Implementation, Draft-Handling, eigener Exception-Klasse und ABAP Unit Tests verwendet.

---

## Technologien

**SAP**
- ABAP Cloud (Clean-Core-Ansatz)
- RESTful Application Programming Model (RAP) — Managed BO mit Draft
- CDS View Entity + Projection View + Metadata Extension
- Behavior Definition + Behavior Implementation
- SAP Fiori Elements (List Report + Object Page)
- OData V4 (zwei Service Bindings: UI + API)
- SAP HANA (Aktiv-Tabelle + Draft-Tabelle)
- SAP BTP ABAP Environment (Free Tier)
- ABAP Unit Tests

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
- Deserialisierung der JSON-Antwort und Persistierung in der HANA-Tabelle `ZMAT_STOCK`
- Vollständiges RAP Business Object mit Managed Draft (`ZMAT_STOCK_D`)
- Behavior Implementation mit eigenem Load-Mechanismus (`ZLOAD_MATERIAL_STOCK`)
- Strukturierte Fehlerbehandlung über eigene Exception-Klasse (`ZCX_MATERIAL_STOCK_ERROR`)
- Zwei OData V4 Services: einer für Fiori Elements, einer für externe API-Zugriffe
- Anzeige der Materiallagerbestände in einer SAP Fiori Elements-Anwendung (List Report + Object Page)
- ABAP Unit Tests zur Validierung der Geschäftslogik (`ZCHECK_STOCK_DATA`)
- Umsetzung nach dem **Clean-Core-Ansatz**

---

## Architektur

```
┌─────────────────────┐  ┌──────────────────────┐  
│   SAP Fiori         │  │ Externer HTTP-Client │  
│   Elements          │  │ Postman·curl·Bruno   │  
│   List Report +     │  │                      │  
│   Object Page       │  │                      │  
└──────────┬──────────┘  └──────────┬───────────┘  
           │                        │                       
┌──────────▼──────────┐  ┌──────────▼────────────────────────────────┐
│ ZSB_MATERIAL_STOCK  │  │         ZSB_MATERIAL_STOCK_API            │
│ OData V4 · UI       │  │         OData V4 · API                    │
└──────────┬──────────┘  └──────────────────────┬────────────────────┘
           └──────────────────────┬─────────────┘
                                  │
                    ┌─────────────▼──────────────┐
                    │     ZSD_MATERIAL_STOCK     │
                    │     Service Definition     │
                    └──────┬─────────────────────┘
                           │
            ┌──────────────▼───────────────────────────┐
            │ ZC_MATERIAL_STOCK   ZI_MATERIAL_STOCK    │
            │ Projection View  +  Root View Entity     │
            │ Metadata Ext.    +  Behavior Definition  │
            │                  +  ZBP_I (Behavior Impl)│
            └──────────────┬───────────────────────────┘
                           │
          ┌────────────────┼──────────────────────────┐
          │                │                          │
┌─────────▼──────┐ ┌───────▼──────────────┐ ┌────────▼──────────────┐
│ ZLOAD_         │ │ ZCL_MATERIAL_        │ │ ZCX_MATERIAL_         │
│ MATERIAL_STOCK │ │ STOCK_API            │ │ STOCK_ERROR           │
│ Daten → DB     │ │ HTTP · JSON Deseri.  │ │ Exception-Klasse      │
└─────────┬──────┘ └───────┬──────────────┘ └───────────────────────┘
          │                │ GET /A_MaterialStock
          │         ┌──────▼───────────────────────────────────┐
          │         │  SAP S/4HANA Cloud API Sandbox           │
          │         │  sandbox.api.sap.com · OData V2 · APIKey │
          │         └──────────────────────────────────────────┘
          │
┌─────────▼─────────────────────┐
│  ZMAT_STOCK   ZMAT_STOCK_D    │
│  Aktiv-Tab.   Draft-Tabelle   │
│  SAP HANA     SAP HANA        │
└───────────────────────────────┘
```

---

## Projektablauf

1. Der **Load-Trigger** (manuell oder geplant) startet `ZLOAD_MATERIAL_STOCK`.
2. `ZLOAD_MATERIAL_STOCK` ruft den **API Client** `ZCL_MATERIAL_STOCK_API` auf.
3. Der API Client sendet einen HTTP-Request an die SAP Sandbox: `GET /A_MaterialStock?$top=5&$format=json` mit `APIKey`-Header.
4. Die JSON-Antwort wird deserialisiert und in der HANA-Tabelle **`ZMAT_STOCK`** gespeichert. Fehler werden über `ZCX_MATERIAL_STOCK_ERROR` behandelt.
5. Das **RAP Business Object** (`ZI_MATERIAL_STOCK` + `ZBP_I_MATERIAL_STOCK`) liest die Daten aus der DB und stellt sie über den **OData V4 Service** bereit.
6. Die **Projection View** `ZC_MATERIAL_STOCK` mit Metadata Extension steuert die Fiori-Darstellung.
7. Der Client (Fiori Elements oder HTTP-Client) konsumiert die Daten über `ZSB_MATERIAL_STOCK` (UI) oder `ZSB_MATERIAL_STOCK_API` (API).

---

## Artefakte

### Package: `ZMAT_STOCK_PKG_ID_NEU`

| Artefakt | Typ | Beschreibung |
|---|---|---|
| `ZMAT_STOCK` | Database Table | Aktiv-Tabelle · Materiallagerbestandsdaten |
| `ZMAT_STOCK_D` | Database Table | Draft-Tabelle · RAP Managed Draft |
| `ZI_MATERIAL_STOCK` | CDS View Entity | Root Business Object (liest `ZMAT_STOCK`) |
| `ZI_MATERIAL_STOCK` | Behavior Definition | RAP BDEF · Managed mit Draft |
| `ZBP_I_MATERIAL_STOCK` | Behavior Implementation | ABAP-Klasse · Behavior Logic |
| `ZC_MATERIAL_STOCK` | CDS Projection View | Consumption View für Fiori |
| `ZC_MATERIAL_STOCK` | Metadata Extension | Fiori-Annotationen (UI-Labels, Filter) |
| `ZSD_MATERIAL_STOCK` | Service Definition | Exponiert `ZC_MATERIAL_STOCK` |
| `ZSB_MATERIAL_STOCK` | Service Binding | OData V4 · UI (Fiori Elements) |
| `ZSB_MATERIAL_STOCK_API` | Service Binding | OData V4 · API (externer Zugriff) |
| `ZLOAD_MATERIAL_STOCK` | ABAP Class | Lädt Daten von API in `ZMAT_STOCK` |
| `ZCL_MATERIAL_STOCK_API` | ABAP Class | HTTP-Client · JSON-Deserialisierung |
| `ZCX_MATERIAL_STOCK_ERROR` | Exception Class | Strukturierte Fehlerbehandlung |
| `ZCHECK_STOCK_DATA` | ABAP Unit Test | Automatisierte Tests der Geschäftslogik |

---

## Vergleich: Custom Entity vs. managed RAP BO

| Merkmal | `material_stock` (Custom Entity) | `material_stock-v2` (managed RAP BO) |
|---|---|---|
| Datenpersistenz | Keine — live API-Aufruf | HANA-Tabelle `ZMAT_STOCK` |
| Draft-Support | Nein | Ja (`ZMAT_STOCK_D`) |
| Behavior | Query Provider | Managed + Behavior Implementation |
| Fehlerbehandlung | Minimal | Eigene Exception-Klasse |
| Unit Tests | Nein | Ja (`ZCHECK_STOCK_DATA`) |
| Service Bindings | 1 (UI) | 2 (UI + API) |
| Komplexität | Einfacher | Vollständig / produktionsnäher |

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
- Optional: Postman, curl oder Bruno für externen API-Zugriff

---

## Installation

### 1. Repository mit abapGit klonen

1. abapGit öffnen
2. „New Online" → URL eingeben:
   ```
   https://github.com/liubovdauer/material_stock
   ```
3. Paket `ZMAT_STOCK_PKG_ID_NEU` und Transportauftrag auswählen
4. Objekte importieren und aktivieren

### 2. API-Key konfigurieren

1. Auf [api.sap.com](https://api.sap.com) einloggen
2. API „SAP S/4HANA Cloud – Material Stock" aufrufen → „Show API Key"
3. Key in der Klasse `ZCL_MATERIAL_STOCK_API` als HTTP-Header `APIKey` eintragen

### 3. Daten laden

Klasse `ZLOAD_MATERIAL_STOCK` ausführen (F9 in ADT) — die Daten werden von der API abgerufen und in `ZMAT_STOCK` gespeichert.

### 4. Services aktivieren

Beide Service Bindings aktivieren:
- `ZSB_MATERIAL_STOCK` → Fiori Elements Preview direkt in ADT
- `ZSB_MATERIAL_STOCK_API` → OData-Endpunkt für externen Zugriff

---

## Lernziele

Dieses Projekt demonstriert praktische Kenntnisse in folgenden Bereichen:

- **Managed RAP Business Object** mit vollständiger Schichtenarchitektur
- **CDS View Entity** als Root BO auf einer HANA-Datenbanktabelle
- **RAP Managed Draft** mit separater Draft-Tabelle
- **Behavior Definition und Behavior Implementation** in ABAP
- **Projection View mit Metadata Extension** für Fiori Elements
- Zwei **OData V4 Service Bindings** (UI + API) für verschiedene Konsumenten
- Ausgehende **HTTP-Kommunikation aus ABAP** mit JSON-Deserialisierung
- Strukturierte **Fehlerbehandlung** mit eigener Exception-Klasse
- **ABAP Unit Tests** zur automatisierten Validierung
- End-to-End Entwicklung nach dem **Clean-Core-Ansatz** auf SAP BTP

---

## Mögliche Erweiterungen

- **Scheduled Job:** Automatischer Daten-Load über `ZLOAD_MATERIAL_STOCK` via Application Job
- **Filterunterstützung:** Übergabe von OData `$filter`-Parametern an den API-Aufruf
- **Weitere Felder:** Erweiterung der CDS Views um zusätzliche Felder aus der API-Antwort via RAP Extensions
- **Value Help:** Value Help-Annotationen für Filterfelder in der Projection View
- **Erweiterung Unit Tests:** Mehr Testfälle inkl. Mock-HTTP-Responses für den API Client
- **Monitoring:** Logging der Daten-Load-Prozesse in einer separaten Protokolltabelle

---

## Autorin

**Liubov Dauer** — SAP Entwicklerin  
[GitHub Profile](https://github.com/liubovdauer)

---

*Sprache: ABAP Cloud · Plattform: SAP BTP ABAP Environment · Muster: Managed RAP BO mit Draft · API: SAP S/4HANA Cloud Material Stock Sandbox*
