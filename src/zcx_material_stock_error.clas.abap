CLASS zcx_material_stock_error DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        previous LIKE previous OPTIONAL.

ENDCLASS.



CLASS ZCX_MATERIAL_STOCK_ERROR IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    SUPER->constructor(
      previous = previous
    ).
  ENDMETHOD.
ENDCLASS.
