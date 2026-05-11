CLASS ztest_material_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ztest_material_query IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  TRY.
        DATA(lo_api) = NEW zcl_material_stock_api_neu( ).

        DATA(lt_stock) = lo_api->get_material_stock(
          iv_apikey = 'YpVVCZgbzmnQ3AazGaZIxYamnD5qcpOO'
        ).

        out->write( |Anzahl Einträge: { lines( lt_stock ) }| ).

        LOOP AT lt_stock INTO DATA(ls_stock).
          out->write( |Material: { ls_stock-material } | &&
                      |Plant: { ls_stock-plant } | &&
                      |Stock: { ls_stock-matlwrhsstkqtyinmatlbaseunit }| ).
        ENDLOOP.

      CATCH cx_root INTO DATA(lx_error).
        out->write( |Fehler: { lx_error->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
