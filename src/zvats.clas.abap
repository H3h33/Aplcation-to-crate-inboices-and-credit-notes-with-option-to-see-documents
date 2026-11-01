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
  ( vat_id = 'I3' vat_description = '25 % standard in Swedish' )
  (  vat_id = 'I2' vat_description = '12 % standard in Swedish' )
  (  vat_id = 'I1' vat_description = '6 % standard in Swedish' )
   (  vat_id = 'I0' vat_description = '0 % standard in Swedish' )
  (  vat_id = 'R1' vat_description = '0 % standard from UE contry' )
  (  vat_id = 'R2' vat_description = '0 % standard from outside of UE country' )
   ) )  .

out->write( |WASTWOWIONO { sy-dbcnt } kodow Vat| ) .
  ENDMETHOD.
ENDCLASS.
