CLASS zcl_material_stock_api_mock DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_material_stock_api .

    " Testdaten die der Mock zurückgibt
    DATA mt_mock_data TYPE zif_material_stock_api=>tt_material_stock.

    " Optional: Exception simulieren
    DATA mv_raise_error TYPE abap_bool VALUE abap_false.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_material_stock_api_mock IMPLEMENTATION.


  METHOD zif_material_stock_api~get_material_stock.

     IF mv_raise_error = abap_true.
      RAISE EXCEPTION TYPE zcx_material_stock_error.
    ENDIF.

  " Kein HTTP Call – gibt einfach die vorbereiteten Testdaten zurück
  rt_stock = mt_mock_data.

  ENDMETHOD.
ENDCLASS.
