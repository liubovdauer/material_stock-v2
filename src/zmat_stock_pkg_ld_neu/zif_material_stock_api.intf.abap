INTERFACE zif_material_stock_api
  PUBLIC .

  TYPES:
    BEGIN OF ty_material_stock,
      material        TYPE string,
      plant           TYPE string,
      storagelocation TYPE string,
      batch           TYPE string,
      mrparea         TYPE string,
      materialbaseunit TYPE string,
      matlwrhsstkqtyinmatlbaseunit TYPE string,
    END OF ty_material_stock.

  TYPES tt_material_stock TYPE STANDARD TABLE OF ty_material_stock WITH DEFAULT KEY.

  TYPES:
    BEGIN OF ty_results_wrapper,
      results TYPE tt_material_stock,
    END OF ty_results_wrapper.

  TYPES:
    BEGIN OF ty_d_wrapper,
      d TYPE ty_results_wrapper,
    END OF ty_d_wrapper.

  METHODS get_material_stock
    IMPORTING iv_apikey TYPE string
    RETURNING VALUE(rt_stock) TYPE tt_material_stock
    RAISING zcx_material_stock_error.

ENDINTERFACE.
