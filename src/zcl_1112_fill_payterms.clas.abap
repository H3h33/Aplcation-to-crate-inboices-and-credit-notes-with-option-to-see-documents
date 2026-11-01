CLASS zcl_1112_fill_payterms DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_1112_fill_payterms IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  DELETE FROM z1112paymterms.

    INSERT z1112paymterms FROM TABLE @( VALUE #(
      ( term_id = 'NT0' payment_days = 0 description = 'Net 0 days' )
      ( term_id = 'NT15' payment_days = 15 description = 'Net 15 days' )
      ( term_id = 'NT30' payment_days = 30 description = 'Net 30 days' )
      ( term_id = 'NT60' payment_days = 60 description = 'Net 60 days' )
      ( term_id = 'NT90' payment_days = 90 description = 'Net 90 days' ) ) ).

    out->write( |Wstawiono { sy-dbcnt } warunków płatności.| ).

  ENDMETHOD.
ENDCLASS.
