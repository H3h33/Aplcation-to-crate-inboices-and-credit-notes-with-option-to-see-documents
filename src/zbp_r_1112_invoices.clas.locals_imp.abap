CLASS LHC_ZR_1112_INVOICES DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.

   TYPES: ty_t_update_result TYPE TABLE FOR UPDATE ZR_1112_INVOICES,
          ty_t_read_result TYPE TABLE FOR READ RESULT ZR_1112_INVOICES,
          ty_t_create TYPE TABLE FOR CREATE ZR_1112_INVOICES.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Zr1112Invoices
        RESULT result,
      set_system_date FOR DETERMINE ON SAVE
            keys FOR Zr1112Invoices~set_system_date,

      creation_creditnote FOR MODIFY
            keys FOR ACTION Zr1112Invoices~creation_creditnote.

          METHODS creation_invoice FOR MODIFY
            keys FOR ACTION Zr1112Invoices~creation_invoice.
          METHODS plus_amount FOR VALIDATE ON SAVE
            keys FOR Zr1112Invoices~plus_amount.
          METHODS get_instance_features FOR INSTANCE FEATURES
            keys REQUEST requested_features FOR Zr1112Invoices RESULT result.

          METHODS calculate_total_amount FOR DETERMINE ON MODIFY
            keys FOR zr1112invoices~calculate_total_amount.
          METHODS type_supplier FOR VALIDATE ON SAVE
            keys FOR zr1112invoices~type_supplier.

          METHODS set_asignment FOR DETERMINE ON SAVE
            keys for zr1112invoices~set_asignment.
          METHODS type_vatid FOR VALIDATE ON SAVE
            keys FOR zr1112invoices~type_vatid.

           METHODS calculateDueDate FOR DETERMINE ON MODIFY
           IMPORTING keys FOR zr1112invoices~calculateDueDate.

ENDCLASS.

CLASS LHC_ZR_1112_INVOICES IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
  METHOD set_system_date.
  DATA cordate TYPE ty_t_update_result.



LOOP AT keys ASSIGNING FIELD-SYMBOL(<DATEE>).
APPEND value #( %tky = <DATEE>-%tky
PostingDate = cl_abap_context_info=>get_system_date(  )
) to cordate.

endloop.
 MODIFY ENTITIES OF ZR_1112_INVOICES IN LOCAL MODE
 ENTITY Zr1112Invoices
 UPDATE FIELDS ( PostingDate ) WITH CORRESPONDING #( cordate )

.
  ENDMETHOD.

  METHOD creation_creditnote.

  DATA result TYPE ty_t_create.

  APPEND VALUE #( Type = 'KG' ) TO result.

  Modify ENTITIES OF ZR_1112_INVOICES in local mode
  ENTITY Zr1112Invoices
  CREATE AUTO FILL CID FIELDS ( Type )
  WITH CORRESPONDING #( result )
  MAPPED mapped
  FAILED failed
  REPORTED reported .

  ENDMETHOD.

  METHOD creation_invoice.
  DATA result TYPE ty_t_create.

  APPEND VALUE #( Type = 'KR' ) TO result.

  Modify ENTITIES OF ZR_1112_INVOICES in local mode
  ENTITY Zr1112Invoices
  CREATE AUTO FILL CID FIELDS ( Type )
  WITH CORRESPONDING #( result )
  MAPPED mapped
  FAILED failed
  REPORTED reported .
  ENDMETHOD.

  METHOD plus_amount.
  DATA resultt TYPE ty_t_read_result.

  READ ENTITIES OF ZR_1112_INVOICES in local mode
  ENTITY Zr1112Invoices
  FIELDS ( netto VatAmount Type ) WITH CORRESPONDING #( keys )
  RESULT resultt.

  LOOP AT resultt ASSIGNING FIELD-SYMBOL(<minus>).
  APPEND VALUE #( %TKY = <minus>-%tky
                  %state_area = 'VALIDATE_AMOUNTS'  )
  to reported-zr1112invoices.
  DATA(credit_note) = xsdbool( <minus>-Type = 'KG' ).

  DATA(netto_wrong) = COND abap_bool(
  when credit_note = abap_true THEN xsdbool( <minus>-Netto >= 0 )
  ELSE
  xsdbool( <minus>-Netto <= 0 )
    ).

  DATA(vat_wrong) = COND abap_bool(
  when credit_note = abap_true THEN xsdbool( <minus>-VatAmount >= 0 )
  ELSE xsdbool( <minus>-VatAmount <= 0 )
     ).

  DATA(msg_number) = COND symsgno( WHEN credit_note = abap_true then '002' ELSE '003' ).

  IF netto_wrong = abap_true OR vat_wrong = abap_true.
  APPEND VALUE #( %TKY = <minus>-%TKY ) TO failed-zr1112invoices.
  ENDIF.

  IF netto_wrong = abap_true.
    APPEND VALUE #( %TKY = <minus>-%tky
                    %state_area = 'VALIDATE_AMOUNTS'
                    %element-Netto = if_abap_behv=>mk-on
                    %msg = new_message( id = 'Z1112_INVOICES'
                                        number = msg_number
                                        severity = if_abap_behv_message=>severity-error
                                        v1 = 'Net amount' )

                     ) TO reported-zr1112invoices.
  ENDIF.

  IF vat_wrong = abap_true.
   APPEND VALUE #( %TKY = <minus>-%tky
                  %state_area = 'VALIDATE_AMOUNTS'
                  %element-VatAmount = if_abap_behv=>mk-on
                  %msg = new_message( id = 'Z1112_INVOICES'
                                      number = msg_number
                                      severity = if_abap_behv_message=>severity-error
                                      v1 = 'VAT amount' )
                  ) TO reported-zr1112invoices.


   ENDIF.


  ENDLOOP.

  ENDMETHOD.




  METHOD get_instance_features.


select uuid  FROM z1112_invoices FOR ALL ENTRIES IN @keys
WHERE uuid = @keys-uuid
INTO TABLE @DATA(active_result).

LOOP AT keys     ASSIGNING FIELD-SYMBOL(<key>).

APPEND CORRESPONDING #( <key> ) to result ASSIGNING FIELD-SYMBOL(<result>).
IF line_exists( active_result[ uuid = <key>-uuid ] ).
<result>-%features-%field-Curr = if_abap_behv=>fc-f-read_only.
<result>-%features-%field-Reference = if_abap_behv=>fc-f-read_only.
<result>-%features-%field-Netto = if_abap_behv=>fc-f-read_only.
<result>-%features-%field-VatAmount = if_abap_behv=>fc-f-read_only.
<result>-%features-%field-VatId = if_abap_behv=>fc-f-read_only.

ENDIF.
ENDLOOP.

  ENDMETHOD.



  METHOD calculate_total_amount.

  DATA resultt TYPE ty_t_read_result.

  READ ENTITIES OF zr_1112_invoices IN LOCAL MODE
  ENTITY Zr1112Invoices
  FIELDS ( Netto VatAmount )
  with corresponding #( keys )
  RESULT resultt.

MODIFY ENTITIES OF zr_1112_invoices IN LOCAL MODE
ENTITY Zr1112Invoices
UPDATE FIELDS ( Brutto )
WITH value #( FOR Zr1112Invoices IN resultt (
%tky = Zr1112Invoices-%tky
Brutto = Zr1112Invoices-Netto + Zr1112Invoices-VatAmount
) ).


  ENDMETHOD.



  METHOD type_supplier.
DATA resultt TYPE ty_t_read_result.
  READ ENTITIES OF zr_1112_invoices in local mode
  ENTITY Zr1112Invoices
  fields ( supplier )
  with CORRESPONDING #( keys )
  RESULT resultt.

  IF resultt IS NOT INITIAL.
  SELECT SupplierId
    FROM zr_supplier
    FOR ALL ENTRIES IN @resultt
    WHERE SupplierId = @resultt-supplier
    INTO TABLE @DATA(existing_suppliers).
ENDIF.

 LOOP AT resultt ASSIGNING FIELD-SYMBOL(<supplierss>).

  APPEND VALUE #( %tky = <supplierss>-%tky
                  %state_area = 'VALIDATE_SUPPLIER' )

                  TO reported-zr1112invoices.

  IF <supplierss>-supplier IS INITIAL
     OR NOT line_exists( existing_suppliers[ SupplierId = <supplierss>-supplier ] ).
    APPEND VALUE #( %tky = <supplierss>-%tky ) TO failed-zr1112invoices.

   APPEND VALUE #( %tky = <supplierss>-%tky
                   %state_area = 'VALIDATE_SUPPLIER'
                   %element-supplier = if_abap_behv=>mk-on
                   %msg = new_message( id = 'Z1112_INVOICES'
                                       number = '001'
                                       severity = if_abap_behv_message=>severity-error
                                       v1 = <supplierss>-supplier


                   )


   ) TO reported-Zr1112Invoices.

 ENDIF.
ENDLOOP.



  ENDMETHOD.



  METHOD SET_ASIGNMENT.
DATA updates type table FOR UPDATE zr_1112_invoices.
READ ENTITIES OF zr_1112_invoices IN LOCAL MODE
ENTITY Zr1112Invoices
FIELDS ( asignment )
WITH CORRESPONDING #( keys )
RESULT DATA(resultt).

DELETE resultt where asignment is not INITIAL.

CHECK resultt IS NOT INITIAL.
SELECT SINGLE FROM z1112_invoices
FIELDS MAX( asignment )
INTO @DATA(max_number).

IF max_number is INITIAL.
max_number = 5100000000.
ENDIF.

LOOP at resultt ASSIGNING FIELD-SYMBOL(<numberss>).
max_number = max_number + 1.
APPEND VALUE #( %tky = <numberss>-%tky
                asignment = max_number ) to updates.


ENDLOOP.

MODIFY ENTITIES OF zr_1112_invoices IN LOCAL MODE
ENTITY Zr1112Invoices
UPDATE
FIELDS ( asignment )
WITH updates.

  ENDMETHOD.

  METHOD type_vatid.

  READ ENTITIES OF zr_1112_invoices IN LOCAL MODE
  ENTITY Zr1112Invoices
  FIELDS ( VatId )
  WITH CORRESPONDING #( keys )
  RESULT DATA(resultt).

if resultt is not INITIAL.

  SELECT vat_id
  FROM z1112vats
  FOR ALL ENTRIES IN @resultt
  WHERE vat_id = @resultt-VatId
  INTO table @DATA(existing_vats).

 endif.

 LOOP AT resultt ASSIGNING FIELD-SYMBOL(<VATS>).

 APPEND VALUE #( %tky = <VATS>-%tky
                 %state_area = 'VALIDATE_VATS'
  ) TO reported-zr1112invoices.

  IF resultt IS INITIAL OR NOT line_exists( existing_vats[ vat_id = <VATS>-VatId ] ).
  APPEND VALUE #( %tky = <VATS>-%tky ) to failed-zr1112invoices.

  APPEND VALUE #( %tky = <VATS>-%tky
                  %state_area = 'VALIDATE_VATS'
                  %element-VatId = if_abap_behv=>mk-on
                  %msg = new_message( id = 'Z1112_INVOICES'
                                      number = '004'
                                      severity = if_abap_behv_message=>severity-error
                                      v1 = <VATS>-VatId

                                    ) ) TO reported-zr1112invoices.

   ENDIF.
  ENDLOOP.
  ENDMETHOD.

  METHOD CALCULATEDUEDATE.
 READ ENTITIES OF zr_1112_invoices IN LOCAL MODE
    ENTITY Zr1112Invoices
      FIELDS ( PaymenTerms DocDate )
      WITH CORRESPONDING #( keys )
    RESULT DATA(resultt).

  IF resultt IS INITIAL.
    RETURN.
  ENDIF.

  SELECT term_id, payment_days
    FROM z1112paymterms
    FOR ALL ENTRIES IN @resultt
    WHERE term_id = @resultt-PaymenTerms
    INTO TABLE @DATA(terms).

  DATA updates TYPE TABLE FOR UPDATE zr_1112_invoices.

  LOOP AT resultt ASSIGNING FIELD-SYMBOL(<PaymTermsDays>).
    IF <PaymTermsDays>-DocDate IS INITIAL.
      CONTINUE.
    ENDIF.

    READ TABLE terms WITH KEY term_id = <PaymTermsDays>-PaymenTerms
      ASSIGNING FIELD-SYMBOL(<term>).
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    APPEND VALUE #( %tky    = <PaymTermsDays>-%tky
                    DueDate = <PaymTermsDays>-DocDate + <term>-payment_days ) TO updates.
  ENDLOOP.

  MODIFY ENTITIES OF zr_1112_invoices IN LOCAL MODE
    ENTITY Zr1112Invoices
      UPDATE FIELDS ( DueDate )
      WITH updates.
  ENDMETHOD.

ENDCLASS.
