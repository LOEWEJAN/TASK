CLASS zjl_cl_attach_bo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tp_entity  TYPE zjl_o_d_attachment .
    TYPES: tpt_entity TYPE STANDARD TABLE OF zjl_o_d_attachment .

    TYPES:
      tpt_failed   TYPE TABLE FOR FAILED   zjl_o_d_attachment .
    TYPES:
      tpt_mapped   TYPE TABLE FOR MAPPED   zjl_o_d_attachment .
    TYPES:
      tpt_reported TYPE TABLE FOR REPORTED zjl_o_d_attachment .

    CLASS-METHODS get_instance
      RETURNING
        VALUE(rr_instance) TYPE REF TO zjl_cl_attach_bo .

    METHODS default_for_create
      RETURNING
        VALUE(rs_entity) TYPE tp_entity.

    METHODS create
      IMPORTING
        !is_entity  TYPE tp_entity
      EXPORTING
        !es_entity  TYPE tp_entity
        !et_message TYPE zjl_if_rap=>tpt_message .

    METHODS read
      IMPORTING
        !i_taskid         TYPE zjl_id
        !i_versno         TYPE zjl_version
        !i_atacno         TYPE zjl_version
        !i_include_buffer TYPE abap_boolean DEFAULT 'X'
      EXPORTING
        !es_entity        TYPE tp_entity
        !et_message       TYPE zjl_if_rap=>tpt_message .

    METHODS read_by_assoc
      IMPORTING
        !i_taskid         TYPE zjl_id
        !i_versno         TYPE zjl_version
        !i_include_buffer TYPE abap_boolean DEFAULT 'X'
      EXPORTING
        !et_entity        TYPE tpt_entity
        !et_message       TYPE zjl_if_rap=>tpt_message .

*    METHODS create_by_assoc
*      IMPORTING
*        !i_taskid         TYPE zjl_id
*        !i_versno         TYPE zjl_version
*      EXPORTING
*        !et_db            TYPE tpt_db
*        !et_message       TYPE zjl_if_rap=>tpt_message .

    METHODS update
      IMPORTING
        !is_entity  TYPE tp_entity
      EXPORTING
        !es_entity  TYPE tp_entity
        !et_message TYPE zjl_if_rap=>tpt_message .

    METHODS delete
      IMPORTING
        !i_taskid   TYPE zjl_id
        !i_versno   TYPE zjl_version
        !i_atacno   TYPE zjl_version
      EXPORTING
        !et_message TYPE zjl_if_rap=>tpt_message .

    CLASS-METHODS handle_messages
      IMPORTING
        !i_cid      TYPE string OPTIONAL
        !i_taskid   TYPE zjl_id OPTIONAL
        !i_versno   TYPE zjl_version OPTIONAL
        !i_atacno   TYPE zjl_version OPTIONAL
        !it_message TYPE zjl_if_rap=>tpt_message
      CHANGING
        !failed     TYPE zjl_cl_attach_bo=>tpt_failed
        !reported   TYPE zjl_cl_attach_bo=>tpt_reported .

  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-DATA or_instance TYPE REF TO zjl_cl_attach_bo .
    CLASS-DATA or_badi     TYPE REF TO zjl_bd_attach .

    METHODS _check
      IMPORTING
        !is_entity        TYPE tp_entity
        !i_change_mode    TYPE c
      CHANGING
        !ct_message       TYPE zjl_if_rap=>tpt_message
      RETURNING
        VALUE(r_is_valid) TYPE abap_bool .

    METHODS _determine
      IMPORTING
        !i_change_mode TYPE c
      CHANGING
        !cs_entity     TYPE tp_entity .

    METHODS _map_to_int
      IMPORTING
                !is_entity     TYPE tp_entity
                !i_action_mode TYPE c
      RETURNING VALUE(rs_int)  TYPE zjl_cl_attach_da=>tp_int .

    METHODS _map_to_entity
      IMPORTING
                !is_db           TYPE zjl_cl_attach_da=>tp_db
      RETURNING VALUE(rs_entity) TYPE tp_entity .

    METHODS get_badi RETURNING VALUE(rr_badi) TYPE REF TO zjl_bd_attach.

ENDCLASS.



CLASS zjl_cl_attach_bo IMPLEMENTATION.


  METHOD get_instance.

    or_instance = COND #( WHEN or_instance IS BOUND THEN or_instance ELSE NEW #( ) ).

    rr_instance = or_instance.

  ENDMETHOD.


  METHOD default_for_create.

    DATA: l_date TYPE c LENGTH 10.

    WRITE sy-datum DD/MM/YYYY TO l_date.

    CONCATENATE 'Upload vom'(001) l_date INTO rs_entity-filedescr SEPARATED BY space.

    get_badi( )->imp->default_for_create( CHANGING cs_entity = rs_entity ).

  ENDMETHOD.


  METHOD create.

    DATA: lt_int       TYPE zjl_cl_attach_da=>tpt_int.
    DATA: ls_db        TYPE zjl_cl_attach_da=>tp_db.
    DATA: ls_entity_in TYPE zjl_cl_attach_bo=>tp_entity.

    CLEAR es_entity.
    CLEAR et_message.

    ls_entity_in = is_entity.

    IF _check( EXPORTING is_entity     = ls_entity_in
                         i_change_mode = zjl_if_rap=>co_modstat_create
               CHANGING  ct_message    = et_message ) EQ abap_false.
      RETURN.
    ENDIF.

    _determine( EXPORTING i_change_mode = zjl_if_rap=>co_modstat_create
                CHANGING  cs_entity      = ls_entity_in ).

    APPEND _map_to_int( is_entity     = ls_entity_in
                        i_action_mode = zjl_if_rap=>co_modstat_create ) TO lt_int.

    zjl_cl_attach_da=>get_instance( )->cud_prepare( EXPORTING it_int     = lt_int
                                                    IMPORTING et_db      = DATA(lt_db)
                                                              et_message = et_message ).

    IF et_message IS INITIAL.
      ASSERT lines( lt_db ) = 1.
      ls_db = lt_db[ 1 ].
    ENDIF.

    DATA(ls_entity) = _map_to_entity( is_db    = ls_db ).

    IF et_message IS INITIAL.
      zjl_cl_attach_da=>get_instance( )->cud_copy( ).
    ELSE.
      zjl_cl_attach_da=>get_instance( )->cud_discard( ).
    ENDIF.

    es_entity = ls_entity.

  ENDMETHOD.


  METHOD read.

    DATA: ls_db  TYPE zjl_cl_attach_da=>tp_db.

    CLEAR: et_message.
    CLEAR: es_entity.

    IF i_taskid IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'TASKID' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF i_versno IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'VERSNO' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF i_atacno IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'ATACNO' ) ) TO et_message.
      RETURN.
    ENDIF.

    zjl_cl_attach_da=>get_instance( )->read(  EXPORTING it_db            = VALUE #( ( task_id = i_taskid vers_no = i_versno atac_no = i_atacno ) )
                                                        i_include_buffer = i_include_buffer
                                               IMPORTING et_db           = DATA(lt_db) ).

    IF lt_db IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '003' ) ) TO et_message.
      RETURN.
    ENDIF.

    ASSERT lines( lt_db ) = 1.
    ls_db = lt_db[ 1 ].

    DATA(ls_entity_in) = _map_to_entity( is_db    = ls_db ).

    IF _check( EXPORTING is_entity     = ls_entity_in
                         i_change_mode = zjl_if_rap=>co_modstat_read
               CHANGING  ct_message    = et_message ) EQ abap_false.
      RETURN.
    ENDIF.

    _determine( EXPORTING i_change_mode = zjl_if_rap=>co_modstat_read
                CHANGING  cs_entity     = ls_entity_in ).

    es_entity = ls_entity_in.

  ENDMETHOD.


  METHOD read_by_assoc.

    CLEAR: et_message.
    CLEAR: et_entity.

    IF i_taskid IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'TASKID' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF i_versno IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'VERSNO' ) ) TO et_message.
      RETURN.
    ENDIF.

    zjl_cl_attach_da=>get_instance( )->read_by_assoc(
     EXPORTING it_db            = VALUE #( ( task_id = i_taskid vers_no = i_versno  ) )
               i_include_buffer = i_include_buffer
     IMPORTING et_db            = DATA(lt_db) ).

    IF lt_db IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '003' ) ) TO et_message.
      RETURN.
    ENDIF.

    LOOP AT lt_db ASSIGNING FIELD-SYMBOL(<ls_db>).
      APPEND _map_to_entity( EXPORTING is_db     = <ls_db> ) TO et_entity.

    ENDLOOP.

  ENDMETHOD.


  METHOD update.

    DATA: lt_int       TYPE zjl_cl_attach_da=>tpt_int.
    DATA: ls_db        TYPE zjl_cl_attach_da=>tp_db.
    DATA: ls_entity_in TYPE zjl_cl_attach_bo=>tp_entity.

    CLEAR es_entity.
    CLEAR et_message.

    IF is_entity-taskid IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'TASKID' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF is_entity-versno IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'VERSNO' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF is_entity-atacno IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'ATACNO' ) ) TO et_message.
      RETURN.
    ENDIF.

    ls_entity_in = is_entity.

    IF _check( EXPORTING is_entity     = ls_entity_in
                         i_change_mode = zjl_if_rap=>co_modstat_update
               CHANGING  ct_message    = et_message ) EQ abap_false.
      RETURN.
    ENDIF.

    _determine( EXPORTING i_change_mode = zjl_if_rap=>co_modstat_update
                CHANGING  cs_entity     = ls_entity_in ).

    APPEND _map_to_int( is_entity     = ls_entity_in
                       i_action_mode = zjl_if_rap=>co_modstat_update ) TO lt_int.

    zjl_cl_attach_da=>get_instance( )->cud_prepare( EXPORTING it_int     = lt_int
                                                    IMPORTING et_db      = DATA(lt_db)
                                                              et_message = et_message ).

    IF et_message IS INITIAL.
      ASSERT lines( lt_db ) = 1.
      ls_db = lt_db[ 1 ].
    ENDIF.

    DATA(ls_entity) = _map_to_entity( is_db    = ls_db ).

    IF et_message IS INITIAL.
      zjl_cl_attach_da=>get_instance( )->cud_copy( ).
    ELSE.
      zjl_cl_attach_da=>get_instance( )->cud_discard( ).
    ENDIF.

    es_entity = ls_entity.

  ENDMETHOD.


  METHOD delete.

    DATA: lt_int       TYPE zjl_cl_attach_da=>tpt_int.
    DATA: ls_entity_in TYPE zjl_cl_attach_bo=>tp_entity.

    CLEAR et_message.

    APPEND _map_to_int( is_entity     = VALUE #( taskid = i_taskid versno = i_versno atacno = i_atacno )
                       i_action_mode = zjl_if_rap=>co_modstat_delete ) TO lt_int.

    ls_entity_in = VALUE #( taskid = i_taskid versno = i_versno atacno = i_atacno ).

    IF _check( EXPORTING is_entity     = ls_entity_in
                         i_change_mode = zjl_if_rap=>co_modstat_delete
               CHANGING  ct_message    = et_message ) EQ abap_false.
      RETURN.
    ENDIF.

    zjl_cl_attach_da=>get_instance( )->cud_prepare( EXPORTING it_int     = lt_int
                                                    IMPORTING et_db      = DATA(lt_db) ##needed
                                                              et_message = et_message ).

    IF et_message IS INITIAL.
      zjl_cl_attach_da=>get_instance( )->cud_copy( ).
    ELSE.
      zjl_cl_attach_da=>get_instance( )->cud_discard( ).
    ENDIF.

  ENDMETHOD.

  METHOD _map_to_entity.

    rs_entity-taskid = is_db-task_id.
    rs_entity-versno = is_db-vers_no.
    rs_entity-atacno = is_db-atac_no.
    rs_entity-createusercd = is_db-create_user_cd.
    rs_entity-createts = is_db-create_ts.
    rs_entity-changeusercd = is_db-change_user_cd.
    rs_entity-changets = is_db-change_ts.
    rs_entity-mimetype = is_db-mimetype.
    rs_entity-filename = is_db-filename.
    rs_entity-filedescr = is_db-file_descr.
    rs_entity-attachment = is_db-attachment.

    get_badi( )->imp->map_to_entity( EXPORTING is_db     = is_db
                                     CHANGING  cs_entity = rs_entity ).

  ENDMETHOD.

  METHOD _map_to_int.

    DATA: ls_db TYPE zjl_cl_attach_da=>tp_db.

    ls_db-task_id = is_entity-taskid.
    ls_db-vers_no = is_entity-versno.
    ls_db-atac_no = is_entity-atacno.
    ls_db-create_user_cd = is_entity-createusercd.
    ls_db-create_ts = is_entity-createts.
    ls_db-change_user_cd = is_entity-changeusercd.
    ls_db-change_ts = is_entity-changets.
    ls_db-mimetype = is_entity-mimetype.
    ls_db-filename = is_entity-filename.
    ls_db-file_descr = is_entity-filedescr.
    ls_db-attachment = is_entity-attachment.

    get_badi( )->imp->map_to_db( EXPORTING is_entity = is_entity
                                 CHANGING  cs_db     = ls_db ).

    MOVE-CORRESPONDING ls_db TO rs_int.

    rs_int-action_code = i_action_mode.

  ENDMETHOD.


  METHOD handle_messages.

    DATA: lr_struc       TYPE REF TO data.
    DATA: lr_struc_descr TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS: <l_field> TYPE any.

    LOOP AT it_message INTO DATA(ls_message).

      APPEND VALUE #( %cid   = i_cid
                      taskid = i_taskid
                      versno = i_versno
                      atacno = i_atacno ) TO failed.

      APPEND INITIAL LINE TO reported ASSIGNING FIELD-SYMBOL(<ls_reported>).
      <ls_reported>-%msg        = ls_message.
      <ls_reported>-%key-taskid = i_taskid.
      <ls_reported>-%key-versno = i_versno.
      <ls_reported>-%key-atacno = i_atacno.
      <ls_reported>-%cid        = i_cid.
      <ls_reported>-taskid      = i_taskid.
      <ls_reported>-versno      = i_versno.

      IF NOT ls_message->o_uifield IS INITIAL.
        CLEAR: lr_struc, lr_struc_descr.
        CREATE DATA lr_struc LIKE <ls_reported>-%element. " <- any type
        lr_struc_descr ?= cl_abap_structdescr=>describe_by_data_ref( p_data_ref = lr_struc ).
        LOOP AT lr_struc_descr->components ASSIGNING FIELD-SYMBOL(<l_component>).
          IF <l_component>-name EQ ls_message->o_uifield.
            ASSIGN COMPONENT <l_component>-name OF STRUCTURE <ls_reported>-%element TO <l_field>.
            IF <l_field> IS ASSIGNED.
              <l_field> = if_abap_behv=>mk-on.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD _check.

    r_is_valid = abap_true.

    get_badi( )->imp->check( EXPORTING is_entity     = is_entity
                                       i_change_mode = i_change_mode
                             IMPORTING et_message    = DATA(lt_message)
                             CHANGING  c_is_valid    = r_is_valid ).

    APPEND LINES OF lt_message TO ct_message.

  ENDMETHOD.

  METHOD _determine.

    get_badi( )->imp->determine( EXPORTING i_change_mode = i_change_mode
                                 CHANGING  cs_entity     = cs_entity ).

  ENDMETHOD.

  METHOD get_badi.

    IF or_badi IS BOUND.
      rr_badi = or_badi.
      RETURN.
    ENDIF.

    or_badi = CAST zjl_bd_attach(  zjl_cl_rap_tool=>get_badi( EXPORTING i_badi_name = 'ZJL_BD_ATTACH' ) ).

    rr_badi = or_badi.

  ENDMETHOD.

ENDCLASS.
