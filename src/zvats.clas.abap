CLASS zvats DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zvats IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DELETE FROM Z1112vats.

  INSERT Z1112VATS from table @( value #(
  ( vat_id = 'i3' vat_description = '25 % standard in Swedish' )
  (  vat_id = 'i2' vat_description = '12 % standard in Swedish' )
  (  vat_id = 'i1' vat_description = '6 % standard in Swedish' )
   (  vat_id = 'i0' vat_description = '0 % standard in Swedish' )
  (  vat_id = 'RC1' vat_description = '0 % standard from UE contry' )
  (  vat_id = 'RC2' vat_description = '0 % standard from outside of UE country' )
   ) )  .

out->write( |WASTWOWIONO { sy-dbcnt } kodow Vat| ) .
  ENDMETHOD.
ENDCLASS.
