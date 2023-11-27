CLASS zjl_cl_task_bo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS co_feature_refuse TYPE zjl_feature VALUE 'Refuse' ##NO_TEXT.
    CONSTANTS co_feature_assign TYPE zjl_feature VALUE 'Assign' ##NO_TEXT.
    CONSTANTS co_feature_complete TYPE zjl_feature VALUE 'Complete' ##NO_TEXT.
    CONSTANTS co_feature_forward TYPE zjl_feature VALUE 'Forward' ##NO_TEXT.
    CONSTANTS co_feature_assoc_attach TYPE zjl_feature VALUE 'Attachment' ##NO_TEXT.
    CONSTANTS co_status_inchange TYPE zjl_status VALUE '00001' ##NO_TEXT.
    CONSTANTS co_status_released TYPE zjl_status VALUE '00006' ##NO_TEXT.

    TYPES: tp_entity  TYPE zjl_o_d_task .
    TYPES: tpt_entity TYPE STANDARD TABLE OF zjl_o_d_task .

    TYPES:
      tpt_failed   TYPE TABLE FOR FAILED   zjl_o_d_task .
    TYPES:
      tpt_mapped   TYPE TABLE FOR MAPPED   zjl_o_d_task .
    TYPES:
      tpt_reported TYPE TABLE FOR REPORTED zjl_o_d_task .

    CLASS-METHODS get_instance
      RETURNING
        VALUE(rr_instance) TYPE REF TO zjl_cl_task_bo .

    METHODS default_for_create
      RETURNING
        VALUE(rs_entity) TYPE tp_entity.

    METHODS precheck_create
      IMPORTING
        !is_entity        TYPE tp_entity
      RETURNING
        VALUE(rt_message) TYPE zjl_if_rap=>tpt_message .

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
        !i_include_buffer TYPE abap_boolean DEFAULT 'X'
      EXPORTING
        !es_entity        TYPE tp_entity
        !et_message       TYPE zjl_if_rap=>tpt_message .

    METHODS precheck_update
      IMPORTING
        !is_entity        TYPE tp_entity
      RETURNING
        VALUE(rt_message) TYPE zjl_if_rap=>tpt_message .

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
      EXPORTING
        !et_message TYPE zjl_if_rap=>tpt_message .

    METHODS facact_complete
      IMPORTING
        !i_taskid   TYPE zjl_id
        !i_versno   TYPE zjl_version
      EXPORTING
        !et_entity  TYPE tpt_entity
        !et_message TYPE zjl_if_rap=>tpt_message .

    METHODS facact_refuse
      IMPORTING
        !i_taskid   TYPE zjl_id
        !i_versno   TYPE zjl_version
      EXPORTING
        !et_entity  TYPE tpt_entity
        !et_message TYPE zjl_if_rap=>tpt_message .

    METHODS facact_forward
      IMPORTING
        !i_taskid          TYPE zjl_id
        !i_versno          TYPE zjl_version
        i_recipientcd      TYPE syuname
        i_recipientgroupcd TYPE zjl_group
      EXPORTING
        !et_entity         TYPE tpt_entity
        !et_message        TYPE zjl_if_rap=>tpt_message .

    METHODS facact_assign
      IMPORTING
        !i_taskid       TYPE zjl_id
        !i_versno       TYPE zjl_version
        i_businessobjcd TYPE zjl_bo
        i_businessobjid TYPE zjl_id
      EXPORTING
        !et_entity      TYPE tpt_entity
        !et_message     TYPE zjl_if_rap=>tpt_message .

    METHODS get_instance_features
      IMPORTING
        !i_taskid     TYPE zjl_id
        !i_versno     TYPE zjl_version
        !i_feature    TYPE zjl_feature
      RETURNING
        VALUE(r_flag) TYPE zjl_enable .

    METHODS get_instance_authorizations
      IMPORTING
        !i_taskid     TYPE zjl_id
        !i_versno     TYPE zjl_version
        !i_feature    TYPE zjl_feature
      RETURNING
        VALUE(r_flag) TYPE zjl_enable .

    METHODS get_global_features
      IMPORTING
        !i_feature    TYPE zjl_feature
      RETURNING
        VALUE(r_flag) TYPE zjl_enable .

    METHODS lock
      IMPORTING
        !i_taskid   TYPE zjl_id
      EXPORTING
        !et_message TYPE zjl_if_rap=>tpt_message .

    CLASS-METHODS handle_messages
      IMPORTING
        !i_cid      TYPE string OPTIONAL
        !i_taskid   TYPE zjl_id OPTIONAL
        !i_versno   TYPE zjl_version OPTIONAL
        !it_message TYPE zjl_if_rap=>tpt_message
      CHANGING
        !failed     TYPE tpt_failed
        !reported   TYPE tpt_reported .

  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-DATA or_instance TYPE REF TO zjl_cl_task_bo .
    CLASS-DATA or_badi     TYPE REF TO zjl_bd_task .

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
      RETURNING VALUE(rs_int)  TYPE zjl_cl_task_da=>tp_int .

    METHODS _map_to_entity
      IMPORTING
                !is_db           TYPE zjl_cl_task_da=>tp_db
      RETURNING VALUE(rs_entity) TYPE tp_entity .

    METHODS get_badi RETURNING VALUE(rr_badi) TYPE REF TO zjl_bd_task.

ENDCLASS.

CLASS zjl_cl_task_bo IMPLEMENTATION.

  METHOD get_instance.

    or_instance = COND #( WHEN or_instance IS BOUND THEN or_instance ELSE NEW #( ) ).

    rr_instance = or_instance.

  ENDMETHOD.

  METHOD get_badi.

    IF or_badi IS BOUND.
      rr_badi = or_badi.
      RETURN.
    ENDIF.

    or_badi = CAST zjl_bd_task(  zjl_cl_rap_tool=>get_badi( EXPORTING i_badi_name = 'ZJL_BD_TASK' ) ).

    rr_badi = or_badi.

  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA: ls_entity TYPE tp_entity.

    r_flag = zjl_if_rap=>co_feature_disabled.

    CASE i_feature.
      WHEN zjl_if_rap=>co_feature_update.
        IF ls_entity-completedfl IS INITIAL.
          r_flag = zjl_if_rap=>co_feature_enabled.
        ENDIF.

      WHEN zjl_if_rap=>co_feature_delete.
        r_flag = zjl_if_rap=>co_feature_enabled.

      WHEN co_feature_assoc_attach.
        r_flag = zjl_if_rap=>co_feature_enabled.

      WHEN co_feature_forward.
        r_flag = zjl_if_rap=>co_feature_enabled.

      WHEN co_feature_refuse.
        r_flag = zjl_if_rap=>co_feature_enabled.

      WHEN co_feature_assign.
        r_flag = zjl_if_rap=>co_feature_enabled.

      WHEN co_feature_complete.
        r_flag = zjl_if_rap=>co_feature_enabled.

    ENDCASE.

    get_badi( )->imp->get_instance_authorizations( EXPORTING i_taskid  = i_taskid
                                                             i_versno  = i_versno
                                                             i_feature = i_feature
                                                   CHANGING  c_flag    = r_flag ).

  ENDMETHOD.

  METHOD get_instance_features.

    DATA: ls_entity TYPE tp_entity.

    zjl_cl_task_da=>get_instance( )->read(  EXPORTING it_db  = VALUE #( ( task_id = i_taskid vers_no = i_versno ) )
                                            IMPORTING et_db  = DATA(lt_db) ).

    ASSERT lines( lt_db ) = 1.

    DATA(ls_db) = lt_db[ 1 ].

    ls_entity =  _map_to_entity( EXPORTING is_db = ls_db ).

    r_flag = zjl_if_rap=>co_feature_disabled.

    CASE i_feature.
      WHEN zjl_if_rap=>co_feature_update.
        IF ls_entity-completedfl IS INITIAL.
          r_flag = zjl_if_rap=>co_feature_enabled.
        ENDIF.

      WHEN zjl_if_rap=>co_feature_delete.
        IF  ls_entity-statuscd NE co_status_released
        AND ls_entity-versno   EQ 1.
          r_flag = zjl_if_rap=>co_feature_enabled.
        ENDIF.

      WHEN co_feature_assoc_attach.
        IF  ls_entity-statuscd NE co_status_released.
          r_flag = zjl_if_rap=>co_feature_enabled.
        ENDIF.

      WHEN co_feature_forward.
        IF  ls_entity-statuscd    NE co_status_released.
          r_flag = zjl_if_rap=>co_feature_enabled.
        ENDIF.

      WHEN co_feature_refuse.
        IF  ls_entity-statuscd NE co_status_released
        AND ls_entity-versno   GT 1.
          r_flag = zjl_if_rap=>co_feature_enabled.
        ENDIF.

      WHEN co_feature_assign.
        IF  ls_entity-statuscd NE co_status_released.
          r_flag = zjl_if_rap=>co_feature_enabled.
        ENDIF.

      WHEN co_feature_complete.
        IF  ls_entity-statuscd    NE co_status_released
        AND ls_entity-completedfl IS INITIAL.
          r_flag = zjl_if_rap=>co_feature_enabled.
        ENDIF.

    ENDCASE.

    get_badi( )->imp->get_instance_features( EXPORTING i_taskid  = i_taskid
                                                       i_versno  = i_versno
                                                       i_feature = i_feature
                                             CHANGING  c_flag    = r_flag ).

  ENDMETHOD.

  METHOD get_global_features.

    r_flag = zjl_if_rap=>co_feature_disabled.

    CASE i_feature.
      WHEN zjl_if_rap=>co_feature_create.
        r_flag = zjl_if_rap=>co_feature_enabled.

    ENDCASE.

    get_badi( )->imp->get_global_features( EXPORTING i_feature = i_feature
                                           CHANGING  c_flag    = r_flag ).

  ENDMETHOD.

  METHOD create.

    DATA: lt_int       TYPE zjl_cl_task_da=>tpt_int.
    DATA: ls_db        TYPE zjl_cl_task_da=>tp_db.
    DATA: ls_entity_in TYPE zjl_cl_task_bo=>tp_entity.

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

    APPEND _map_to_int( is_entity    = ls_entity_in
                       i_action_mode = zjl_if_rap=>co_modstat_create ) TO lt_int.

    zjl_cl_task_da=>get_instance( )->cud_prepare( EXPORTING it_int     = lt_int
                                                  IMPORTING et_db      = DATA(lt_db)
                                                            et_message = et_message ).

    IF et_message IS INITIAL.
      ASSERT lines( lt_db ) = 1.
      ls_db = lt_db[ 1 ].
    ENDIF.

    DATA(ls_entity_out) = _map_to_entity( is_db    = ls_db ).

    IF et_message IS INITIAL.
      zjl_cl_task_da=>get_instance( )->cud_copy( ).
    ELSE.
      zjl_cl_task_da=>get_instance( )->cud_discard( ).
    ENDIF.

    es_entity = ls_entity_out.

  ENDMETHOD.

  METHOD delete.

    DATA: lt_int       TYPE zjl_cl_task_da=>tpt_int.
    DATA: ls_db        TYPE zjl_cl_task_da=>tp_db.
    DATA: ls_entity_in TYPE zjl_cl_task_bo=>tp_entity.

    CLEAR et_message.

    APPEND _map_to_int( is_entity     = VALUE #( taskid = i_taskid versno = i_versno )
                       i_action_mode = zjl_if_rap=>co_modstat_delete ) TO lt_int.

    ls_entity_in = VALUE #( taskid = i_taskid versno = i_versno ).

    IF _check( EXPORTING is_entity     = ls_entity_in
                         i_change_mode = zjl_if_rap=>co_modstat_delete
               CHANGING  ct_message    = et_message ) EQ abap_false.
      RETURN.
    ENDIF.

    zjl_cl_task_da=>get_instance( )->cud_prepare( EXPORTING it_int     = lt_int
                                                  IMPORTING et_db      = DATA(lt_db)
                                                            et_message = et_message ).

    IF et_message IS INITIAL.
      zjl_cl_task_da=>get_instance( )->cud_copy( ).
    ELSE.
      zjl_cl_task_da=>get_instance( )->cud_discard( ).
    ENDIF.

  ENDMETHOD.

  METHOD read.

    DATA: ls_db  TYPE zjl_cl_task_da=>tp_db.

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

    zjl_cl_task_da=>get_instance( )->read( EXPORTING it_db            = VALUE #( ( task_id = i_taskid vers_no = i_versno ) )
                                                     i_include_buffer = i_include_buffer
                                           IMPORTING et_db            = DATA(lt_db) ).

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

  METHOD update.

    DATA: lt_int TYPE zjl_cl_task_da=>tpt_int.
    DATA: ls_db  TYPE zjl_cl_task_da=>tp_db.
    DATA: ls_entity_in TYPE zjl_cl_task_bo=>tp_entity.

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

    ls_entity_in = is_entity.

    IF _check( EXPORTING is_entity     = ls_entity_in
                         i_change_mode = zjl_if_rap=>co_modstat_update
               CHANGING  ct_message    = et_message ) EQ abap_false.
      RETURN.
    ENDIF.

    _determine( EXPORTING i_change_mode = zjl_if_rap=>co_modstat_update
                CHANGING  cs_entity     = ls_entity_in ).

    APPEND _map_to_int( is_entity    = ls_entity_in
                       i_action_mode = zjl_if_rap=>co_modstat_update ) TO lt_int.

    zjl_cl_task_da=>get_instance( )->cud_prepare( EXPORTING it_int     = lt_int
                                                  IMPORTING et_db      = DATA(lt_db)
                                                            et_message = et_message ).

    IF et_message IS INITIAL.
      ASSERT lines( lt_db ) = 1.
      ls_db = lt_db[ 1 ].
    ENDIF.

    DATA(ls_entity_out) = _map_to_entity( is_db    = ls_db ).

    IF et_message IS INITIAL.
      zjl_cl_task_da=>get_instance( )->cud_copy( ).
    ELSE.
      zjl_cl_task_da=>get_instance( )->cud_discard( ).
    ENDIF.

    es_entity = ls_entity_out.

  ENDMETHOD.

  METHOD default_for_create.

    DATA: l_date TYPE c LENGTH 10.

    WRITE sy-datum DD/MM/YYYY TO l_date.

    rs_entity-resubmissdt = sy-datum.
    rs_entity-targetdt    = sy-datum.
    rs_entity-note        = space.

    CONCATENATE 'Aufgabe vom' l_date INTO rs_entity-descr SEPARATED BY space.

    get_badi( )->imp->default_for_create( CHANGING cs_entity = rs_entity ).

  ENDMETHOD.

  METHOD precheck_create.

* Technische Prüfung "Vorgang"
    IF is_entity-processcd IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '008' attr1 = 'Geschäftsprozeß' )
                                  uifield = 'PROCESSCD' ) TO rt_message.
      RETURN.
    ELSE.
      SELECT SINGLE * FROM zjl_b_v_process WHERE code EQ @is_entity-processcd INTO @DATA(ls_dummy) ##needed.
      IF NOT sy-subrc IS INITIAL.
        APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '009' attr1 = 'Vorgang' )
                                    uifield = 'PROCESSCD' ) TO rt_message.
        RETURN.
      ENDIF.
    ENDIF.

* Technische Prüfung "Wiedervorlagedatum"
    IF is_entity-resubmissdt IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '008' attr1 = 'Wiedervorlagedatum' )
                                  uifield = 'RESUBMISSDT' ) TO rt_message.
      RETURN.
    ENDIF.

* Technische Prüfung "Zieldatum"
    IF is_entity-targetdt IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '008' attr1 = 'Zieldatum' )
                                  uifield = 'TARGETDT' ) TO rt_message.
      RETURN.
    ENDIF.

* Technische Prüfung "Beschreibung"
    IF is_entity-descr IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '008' attr1 = 'Vorgang' )
                                  uifield = 'DESCR' ) TO rt_message.
      RETURN.
    ENDIF.

*Fachliche Prüfung 1
    IF is_entity-resubmissdt LT cl_abap_context_info=>get_system_date( ).
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = 'ZJL_TASK' msgno = '001' attr1 = 'Wiedervorlagedatum' )
                                  uifield = 'RESUBMISSDT' ) TO rt_message.
      RETURN.
    ENDIF.

*Fachliche Prüfung 2
    IF is_entity-targetdt LT cl_abap_context_info=>get_system_date( ).
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = 'ZJL_TASK' msgno = '001' attr1 = 'Zieldatum' )
                                  uifield = 'TARGETDT' ) TO rt_message.
      RETURN.
    ENDIF.

*Fachliche Prüfung 3
    IF is_entity-targetdt LT is_entity-resubmissdt.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = 'ZJL_TASK' msgno = '002' )
                                  uifield = 'TARGETDT' ) TO rt_message.
      RETURN.
    ENDIF.

    get_badi( )->imp->precheck_create( EXPORTING is_entity  = is_entity
                                       IMPORTING et_message = DATA(lt_message) ).

    APPEND LINES OF lt_message TO rt_message.

  ENDMETHOD.

  METHOD precheck_update.

* Technische Prüfung "Vorgang"
    IF is_entity-processcd IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '008' attr1 = 'Geschäftsprozeß' )
                                  uifield = 'PROCESSCD' ) TO rt_message.
      RETURN.
    ELSE.
      SELECT SINGLE * FROM zjl_b_v_process WHERE code EQ @is_entity-processcd INTO @DATA(ls_dummy) ##needed.
      IF NOT sy-subrc IS INITIAL.
        APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '009' attr1 = 'Vorgang' )
                                    uifield = 'PROCESSCD' ) TO rt_message.
        RETURN.
      ENDIF.
    ENDIF.

* Technische Prüfung "Wiedervorlagedatum"
    IF is_entity-resubmissdt IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '008' attr1 = 'Wiedervorlagedatum' )
                                  uifield = 'RESUBMISSDT' ) TO rt_message.
      RETURN.
    ENDIF.

* Technische Prüfung "Zieldatum"
    IF is_entity-targetdt IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '008' attr1 = 'Zieldatum' )
                                  uifield = 'TARGETDT' ) TO rt_message.
      RETURN.
    ENDIF.

* Technische Prüfung "Beschreibung"
    IF is_entity-descr IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '008' attr1 = 'Vorgang' )
                                  uifield = 'DESCR' ) TO rt_message.
      RETURN.
    ENDIF.

*Fachliche Prüfung 1
    IF is_entity-resubmissdt LT cl_abap_context_info=>get_system_date( ).
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = 'ZJL_TASK' msgno = '001' attr1 = 'Wiedervorlagedatum' )
                                  uifield = 'RESUBMISSDT' ) TO rt_message.
      RETURN.
    ENDIF.

*Fachliche Prüfung 2
    IF is_entity-targetdt LT cl_abap_context_info=>get_system_date( ).
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = 'ZJL_TASK' msgno = '001' attr1 = 'Zieldatum' )
                                  uifield = 'TARGETDT' ) TO rt_message.
      RETURN.
    ENDIF.

*Fachliche Prüfung 3
    IF is_entity-targetdt LT is_entity-resubmissdt.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = 'ZJL_TASK' msgno = '002' )
                                  uifield = 'TARGETDT' ) TO rt_message.
      RETURN.
    ENDIF.

    get_badi( )->imp->precheck_update( EXPORTING is_entity  = is_entity
                                       IMPORTING et_message = DATA(lt_message) ).

    APPEND LINES OF lt_message TO rt_message.

  ENDMETHOD.

  METHOD facact_complete.

    CLEAR et_entity.
    CLEAR et_message.

    IF i_taskid IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'TASKID' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF i_versno IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'VERSNO' ) ) TO et_message.
      RETURN.
    ENDIF.

    zjl_cl_task_da=>get_instance( )->read( EXPORTING it_db            = VALUE #( ( task_id = i_taskid vers_no = i_versno ) )
                                                     i_include_buffer = abap_true
                                           IMPORTING et_db            = DATA(lt_db) ).


    ASSERT lines( lt_db ) = 1.
    DATA(ls_db) = lt_db[ 1 ].

    DATA(ls_entity) = _map_to_entity( ls_db ).

    ls_entity-verstodt       = cl_abap_context_info=>get_system_date( ).
    ls_entity-versinactivefl = space.
    ls_entity-versetagts     = utclong_current( ).
    ls_entity-statuscd       = co_status_released.
    ls_entity-releaseusercd  = cl_abap_context_info=>get_user_technical_name( ).
    ls_entity-releasets      = utclong_current( ).
    ls_entity-completedfl    = 'X'.

    update( EXPORTING is_entity  = ls_entity
            IMPORTING es_entity  = DATA(ls_entity_old_return)
                      et_message = et_message ).

    IF NOT et_message IS INITIAL.
      RETURN.
    ENDIF.

    APPEND ls_entity TO et_entity.

  ENDMETHOD.

  METHOD facact_refuse.

    CLEAR et_entity.
    CLEAR et_message.

    IF i_taskid IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'TASKID' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF i_versno IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'VERSNO' ) ) TO et_message.
      RETURN.
    ENDIF.

    zjl_cl_task_da=>get_instance( )->read( EXPORTING it_db            = VALUE #( ( task_id = i_taskid vers_no = i_versno ) )
                                                     i_include_buffer = abap_true
                                           IMPORTING et_db            = DATA(lt_db) ).

    ASSERT lines( lt_db ) = 1.
    DATA(ls_db) = lt_db[ 1 ].

    zjl_cl_task_da=>get_instance( )->read( EXPORTING it_db            = VALUE #( ( task_id = ls_db-task_id vers_no = ls_db-vers_origin_no ) )
                                                     i_include_buffer = abap_true
                                           IMPORTING et_db            = DATA(lt_db_ori) ).

    ASSERT lines( lt_db_ori ) = 1.
    DATA(ls_db_ori) = lt_db_ori[ 1 ].

    DATA(ls_entity_ori) = _map_to_entity( ls_db_ori ).
    DATA(ls_entity_old) = _map_to_entity( ls_db ).
    DATA(ls_entity_new) = ls_entity_old.

    ls_entity_old-verstodt       = cl_abap_context_info=>get_system_date( ).
    ls_entity_old-versinactivefl = space.
    ls_entity_old-versetagts     = utclong_current( ).
    ls_entity_old-statuscd       = co_status_released.
    ls_entity_old-releaseusercd  = cl_abap_context_info=>get_user_technical_name( ).
    ls_entity_old-releasets      = utclong_current( ).

    update( EXPORTING is_entity  = ls_entity_old
            IMPORTING es_entity  = DATA(ls_entity_old_return)
                      et_message = et_message ).

    IF NOT et_message IS INITIAL.
      RETURN.
    ENDIF.

    ls_entity_new-versno         = zjl_cl_task_da=>get_instance( )->get_next_vers_no( i_taskid = ls_entity_new-taskid ).
    ls_entity_new-versfromdt     = cl_abap_context_info=>get_system_date( ).
    ls_entity_new-verstodt       = '99991231'.
    ls_entity_new-versinactivefl = space.
    ls_entity_new-versetagts     = utclong_current( ).
    ls_entity_new-versoriginno   = ls_entity_old-versno.
    ls_entity_new-statuscd       = co_status_inchange.
    ls_entity_new-createusercd   = cl_abap_context_info=>get_user_technical_name( ).
    ls_entity_new-createts       = utclong_current( ).
    ls_entity_new-recipientcd      = ls_entity_ori-recipientcd.
    ls_entity_new-recipientgroupcd = ls_entity_ori-recipientgroupcd.

    create( EXPORTING is_entity  = ls_entity_new
            IMPORTING es_entity  = DATA(ls_entity_new_return)
                      et_message = et_message ).

    IF NOT et_message IS INITIAL.
      RETURN.
    ENDIF.

    APPEND ls_entity_new_return TO et_entity.

  ENDMETHOD.

  METHOD facact_forward.

    CLEAR et_entity.
    CLEAR et_message.

    IF i_taskid IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'TASKID' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF i_versno IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'VERSNO' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF  i_recipientcd      IS INITIAL
    AND i_recipientgroupcd IS INITIAL .
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = 'ZJL_TASK' msgno = '003'  ) ) TO et_message.
      RETURN.
    ENDIF.

    IF  NOT i_recipientcd      IS INITIAL
    AND NOT i_recipientgroupcd IS INITIAL .
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = 'ZJL_TASK' msgno = '003'  ) ) TO et_message.
      RETURN.
    ENDIF.

    IF NOT i_recipientgroupcd IS INITIAL .
      SELECT SINGLE code INTO @DATA(l_code_1) FROM zjl_b_v_group WHERE code EQ @i_recipientgroupcd.
      IF NOT sy-subrc IS INITIAL.
        APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '009' attr1 = 'Empfängergruppe' ) ) TO et_message.
        RETURN.
      ENDIF.
    ENDIF.

    IF NOT i_recipientcd IS INITIAL .
      SELECT SINGLE code INTO @DATA(l_code_2) FROM zjl_b_v_uname WHERE code EQ @i_recipientcd.
      IF NOT sy-subrc IS INITIAL.
        APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '009' attr1 = 'Empfänger' ) ) TO et_message.
        RETURN.
      ENDIF.
    ENDIF.

    zjl_cl_task_da=>get_instance( )->read( EXPORTING it_db            = VALUE #( ( task_id = i_taskid vers_no = i_versno ) )
                                                     i_include_buffer = abap_true
                                           IMPORTING et_db            = DATA(lt_db) ).


    ASSERT lines( lt_db ) = 1.
    DATA(ls_db) = lt_db[ 1 ].

    DATA(ls_entity_old) = _map_to_entity( ls_db ).
    DATA(ls_entity_new) = ls_entity_old.

    ls_entity_old-verstodt       = cl_abap_context_info=>get_system_date( ).
    ls_entity_old-versinactivefl = space.
    ls_entity_old-versetagts     = utclong_current( ).
    ls_entity_old-statuscd       = co_status_released.
    ls_entity_old-releaseusercd  = cl_abap_context_info=>get_user_technical_name( ).
    ls_entity_old-releasets      = utclong_current( ).

    update( EXPORTING is_entity  = ls_entity_old
            IMPORTING es_entity  = DATA(ls_entity_old_return)
                      et_message = et_message ).

    IF NOT et_message IS INITIAL.
      RETURN.
    ENDIF.

    ls_entity_new-versno           = zjl_cl_task_da=>get_instance( )->get_next_vers_no( i_taskid = ls_entity_new-taskid ).
    ls_entity_new-versfromdt       = cl_abap_context_info=>get_system_date( ).
    ls_entity_new-verstodt         = '99991231'.
    ls_entity_new-versinactivefl   = space.
    ls_entity_new-versetagts       = utclong_current( ).
    ls_entity_new-versoriginno     = ls_entity_old-versno.
    ls_entity_new-statuscd         = co_status_inchange.
    ls_entity_new-recipientgroupcd = i_recipientgroupcd.
    ls_entity_new-recipientcd      = i_recipientcd.

    create( EXPORTING is_entity  = ls_entity_new
            IMPORTING es_entity  = DATA(ls_entity_new_return)
                      et_message = et_message ).

    IF NOT et_message IS INITIAL.
      RETURN.
    ENDIF.

    APPEND ls_entity_new_return TO et_entity.

  ENDMETHOD.

  METHOD facact_assign.

    CLEAR et_entity.
    CLEAR et_message.

    IF i_taskid IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'TASKID' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF i_versno IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'VERSNO' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF i_businessobjcd IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '009' attr1 = 'Geschäftsobjekt' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF i_businessobjid IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '009' attr1 = 'Geschäftsobjekt-ID' ) ) TO et_message.
      RETURN.
    ENDIF.

    IF NOT i_businessobjcd IS INITIAL .
      SELECT SINGLE code INTO @DATA(l_code_1) FROM zjl_b_v_bo WHERE code EQ @i_businessobjcd.
      IF NOT sy-subrc IS INITIAL.
        APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '009' attr1 = 'Empfängergruppe' ) ) TO et_message.
        RETURN.
      ENDIF.
    ENDIF.

    zjl_cl_task_da=>get_instance( )->read( EXPORTING it_db            = VALUE #( ( task_id = i_taskid vers_no = i_versno ) )
                                                     i_include_buffer = abap_true
                                           IMPORTING et_db            = DATA(lt_db) ).


    ASSERT lines( lt_db ) = 1.
    DATA(ls_db) = lt_db[ 1 ].

    DATA(ls_entity_old) = _map_to_entity( ls_db ).
    DATA(ls_entity_new) = ls_entity_old.

    ls_entity_old-verstodt       = cl_abap_context_info=>get_system_date( ).
    ls_entity_old-versinactivefl = space.
    ls_entity_old-versetagts     = utclong_current( ).
    ls_entity_old-statuscd       = co_status_released.
    ls_entity_old-releaseusercd  = cl_abap_context_info=>get_user_technical_name( ).
    ls_entity_old-releasets      = utclong_current( ).

    update( EXPORTING is_entity  = ls_entity_old
            IMPORTING es_entity  = DATA(ls_entity_old_return)
                      et_message = et_message ).

    IF NOT et_message IS INITIAL.
      RETURN.
    ENDIF.

    ls_entity_new-versno           = zjl_cl_task_da=>get_instance( )->get_next_vers_no( i_taskid = ls_entity_new-taskid ).
    ls_entity_new-versfromdt       = cl_abap_context_info=>get_system_date( ).
    ls_entity_new-verstodt         = '99991231'.
    ls_entity_new-versinactivefl   = space.
    ls_entity_new-versetagts       = utclong_current( ).
    ls_entity_new-versoriginno     = ls_entity_old-versno.
    ls_entity_new-statuscd         = co_status_inchange.
    ls_entity_new-businessobjcd    = i_businessobjcd.
    ls_entity_new-businessobjid    = i_businessobjid.

    create( EXPORTING is_entity  = ls_entity_new
            IMPORTING es_entity  = DATA(ls_entity_new_return)
                      et_message = et_message ).

    IF NOT et_message IS INITIAL.
      RETURN.
    ENDIF.

    APPEND ls_entity_new_return TO et_entity.

  ENDMETHOD.

  METHOD lock.

    TRY.
        DATA(lr_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = 'EZJL_TAKO' ).

        TRY.
            lr_lock->enqueue( it_parameter = VALUE #( ( name = 'TASK_ID' value = REF #( i_taskid  ) ) ) ).

          CATCH cx_abap_foreign_lock.
            APPEND NEW zjl_cx_behavior(  ) TO et_message.
            RETURN.

        ENDTRY.

      CATCH cx_abap_lock_failure INTO DATA(lx_exp).

        APPEND NEW zjl_cx_behavior( textid = zjl_cx_behavior=>co_err_unknown ) TO et_message.
        RETURN.

    ENDTRY.

  ENDMETHOD.

  METHOD _map_to_entity.

    rs_entity-taskid = is_db-task_id .
    rs_entity-versno = is_db-vers_no .
    rs_entity-versfromdt = is_db-vers_from_dt .
    rs_entity-verstodt = is_db-vers_to_dt .
    rs_entity-versinactivefl = is_db-vers_inactive_fl .
    rs_entity-versetagts = is_db-vers_etag_ts .
    rs_entity-versoriginno = is_db-vers_origin_no .
    rs_entity-createusercd = is_db-create_user_cd .
    rs_entity-createts = is_db-create_ts .
    rs_entity-changeusercd = is_db-change_user_cd .
    rs_entity-changets = is_db-change_ts .
    rs_entity-releaseusercd = is_db-release_user_cd .
    rs_entity-releasets = is_db-release_ts .
    rs_entity-statuscd = is_db-status_cd .
    rs_entity-processcd = is_db-process_cd .
    rs_entity-businessobjcd = is_db-businessobj_cd .
    rs_entity-businessobjid = is_db-businessobj_id .
    rs_entity-recipientcd = is_db-recipient_cd .
    rs_entity-recipientgroupcd = is_db-recipient_group_cd .
    rs_entity-targetdt = is_db-target_dt .
    rs_entity-resubmissdt = is_db-resubmiss_dt .
    rs_entity-completedfl = is_db-completed_fl .
    rs_entity-descr = is_db-descr .
    rs_entity-note = is_db-note .

    get_badi( )->imp->map_to_entity( EXPORTING is_db     = is_db
                                     CHANGING  cs_entity = rs_entity ).

  ENDMETHOD.

  METHOD _map_to_int.

    DATA: ls_db TYPE zjl_cl_task_da=>tp_db.

    ls_db-task_id = is_entity-taskid .
    ls_db-vers_no = is_entity-versno .
    ls_db-vers_from_dt = is_entity-versfromdt .
    ls_db-vers_to_dt = is_entity-verstodt .
    ls_db-vers_inactive_fl = is_entity-versinactivefl .
    ls_db-vers_etag_ts = is_entity-versetagts .
    ls_db-vers_origin_no = is_entity-versoriginno .
    ls_db-create_user_cd = is_entity-createusercd .
    ls_db-create_ts = is_entity-createts .
    ls_db-change_user_cd = is_entity-changeusercd .
    ls_db-change_ts = is_entity-changets .
    ls_db-release_user_cd = is_entity-releaseusercd .
    ls_db-release_ts = is_entity-releasets .
    ls_db-status_cd = is_entity-statuscd .
    ls_db-process_cd = is_entity-processcd .
    ls_db-businessobj_cd = is_entity-businessobjcd .
    ls_db-businessobj_id = is_entity-businessobjid .
    ls_db-recipient_cd = is_entity-recipientcd .
    ls_db-recipient_group_cd = is_entity-recipientgroupcd .
    ls_db-target_dt = is_entity-targetdt .
    ls_db-resubmiss_dt = is_entity-resubmissdt .
    ls_db-completed_fl = is_entity-completedfl .
    ls_db-descr = is_entity-descr .
    ls_db-note = is_entity-note .

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
                      versno = i_versno ) TO failed.

      APPEND INITIAL LINE TO reported ASSIGNING FIELD-SYMBOL(<ls_reported>).
      <ls_reported>-%msg        = ls_message.
      <ls_reported>-%key-taskid = i_taskid.
      <ls_reported>-%key-versno = i_versno.
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

ENDCLASS.
