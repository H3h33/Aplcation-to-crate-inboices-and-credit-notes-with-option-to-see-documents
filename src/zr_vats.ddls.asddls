@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED

@ObjectModel.dataCategory: #VALUE_HELP
@EndUserText.label: 'CDS VIEW of value help for type of doc'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity ZR_Vats as select from z1112vats
{
@Consumption.valueHelpDefault.display: true
@Search.defaultSearchElement: true
@EndUserText.label: 'V_Id'   
   key vat_id as V_Id,
@Consumption.valueHelpDefault.display: true
@Search.defaultSearchElement: true
@EndUserText.label: 'VatDescription'
     vat_description as VatDescription,
     last_changed_at as LastChangedAt,
     local_last_changed_at as LocalLastChangedAt

    
}
