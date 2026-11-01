CLASS zcl_create_numb_for_assigmnet DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_create_numb_for_assigmnet IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DATA assign_numbers TYPE cl_numberrange_intervals=>nr_interval.

  assign_numbers = VALUE #( ( nrrangenr = '01'
  fromnumber = '5100000000'
  tonumber = '5199999999'
  procind = 'I'
  )
  ).

  TRY.

  cl_numberrange_intervals=>create(
  EXPORTING
  interval = assign_numbers
  object = 'ZIASSIG_NB'
  subobject = ''
  IMPORTING error = DATA(error)
  error_inf = DATA(error_inf)
  error_iv = DATA(error_iv)
  warning = DATA(warning)
  ).

  IF ERROR is INITIAL.
  out->write( 'Interwał 01 utworzony.' ).
  ELSE.
  out->write( |Błąd: { error_inf-msgnr } pole: { error_inf-fieldname }| ).
  ENDIF.

   CATCH cx_number_ranges INTO DATA(ex).
        out->write( ex->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
