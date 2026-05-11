CLASS zcl_material_stock_api_neu DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_material_stock,
        material        TYPE string,
        plant           TYPE string,
        storagelocation TYPE string,
        batch           TYPE string,
        mrparea         TYPE string,
        materialbaseunit TYPE string,
        matlwrhsstkqtyinmatlbaseunit TYPE string,
      END OF ty_material_stock,
      tt_material_stock TYPE STANDARD TABLE OF ty_material_stock WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_results_wrapper,
        results TYPE tt_material_stock,
      END OF ty_results_wrapper.

    TYPES:
      BEGIN OF ty_d_wrapper,
        d TYPE ty_results_wrapper,
      END OF ty_d_wrapper.

    METHODS get_material_stock
      IMPORTING
        iv_apikey        TYPE string
      RETURNING
        VALUE(rt_stock)  TYPE tt_material_stock
      RAISING
        zcx_material_stock_error.

ENDCLASS.



CLASS zcl_material_stock_api_neu IMPLEMENTATION.

   METHOD get_material_stock.

    TRY.

        " HTTP Client erstellen
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
          cl_http_destination_provider=>create_by_url(
            'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_MATERIAL_STOCK_SRV/A_MatlStkInAcctMod?$top=5&$format=json'
          )
        ).

        DATA(lo_request) = lo_http_client->get_http_request( ).

        " Header setzen
        lo_request->set_header_fields( VALUE #(
          ( name = 'APIKey' value = 'YpVVCZgbzmnQ3AazGaZIxYamnD5qcpOO' )

        ) ).

        " Request senden
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

        DATA(ls_status) = lo_response->get_status( ).

        " HTTP Fehler behandeln
        IF ls_status-code <> 200.
          RETURN.

        ENDIF.

        " Response lesen
        DATA(lv_body) = lo_response->get_text( ).

        " JSON -> ABAP
        DATA ls_result TYPE ty_d_wrapper.

        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = lv_body
            pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          CHANGING
            data        = ls_result
        ).

        rt_stock = ls_result-d-results.

      CATCH cx_root INTO DATA(lx_error).

        RETURN.


    ENDTRY.

  ENDMETHOD.

ENDCLASS.
