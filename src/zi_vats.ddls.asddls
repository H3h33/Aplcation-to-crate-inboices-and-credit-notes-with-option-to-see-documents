@EndUserText.label: 'Vats'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.dataCategory: #VALUE_HELP
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_Vats
  as select from z1112vats
  association to parent ZI_Vats_S as _VatsAll on $projection.SingletonID = _VatsAll.SingletonID
{
@Consumption.valueHelpDefault.display: true
@Search.defaultSearchElement: true
@EndUserText.label: 'VatId' 
  key vat_id as VatId,
  @Consumption.valueHelpDefault.display: true
@Search.defaultSearchElement: true
@EndUserText.label: 'VatDescription'
  vat_description as VatDescription,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  local_last_changed_at as LocalLastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _VatsAll
}
