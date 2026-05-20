CLASS zcl_material_stock_query_test DEFINITION
  PUBLIC FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_mock_api TYPE REF TO zcl_material_stock_api_mock.
    DATA mo_cut      TYPE REF TO zcl_material_stock_query.  "CUT = Class Under Test

    METHODS setup.

    " Test Methoden
    METHODS test_returns_3_records    FOR TESTING.
    METHODS test_empty_when_api_fails FOR TESTING.
    METHODS test_material_field       FOR TESTING.


ENDCLASS.

CLASS zcl_material_stock_query_test IMPLEMENTATION.

  METHOD setup.
    " Vor jedem Test: Mock mit Testdaten vorbereiten
    mo_mock_api = NEW zcl_material_stock_api_mock( ).

    " Testdaten befüllen
    mo_mock_api->mt_mock_data = VALUE #(
      ( material = 'CH_C_104' plant = '1010' storagelocation = '101B'
        batch = '0000000189' matlwrhsstkqtyinmatlbaseunit = '1000.000' )
      ( material = 'CH_C_104' plant = '1010' storagelocation = '101B'
        batch = '9999991' matlwrhsstkqtyinmatlbaseunit = '10000000.000' )
      ( material = '221' plant = '1710' storagelocation = ''
        batch = '' matlwrhsstkqtyinmatlbaseunit = '0.000' )
    ).

    " Query mit Mock-API instanziieren
    mo_cut = NEW zcl_material_stock_query( io_api = mo_mock_api ).
  ENDMETHOD.


  METHOD test_returns_3_records.
    " Direkt API aufrufen und prüfen
    TRY.
        data(lt_result) = mo_mock_api->zif_material_stock_api~get_material_stock(
          iv_apikey = 'test'
        ).


    " Assertion: 3 Einträge erwartet
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result )
      exp = 3
      msg = 'API sollte 3 Einträge zurückgeben'
    ).
    CATCH zcx_material_stock_error INTO DATA(lx_error).
        " Test schlägt fehl wenn Exception geworfen wird
        cl_abap_unit_assert=>fail(
          msg = |Unerwartete Exception: { lx_error->get_text( ) }|
        ).
        "handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD test_empty_when_api_fails.
    " Mock ohne Daten → leere Tabelle
    mo_mock_api->mt_mock_data = VALUE #( ).

    TRY.
        data(lt_result) = mo_mock_api->zif_material_stock_api~get_material_stock(
          iv_apikey = 'test'
        ).


    " Assertion: leer
    cl_abap_unit_assert=>assert_initial(
      act = lt_result
      msg = 'Leere API sollte leere Tabelle zurückgeben'
    ).

    CATCH zcx_material_stock_error INTO DATA(lx_error).
        cl_abap_unit_assert=>fail(
          msg = |Unerwartete Exception: { lx_error->get_text( ) }|
        ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_material_field.
    TRY.
    DATA(lt_result) = mo_mock_api->zif_material_stock_api~get_material_stock(
      iv_apikey = 'test'
    ).

    " Ersten Eintrag lesen
    READ TABLE lt_result INDEX 1 INTO DATA(ls_first).

    " Prüfen: Material Feld korrekt
    cl_abap_unit_assert=>assert_equals(
      act = ls_first-material
      exp = 'CH_C_104'
      msg = 'Material Feld sollte CH_C_104 sein'
    ).
    CATCH zcx_material_stock_error INTO DATA(lx_error).
        cl_abap_unit_assert=>fail(
          msg = |Unerwartete Exception: { lx_error->get_text( ) }|
        ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
