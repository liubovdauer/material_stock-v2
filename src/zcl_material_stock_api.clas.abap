CLASS zcl_material_stock_api DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_material_stock,
        Material                     TYPE string,
        Plant                        TYPE string,
        StorageLocation              TYPE string,
        Batch                        TYPE string,
        MRPArea                      TYPE string,
        MaterialBaseUnit             TYPE string,
        MatlWrhsStkQtyInMatlBaseUnit TYPE string,
      END OF ty_material_stock,
      tt_material_stock TYPE STANDARD TABLE OF ty_material_stock
                        WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_results_wrapper,
        results TYPE tt_material_stock,
      END OF ty_results_wrapper.

    TYPES:
      BEGIN OF ty_d_wrapper,
        d TYPE ty_results_wrapper,
      END OF ty_d_wrapper.

    METHODS get_material_stock
      RETURNING VALUE(rt_stock) TYPE tt_material_stock
      RAISING   zcx_material_stock_error.

    METHODS load_and_save
      RAISING zcx_material_stock_error.

ENDCLASS.


CLASS zcl_material_stock_api IMPLEMENTATION.

  METHOD get_material_stock.

    DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
      cl_http_destination_provider=>create_by_url(
        'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_MATERIAL_STOCK_SRV/A_MatlStkInAcctMod?$top=5&$format=json'
      )
    ).

    DATA(lo_request) = lo_http_client->get_http_request( ).
    lo_request->set_header_fields( VALUE #(
      ( name  = 'APIKey'
        value = 'YpVVCZgbzmnQ3AazGaZIxYamnD5qcpOO' )
    ) ).

    DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

    DATA(lv_status) = lo_response->get_status( ).
    IF lv_status-code <> 200.
      RAISE EXCEPTION TYPE zcx_material_stock_error.
    ENDIF.

    DATA(lv_body) = lo_response->get_text( ).

    DATA ls_result TYPE ty_d_wrapper.
    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_body
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      CHANGING
        data        = ls_result
    ).

    rt_stock = ls_result-d-results.

  ENDMETHOD.


  METHOD load_and_save.

    DATA(lt_stock) = get_material_stock( ).

    DELETE FROM zmat_stock.

    DATA lt_db_entries TYPE TABLE OF zmat_stock.

    LOOP AT lt_stock INTO DATA(ls_stock).
      APPEND VALUE #(
        client             = sy-mandt
        material           = ls_stock-Material
        plant              = ls_stock-Plant
        storage_location   = ls_stock-StorageLocation
        batch              = ls_stock-Batch
        mrp_area           = ls_stock-MRPArea
        material_base_unit = ls_stock-MaterialBaseUnit
        stock_qty          = ls_stock-MatlWrhsStkQtyInMatlBaseUnit
      ) TO lt_db_entries.
    ENDLOOP.

    INSERT zmat_stock FROM TABLE @lt_db_entries.

    COMMIT WORK.

  ENDMETHOD.

ENDCLASS.
