CLASS zsupplier DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zsupplier IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  DELETE from z1112supplier.

  INSERT z1112supplier from TABLE @( Value #(
  ( supplier_id = '11122' supplier_description = 'Supplier A' )
  ( supplier_id = '11123' supplier_description = 'Supplier B' )
  ( supplier_id = '11124' supplier_description = 'Supplier C' )
  ( supplier_id = '11125' supplier_description = 'Supplier D' )
  ( supplier_id = '11126' supplier_description = 'Supplier E' )
  ( supplier_id = '11127' supplier_description = 'Supplier F' )
   ) ).

 out->write( | Dodano { sy-dbcnt } supplierow| ).
  ENDMETHOD.
ENDCLASS.
