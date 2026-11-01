# Supplier Invoices & Credit Memos – SAP RAP App

A transactional SAP Fiori elements app built with the **ABAP RESTful Application Programming Model (RAP)** on **SAP BTP ABAP Environment**.
It combines three classic SAP Accounts Payable transactions into one app:

| Classic transaction | What it does | In this app |
| --- | --- | --- |
| **FB60** | Post a supplier invoice | Create a document with type `KR` |
| **FB65** | Post a supplier credit memo | Create a document with type `KG` |
| **FBL1N** | Display supplier line items | List report with filters and clearing status |

The idea comes from three years of hands-on work in Accounts Payable with SAP – the app models rules an AP accountant checks every day: correct sign for credit memos, an existing supplier and VAT code, payment terms and overdue items.

> **Environment:** SAP Learning practice system (SAP BTP ABAP Environment, course S4D437). The system has no S/4HANA business modules, so suppliers, VAT codes, payment terms and document types are modelled with own tables instead of released SAP objects such as `I_Supplier` or `I_JournalEntryTP`.

---

## Features

**Document entry (FB60 / FB65)**
- Managed RAP business object with **draft handling**
- Factory actions `creation_invoice` (`KR`) and `creation_creditnote` (`KG`) that create a document with a preset document type
- Value helps for supplier, document type, VAT code, payment terms and currency (`I_CurrencyStdVH`)
- Supplier, VAT code and payment terms shown together with their descriptions (`@ObjectModel.text.element`)
- **Posting date** set automatically from `cl_abap_context_info=>get_system_date( )`
- **Net due date** = document date + payment days from the selected payment terms (NT0 / NT15 / NT30 / NT60 / NT90), refreshed immediately via side effects
- **Gross amount** = net amount + VAT amount
- **Document number** (`asignment`) assigned on save
- After activation, amounts, VAT code, currency and reference become read-only via **instance feature control** - like a posted FI document

**Validations with field-level messages**
- `type_supplier` - the supplier must exist
- `type_vatid` - the VAT code must exist
- `plus_amount` - sign check depending on document type: credit memo amounts must be negative, invoice amounts positive. Net and VAT amounts are checked separately, so each message highlights only the wrong field
- Messages come from message class `Z1112_INVOICES`, are bound to fields with `%element` and cleared with `%state_area`
- All validations run in the draft `Prepare` action, so messages appear while editing

**Line item display (FBL1N)**
- List report with filters on supplier, document type, status, dates and currency
- **Clearing status with criticality**: 🟢 Cleared · 🟡 Open · 🔴 Overdue (open and past the net due date)
- Object page grouped into document data, dates, amounts and administrative data

---

## Architecture

```
z1112_invoices (table)              z1112_invoices_d (draft table)
   └─ ZR_1112_INVOICES              root view entity - BO base layer
        ├─ [1..1] → Zr_TYPE             document types        (ztype)
        ├─ [0..1] → ZR_Vats             VAT codes             (z1112vats)
        ├─ [1..1] → ZR_supplier         supplier master data  (z1112supplier)
        ├─ [0..1] → Zr_1112_PAYMTERMS   payment terms         (z1112paymterms)
        └─ ZC_1112_INVOICES             projection view - UI layer
             ├─ metadata extension (UI annotations)
             └─ ZUI_Z1112_INVOICES_O4 - service definition / OData V4 UI binding
```

| Object | Type | Purpose |
| --- | --- | --- |
| `ZR_1112_INVOICES` | CDS root view entity + behavior definition | Managed BO, draft, UUID key, calculated clearing status |
| `ZBP_R_1112_INVOICES` | Behavior pool | Determinations, validations, factory actions, feature control |
| `ZC_1112_INVOICES` | Projection view + projection behavior + metadata extension | UI layer, `use draft`, `use side effects` |
| `ZUI_Z1112_INVOICES_O4` | Service definition / binding | OData V4 - UI |
| `Z1112_INVOICES` | Message class | Validation message texts |
| `ZR_supplier`, `ZR_Vats`, `Zr_TYPE`, `Zr_1112_PAYMTERMS` | CDS view entities | Value helps and texts |
| `ZSUPPLIER`, `ZVATS`, `ZVALUES`, `ZCL_1112_FILL_PAYTERMS` | Classes (`if_oo_adt_classrun`) | Fill demo data |
| `ZIASSIG_NB`, `ZCL_CREATE_NUMB_FOR_ASSIGMNET` | Number range object + interval class | Prepared for number-range-based numbering (see below) |

### Behavior overview

| Type | Name | Trigger | What it does |
| --- | --- | --- | --- |
| Determination | `set_system_date` | on save: create | Posting date = system date |
| Determination | `calculateDueDate` | on modify: create, PaymenTerms, DocDate | Due date = document date + payment days |
| Determination | `calculate_total_amount` | on modify: create, Netto, VatAmount | Gross = net + VAT |
| Determination | `set_asignment` | on save: create | Document number (`MAX + 1`) |
| Validation | `type_supplier` | on save: create, supplier | Supplier exists |
| Validation | `type_vatid` | on save: create, VatId | VAT code exists |
| Validation | `plus_amount` | on save: create, update, Netto, VatAmount | Sign depends on document type |
| Action | `creation_invoice`, `creation_creditnote` | static factory | Create document with preset type |
| Feature control | `get_instance_features` | instance | Business fields read-only after activation |
| Side effects | - | PaymenTerms, DocDate | UI refreshes due date immediately |

---

## Design decisions

**Technical UUID key + semantic document number**
The key is a UUID with managed early numbering. The human-readable document number is a separate field. This keeps draft handling, `%tky` and associations simple - a common RAP pattern.

**Cardinality `[0..1]` for master-data associations**
A new draft has no VAT code or payment terms yet, so `[1..1]` would not hold for every row. The rule "must be filled" is enforced by `mandatory` and validations, not by cardinality.

**Descriptions via associations, not stored**
VAT, supplier and payment-term descriptions are read through associations – the invoice stores only the code (normalisation, the same way SAP stores only the tax code and payment terms key on a document).

**Calculated status instead of a stored field**
Clearing status and its criticality are derived in CDS with `CASE` from clearing date and due date, so they can never get out of sync with the data. An empty due date is not treated as overdue.

**One validation per business rule**
Net and VAT sign checks share one validation (same rule, same trigger) but each field gets its own message. Supplier and VAT code existence are separate validations because they are independent rules.

**Messages from a message class**
Texts live in `Z1112_INVOICES` instead of hard-coded strings - translatable and changeable without touching code.

---

## Document numbering - what I tried and why

The document number is the most instructive part of the project from a RAP perspective.

1. **Number range in an `on save` determination** (`cl_numberrange_runtime=>number_get`) → runtime error `BEHAVIOR_ILLEGAL_STATEMENT`.
   Without buffering, `number_get` writes to the database. On-save determinations run in an early phase of the save sequence where database changes are not allowed.

2. **Number range in `save_modified` (managed with additional save) + `UPDATE` of the BO table** → the debugger showed `sy-dbcnt = 1`, but the value ended up empty in the table.
   The managed framework persists the instance from its transactional buffer, where the field was still initial, and overwrites the direct update. Lesson: in a managed BO you do not write to its own persistent table - additional save is meant for *other* tables (logs, change documents, events).

3. **Current solution: `MAX + 1` in an `on save` determination**, written to the buffer with `MODIFY ENTITIES`, so the framework persists it.
   ⚠️ Demo-only: with parallel saves two documents could receive the same number.

**Production approach:** make the document number the key with **late numbering** and take it from the number range in `adjust_numbers` - the save step RAP provides exactly for this. The number range object `ZIASSIG_NB` and its interval class are kept in the repository for this upgrade.

---

## Known limitations & roadmap

- [ ] Late numbering from number range (`adjust_numbers`) instead of `MAX + 1`
- [ ] VAT tolerance check as a **warning** (expected VAT = net × rate, deviation allowed for supplier rounding)
- [ ] ABAP Unit tests for validations and determinations
- [ ] Instance authorization (currently `authorization master ( global )` with an empty implementation)
- [ ] Clearing action (sets clearing date) and reversal of documents
- [ ] Side effects for the gross amount
- [ ] In a real S/4HANA system: replace own tables with released objects (`I_Supplier`, tax codes, payment terms) and post via `I_JournalEntryTP`

**Customizing note:** a Business Configuration Maintenance Object was generated for the VAT table (`ZI_Vats_S`, `ZUI_VATS_O4`) to show how configuration is maintained in ABAP Cloud (Custom Business Configurations app + transports). The practice system's user lacks the authorizations to run it, so VAT codes are loaded by the `ZVATS` class instead.
