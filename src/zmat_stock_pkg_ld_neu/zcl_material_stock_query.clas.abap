CLASS zcl_material_stock_query DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

ENDCLASS.


CLASS zcl_material_stock_query IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    DATA lt_data TYPE STANDARD TABLE OF zce_material_stock.

    " ── API aufrufen ────────────────────────────────────────────────────
    TRY.
        DATA(lo_api) = NEW zcl_material_stock_api_neu( ).

        DATA(lt_stock) = lo_api->get_material_stock(
          iv_apikey = 'YpVVCZgbzmnQ3AazGaZIxYamnD5qcpOO'
        ).

        LOOP AT lt_stock INTO DATA(ls_stock).
          APPEND VALUE #(
            Material                     = ls_stock-material
            Plant                        = ls_stock-plant
            StorageLocation              = ls_stock-storagelocation
            Batch                        = ls_stock-batch
            MRPArea                      = ls_stock-mrparea
            MaterialBaseUnit             = ls_stock-materialbaseunit
            MatlWrhsStkQtyInMatlBaseUnit = ls_stock-matlwrhsstkqtyinmatlbaseunit
          ) TO lt_data.
        ENDLOOP.

      CATCH cx_root.
        CLEAR lt_data.
    ENDTRY.

    " ── RAP Paging (WICHTIG: korrektes Handling) ────────────────────────
    DATA(lo_paging) = io_request->get_paging( ).

    DATA(lv_top)  = lo_paging->get_page_size( ).
    DATA(lv_skip) = lo_paging->get_offset( ).

    DATA lv_total TYPE int8.
    lv_total = lines( lt_data ).

    DATA lt_paged TYPE STANDARD TABLE OF zce_material_stock.

    " ── Kein Paging angefordert → alles zurückgeben
    IF lv_top = if_rap_query_paging=>page_size_unlimited OR lv_top IS INITIAL.
      lt_paged = lt_data.
    ELSE.

      " ── SAFE slicing (RAP/OData V4 compliant)
      lt_paged = VALUE #(
        FOR i = lv_skip + 1 THEN i + 1 WHILE i <= lines( lt_data )
        ( lt_data[ i ] )
      ).

      " ── Limit anwenden ($top)
      IF lines( lt_paged ) > lv_top.
        DELETE lt_paged FROM lv_top + 1.
      ENDIF.

    ENDIF.

    " ── Total Count für Fiori Elements ─────────────────────────────────
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lv_total ).
    ENDIF.

    " ── Ergebnis setzen ────────────────────────────────────────────────
    io_response->set_data( lt_paged ).

  ENDMETHOD.

ENDCLASS.
