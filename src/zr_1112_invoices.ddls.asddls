@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'Z1112_INVOICES'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_1112_INVOICES
  as select from z1112_invoices
  association [1..1 ]to Zr_TYPE as _typedoc on $projection.Type = _typedoc.Type
  association [0..1]to ZR_Vats as _vatdoc on $projection.VatId = _vatdoc.V_Id
  association [1..1] to ZR_supplier as _suppdoc on $projection.supplier = _suppdoc.SupplierId
  association [0..1] to Zr_1112_PAYMTERMS as _payterms on $projection.PaymenTerms = _payterms.TermId
 {
 key uuid       as uuid,
 @ObjectModel.text.element: [ 'SupplierDescription' ]
 @Consumption.valueHelpDefinition: [{ entity.name: 'ZR_SUPPLIER' , entity.element: 'SupplierId', useForValidation: true }]
 supplier_id as supplier,
 _suppdoc.SupplierDescription as SupplierDescription,
 reference as Reference,
 @Consumption.valueHelpDefinition: [{ 
    entity.name: 'Zr_TYPE' ,
    entity.element: 'Type',
    useForValidation: true
  }]
   type as Type,
 @ObjectModel.text.element: [ 'VatDescription' ]
   vat_id as VatId,
   _vatdoc.VatDescription as VatDescription,
   asignment as asignment,
 
  doc_date as DocDate,
  @Consumption.valueHelpDefinition: [{ 
     entity.name: 'ZR_1112_PAYMTERMS',
     entity.element: 'TermId',
     useForValidation: true
   }]
   @ObjectModel.text.element: [ 'PayTermDescription' ]
  payment_terms as PaymenTerms,
  _payterms.Description as  PayTermDescription,
  due_date as DueDate,
  posting_date as PostingDate,
    gross_total as Brutto,
  nett_total  as Netto,
vat_amount as VatAmount,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  
  curr as Curr,
  text as Text,
  clearance_date as ClearanceDate,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_created_at as LocalCreatedAt,
  
  
case
  when clearance_date is not initial                                then 'Cleared'
  when due_date is not initial and due_date < $session.system_date  then 'Overdue'
  else                                                                   'Open'
end as ClearingStatus,

case
  when clearance_date is not initial                                then 3
  when due_date is not initial and due_date < $session.system_date  then 1
  else                                                                   2
end as ClearingStatusCriticality,

  _typedoc,
  _vatdoc,
  _suppdoc,
  _payterms
  
  
  
}
