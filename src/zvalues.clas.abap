CLASS zvalues DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zvalues IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DELETE FROM ZTYPE.

  INSERT ZTYPE FROM TABLE @( VALUE #( ( type = 'KR' name = 'Debit note' )

  ( type = 'KG' name = 'Credit note' )
  )
  ).

  out->write( |Wstawiono { sy-dbcnt } wierszy| ).
  ENDMETHOD.
ENDCLASS.
