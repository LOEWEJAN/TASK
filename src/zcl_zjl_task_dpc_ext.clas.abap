CLASS zcl_zjl_task_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zjl_task_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.

    METHODS dynamic_tileset_get_entity
        REDEFINITION .
    METHODS dynamic_tileset_get_entityset
        REDEFINITION .
  PRIVATE SECTION.

    METHODS get_counter
      RETURNING
        VALUE(rs_entity) TYPE zcl_zjl_task_mpc=>ts_dynamic_tile .
ENDCLASS.



CLASS zcl_zjl_task_dpc_ext IMPLEMENTATION.


  METHOD dynamic_tileset_get_entity.
**TRY.
*SUPER->DYNAMIC_TILESET_GET_ENTITY(
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*       ).
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

    " Update Entity Info
    er_entity = me->get_counter( ).

  ENDMETHOD.


  METHOD dynamic_tileset_get_entityset.
**TRY.
*SUPER->DYNAMIC_TILESET_GET_ENTITYSET(
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*       ).
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

    APPEND get_counter( )  TO et_entityset.

  ENDMETHOD.


  METHOD get_counter.

    SELECT COUNT(*)
           FROM zjl_o_d_task
      WHERE mytaskfl    EQ 'X'
        AND completedfl NE 'X'
       INTO @DATA(l_count_open).

    SELECT COUNT(*)
           FROM zjl_o_d_task
      WHERE mytaskfl EQ 'X'
        AND completedfl NE 'X'
        AND calccriticality GT 1
                   INTO @DATA(l_count_overdue).

    rs_entity = VALUE #(  BASE rs_entity
                            id            = 'GetCounter'
                            icon          = abap_false "'sap-icon://complete'
                            info          = abap_false "Text to be displayed at the bottom of the tile.
                            infostate     = abap_false "Negative, Neutral, Positive, Critical
                            number        = CONV string( l_count_open ) "Number to be displayed in the top right corner of the tile.
                            numberdigits  = abap_false
                            numberfactor  = abap_false
                            numberstate   = COND #( WHEN l_count_overdue = 0  "Negative, Neutral, Positive, Critical
                                                      THEN 'Positive'
                                                      ELSE 'Negative'     )
                            numberunit    = space "Unit to be displayed below the number,
                            statearrow    = abap_false "None, Up, Down
                            subtitle      = abap_false "Subtitle to be displayed below the tile title.
                            targetparams  = abap_false "List of key-value-pairs separated by ampersands.
                            title         = abap_false "Title to be displayed in the tile.
).



  ENDMETHOD.
ENDCLASS.
