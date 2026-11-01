@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds for suppliers'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP
define view entity ZR_supplier as select from z1112supplier
{
    @Consumption.valueHelpDefault.display: true
    @Search.defaultSearchElement: true
   @EndUserText.label: 'SupplierId'
    key supplier_id as SupplierId,
    @Consumption.valueHelpDefault.display: true
    @Search.defaultSearchElement: true
   @EndUserText.label: 'SupplierDescription'
    
    supplier_description as SupplierDescription
}
