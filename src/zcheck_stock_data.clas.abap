CLASS zcheck_stock_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS zcheck_stock_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    SELECT * FROM zmat_stock INTO TABLE @DATA(lt_stock).

    IF lt_stock IS INITIAL.
      out->write( 'Tabelle ist LEER!' ).
    ELSE.
      out->write( |{ lines( lt_stock ) } Einträge gefunden:| ).
      LOOP AT lt_stock INTO DATA(ls_stock).
        out->write( |Material: { ls_stock-material } | &&
                    |Plant: { ls_stock-plant } | &&
                    |Stock: { ls_stock-stock_qty }| ).
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
