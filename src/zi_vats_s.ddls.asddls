@EndUserText.label: 'Vats Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Semantics.valueRange.maximum: '1'
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'VatsAll'
  }
}
define root view entity ZI_Vats_S
  as select from I_Language
    left outer join Z1112VATS on 0 = 0
  composition [0..*] of ZI_Vats as _Vats
{
  @UI.facet: [ {
    id: 'Vats', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Vats', 
    position: 1 , 
    targetElement: '_Vats'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _Vats,
  @UI.hidden: true
  max( Z1112VATS.LAST_CHANGED_AT ) as LastChangedAtMax
}
where I_Language.Language = $session.system_language
