CLASS zload_material_stock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zload_material_stock IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TRY.
        DATA(lo_api) = NEW zcl_material_stock_api( ).
        lo_api->load_and_save( ).
        out->write( 'Daten erfolgreich geladen!' ).

      CATCH zcx_material_stock_error INTO DATA(lx_error).
        out->write( |Fehler: { lx_error->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
