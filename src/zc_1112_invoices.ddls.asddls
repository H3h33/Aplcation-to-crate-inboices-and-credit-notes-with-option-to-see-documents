@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'Z1112_INVOICES'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_1112_INVOICES
  provider contract transactional_query
  as projection on ZR_1112_INVOICES
  association [1..1] to ZR_1112_INVOICES as _BaseEntity on $projection.uuid  = _BaseEntity.uuid 
   association [0..1]to ZR_Vats as _vatdoc on $projection.VatId = _vatdoc.V_Id
   association [1..1] to ZR_supplier as _suppdoc on $projection.supplier = _suppdoc.SupplierId
{
  key uuid,
  @Consumption: {valueHelpDefinition: [{ entity.name: 'ZR_SUPPLIER' ,
  entity.element: 'SupplierId' , useForValidation: true} ]}
  supplier,
  Reference,
  @Consumption:{ valueHelpDefinition: [{ entity.name: 'Zr_TYPE' ,
    entity.element: 'Type',
    useForValidation: true }] }
  Type,
  asignment,
  DocDate,
    @Consumption.valueHelpDefinition: [{ 
     entity.name: 'ZR_1112_PAYMTERMS',
     entity.element: 'TermId',
     useForValidation: true
   }]
  PaymenTerms,
  DueDate,
  PostingDate,
  Netto,
  @Consumption: {
    valueHelpDefinition: [ {
      entity.element: 'Currency', 
      entity.name: 'I_CurrencyStdVH', 
      useForValidation: true
    } ]
  }
  Curr,
  VatAmount,
  @Consumption: {
  valueHelpDefinition: [{entity.name: 'ZR_VATS' ,
  entity.element: 'V_Id'}]}
  VatId,
  Brutto,
  Text,
  ClearanceDate,
  ClearingStatus,
ClearingStatusCriticality,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  CreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LocalCreatedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalCreatedAt,
  _BaseEntity,
  _vatdoc,
  _suppdoc
}
