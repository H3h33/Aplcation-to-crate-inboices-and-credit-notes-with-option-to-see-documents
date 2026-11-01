@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds for payment terms'
@Metadata.ignorePropagatedAnnotations: true
define view entity Zr_1112_PAYMTERMS as select from z1112paymterms
{
   @ObjectModel.text.element: ['Description']
      @EndUserText.label: 'Payment Terms'
  key term_id     as TermId,
      @EndUserText.label: 'PaymentDays'
      payment_days        as PaymentDays,
      @Semantics.text: true
      @EndUserText.label: 'Description'
      description as Description
}
