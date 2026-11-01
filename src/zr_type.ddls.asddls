@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED

@ObjectModel.dataCategory: #VALUE_HELP
@EndUserText.label: 'CDS VIEW of value help for type of doc'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity Zr_TYPE as select from ztype
{
@Consumption.valueHelpDefault.display: true
@Search.defaultSearchElement: true
@EndUserText.label: 'Type'
    key type as Type,
@Consumption.valueHelpDefault.display: true
@Search.defaultSearchElement: true
@EndUserText.label: 'Name'
    name as Name
}
