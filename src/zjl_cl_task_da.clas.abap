CLASS zjl_cl_task_da DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tp_db     TYPE zjl_tako.
    TYPES: tp_db_key TYPE zjl_tako_key_s .    "DB key

    TYPES: BEGIN OF tp_int.
             INCLUDE TYPE tp_db.
    TYPES action_code TYPE c LENGTH 1.
    TYPES: END OF tp_int .

    TYPES:
      tpt_int     TYPE STANDARD TABLE OF tp_int.

    TYPES:
      tpt_db     TYPE SORTED TABLE OF tp_db     WITH UNIQUE KEY task_id vers_no .
    TYPES:
      tpt_db_key TYPE SORTED TABLE OF tp_db_key WITH UNIQUE KEY task_id vers_no .

    CONSTANTS:
      co_db TYPE c LENGTH 20 VALUE 'ZJL_TAKO' ##NO_TEXT.

    CLASS-METHODS get_instance
      RETURNING
        VALUE(rr_instance) TYPE REF TO zjl_cl_task_da .

    METHODS cud_prepare
      IMPORTING
        !it_int            TYPE tpt_int
        !i_no_delete_check TYPE abap_bool OPTIONAL
      EXPORTING
        !et_db             TYPE tpt_db
        !et_message        TYPE zjl_if_rap=>tpt_message .

    METHODS cud_copy .

    METHODS cud_discard .

    METHODS read
      IMPORTING
        !it_db            TYPE tpt_db OPTIONAL
        !i_include_buffer TYPE abap_boolean DEFAULT 'X'
      EXPORTING
        !et_db            TYPE tpt_db .

    METHODS get_next_vers_no
      IMPORTING
                !i_taskid       TYPE zjl_id
      RETURNING VALUE(r_versno) TYPE zjl_version .

    METHODS adjust_numbers
      EXPORTING
        e_task_id  TYPE zjl_id
        e_vers_no  TYPE zjl_version
        et_message TYPE zjl_if_rap=>tpt_message .

    METHODS save .

  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-DATA or_instance TYPE REF TO zjl_cl_task_da .

    DATA ot_buffer_c TYPE tpt_db .
    DATA ot_buffer_u TYPE tpt_db .
    DATA ot_buffer_d TYPE tpt_db_key .
    DATA ot_buffer_c_tmp TYPE tpt_db .
    DATA ot_buffer_u_tmp TYPE tpt_db .
    DATA ot_buffer_d_tmp TYPE tpt_db_key .

    CONSTANTS co_nrobj    TYPE nrobj VALUE 'ZJLTASKID' ##NO_TEXT.
    CONSTANTS co_dummy_id TYPE zjl_id VALUE '999999999999999'.

    METHODS _check
      IMPORTING
        !is_db            TYPE tp_db
        !i_change_mode    TYPE c
      CHANGING
        !ct_message       TYPE zjl_if_rap=>tpt_message
      RETURNING
        VALUE(r_is_valid) TYPE abap_bool.

    METHODS _determine
      IMPORTING
        !i_change_mode TYPE c
      CHANGING
        !cs_db         TYPE tp_db .

    METHODS _create
      IMPORTING
        !it_db      TYPE tpt_db
      EXPORTING
        !et_db      TYPE tpt_db
        !et_message TYPE zjl_if_rap=>tpt_message .

    METHODS _update
      IMPORTING
        !it_db      TYPE tpt_db
      EXPORTING
        !et_db      TYPE tpt_db
        !et_message TYPE zjl_if_rap=>tpt_message .

    METHODS _delete
      IMPORTING
        !it_db             TYPE tpt_db
        !i_no_delete_check TYPE abap_bool
      EXPORTING
        !et_message        TYPE zjl_if_rap=>tpt_message .

ENDCLASS.



CLASS zjl_cl_task_da IMPLEMENTATION.


  METHOD get_instance.

    or_instance = COND #( WHEN or_instance IS BOUND THEN or_instance ELSE NEW #( ) ).

    rr_instance = or_instance.

  ENDMETHOD.

  METHOD cud_copy.

    LOOP AT ot_buffer_c_tmp ASSIGNING FIELD-SYMBOL(<ls_buffer_c_tmp>).
      READ TABLE ot_buffer_c ASSIGNING FIELD-SYMBOL(<ls_buffer_c>) WITH TABLE KEY task_id = <ls_buffer_c_tmp>-task_id
                                                                                  vers_no = <ls_buffer_c_tmp>-vers_no.
      IF NOT sy-subrc IS INITIAL.
        APPEND <ls_buffer_c_tmp> TO ot_buffer_c.
      ELSE.
        MOVE-CORRESPONDING <ls_buffer_c_tmp> TO <ls_buffer_c>.
      ENDIF.
    ENDLOOP.

    LOOP AT ot_buffer_u_tmp ASSIGNING FIELD-SYMBOL(<ls_buffer_u_tmp>).
      READ TABLE ot_buffer_u ASSIGNING FIELD-SYMBOL(<ls_buffer_u>) WITH TABLE KEY task_id = <ls_buffer_u_tmp>-task_id
                                                                                  vers_no = <ls_buffer_u_tmp>-vers_no.
      IF NOT sy-subrc IS INITIAL.
        APPEND <ls_buffer_u_tmp> TO ot_buffer_u.
      ELSE.
        MOVE-CORRESPONDING <ls_buffer_u_tmp> TO <ls_buffer_u>.
      ENDIF.
    ENDLOOP.

    LOOP AT ot_buffer_d_tmp ASSIGNING FIELD-SYMBOL(<ls_buffer_d_tmp>).
      DELETE ot_buffer_c WHERE task_id EQ <ls_buffer_d_tmp>-task_id
                           AND vers_no EQ <ls_buffer_d_tmp>-vers_no.
      IF sy-subrc IS INITIAL.
        CONTINUE.
      ENDIF.
      DELETE ot_buffer_u WHERE task_id EQ <ls_buffer_d_tmp>-task_id
                           AND vers_no EQ <ls_buffer_d_tmp>-vers_no.
      INSERT <ls_buffer_d_tmp> INTO TABLE ot_buffer_d.
    ENDLOOP.

    cud_discard(  ).

  ENDMETHOD.


  METHOD cud_discard.

    CLEAR ot_buffer_c_tmp.
    CLEAR ot_buffer_u_tmp.
    CLEAR ot_buffer_d_tmp.

  ENDMETHOD.


  METHOD cud_prepare.

    DATA lt_db_c TYPE tpt_db.
    DATA lt_db_u TYPE tpt_db.
    DATA lt_db_d TYPE tpt_db.
    DATA ls_db   TYPE tp_db.

    CLEAR et_db.
    CLEAR et_message.

    CHECK it_int IS NOT INITIAL.

    LOOP AT it_int ASSIGNING FIELD-SYMBOL(<ls_int>).

      CASE <ls_int>-action_code.
        WHEN zjl_if_rap=>co_modstat_create.
          MOVE-CORRESPONDING <ls_int> TO ls_db.
          INSERT ls_db INTO TABLE lt_db_c.

        WHEN zjl_if_rap=>co_modstat_update.
          MOVE-CORRESPONDING <ls_int> TO ls_db.
          INSERT ls_db INTO TABLE lt_db_u.

        WHEN zjl_if_rap=>co_modstat_delete.
          MOVE-CORRESPONDING <ls_int> TO ls_db.
          INSERT ls_db INTO TABLE lt_db_d.

      ENDCASE.
    ENDLOOP.

* Update der TMP-Buffer
    _create( EXPORTING it_db  = lt_db_c
             IMPORTING et_db  = et_db
                       et_message = et_message ).

    _update( EXPORTING it_db   = lt_db_u
             IMPORTING et_db   = DATA(lt_db)
                       et_message  = DATA(lt_msg) ).

    INSERT LINES OF lt_db INTO TABLE et_db.
    APPEND LINES OF lt_msg TO et_message.

    _delete( EXPORTING it_db         = lt_db_d
                       i_no_delete_check = i_no_delete_check
             IMPORTING et_message        = lt_msg ).
    APPEND LINES OF lt_msg TO et_message.

  ENDMETHOD.


  METHOD read.

    CLEAR et_db.

    CHECK NOT it_db IS INITIAL.

    SELECT * FROM (co_db) FOR ALL ENTRIES IN @it_db
             WHERE task_id EQ @it_db-task_id
               AND vers_no EQ @it_db-vers_no
              INTO TABLE @et_db.

    IF i_include_buffer EQ abap_true.

      LOOP AT it_db ASSIGNING FIELD-SYMBOL(<ls_db>).
        LOOP AT ot_buffer_c ASSIGNING FIELD-SYMBOL(<ls_buffer_c>) WHERE task_id EQ <ls_db>-task_id
                                                                    AND vers_no EQ <ls_db>-vers_no.
          INSERT <ls_buffer_c> INTO TABLE et_db.
        ENDLOOP.

        LOOP AT ot_buffer_u ASSIGNING FIELD-SYMBOL(<ls_buffer_u>) WHERE task_id EQ <ls_db>-task_id
                                                                    AND vers_no EQ <ls_db>-vers_no.
          MODIFY TABLE et_db FROM <ls_buffer_u>.
        ENDLOOP.

        LOOP AT ot_buffer_d ASSIGNING FIELD-SYMBOL(<ls_buffer_d>) WHERE task_id EQ <ls_db>-task_id
                                                                    AND vers_no EQ <ls_db>-vers_no.
          DELETE et_db WHERE task_id EQ <ls_buffer_d>-task_id
                         AND vers_no EQ <ls_buffer_d>-vers_no.
        ENDLOOP.

      ENDLOOP.

      LOOP AT it_db ASSIGNING <ls_db>.
        LOOP AT ot_buffer_c_tmp ASSIGNING <ls_buffer_c> WHERE task_id EQ <ls_db>-task_id
                                                          AND vers_no EQ <ls_db>-vers_no.
          DELETE et_db WHERE task_id EQ <ls_buffer_d>-task_id
                         AND vers_no EQ <ls_buffer_d>-vers_no.
          INSERT <ls_buffer_c> INTO TABLE et_db.
        ENDLOOP.

        LOOP AT ot_buffer_u_tmp ASSIGNING <ls_buffer_u> WHERE task_id EQ <ls_db>-task_id
                                                          AND vers_no EQ <ls_db>-vers_no.
          MODIFY TABLE et_db FROM <ls_buffer_u>.
        ENDLOOP.

        LOOP AT ot_buffer_d_tmp ASSIGNING <ls_buffer_d> WHERE task_id EQ <ls_db>-task_id
                                                          AND vers_no EQ <ls_db>-vers_no.
          DELETE et_db WHERE task_id EQ <ls_buffer_d>-task_id
                         AND vers_no EQ <ls_buffer_d>-vers_no.
        ENDLOOP.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD save.

    ASSERT ot_buffer_c_tmp IS INITIAL.
    ASSERT ot_buffer_u_tmp IS INITIAL.
    ASSERT ot_buffer_d_tmp IS INITIAL.

    INSERT (co_db)  FROM TABLE @ot_buffer_c.
    UPDATE (co_db)  FROM TABLE @ot_buffer_u.
    DELETE zjl_tako FROM TABLE @( CORRESPONDING #( ot_buffer_d ) ).

  ENDMETHOD.


  METHOD _create.

    CLEAR et_db.
    CLEAR et_message.

    CHECK it_db IS NOT INITIAL.

    LOOP AT it_db INTO DATA(ls_db) ##INTO_OK.

      IF _check( EXPORTING is_db         = ls_db
                           i_change_mode = zjl_if_rap=>co_modstat_create
                 CHANGING  ct_message    = et_message ) = abap_false.
        RETURN.
      ENDIF.

      _determine( EXPORTING i_change_mode = zjl_if_rap=>co_modstat_create
                  CHANGING cs_db      = ls_db ).

      INSERT ls_db INTO TABLE ot_buffer_c_tmp.

    ENDLOOP.

    et_db = ot_buffer_c_tmp.

  ENDMETHOD.


  METHOD _update.

    DATA: lt_db TYPE tpt_db.
    DATA: ls_buffer_db TYPE tp_db.

    FIELD-SYMBOLS <ls_buffer_db> TYPE tp_db.

    CLEAR et_db.
    CLEAR et_message.

    CHECK it_db IS NOT INITIAL.

    SELECT * FROM (co_db) FOR ALL ENTRIES IN @it_db WHERE task_id EQ @it_db-task_id
                                                      AND vers_no EQ @it_db-vers_no
                                                      INTO TABLE @lt_db.

    LOOP AT it_db ASSIGNING FIELD-SYMBOL(<ls_db_update>).

      UNASSIGN <ls_buffer_db>.

      READ TABLE ot_buffer_d TRANSPORTING NO FIELDS WITH TABLE KEY task_id = <ls_db_update>-task_id
                                                                   vers_no = <ls_db_update>-vers_no.

      IF sy-subrc IS INITIAL.
        APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '002' ) ) TO et_message.
        RETURN.
      ENDIF.

      IF <ls_buffer_db> IS NOT ASSIGNED." Special case: record already in temporary create buffer
        READ TABLE ot_buffer_c_tmp ASSIGNING <ls_buffer_db> WITH TABLE KEY task_id = <ls_db_update>-task_id
                                                                           vers_no = <ls_db_update>-vers_no.
      ENDIF.

      IF <ls_buffer_db> IS NOT ASSIGNED." Special case: record already in create buffer
        READ TABLE ot_buffer_c INTO ls_buffer_db WITH TABLE KEY task_id = <ls_db_update>-task_id
                                                                vers_no = <ls_db_update>-vers_no.
        IF sy-subrc IS INITIAL.
          INSERT ls_buffer_db INTO TABLE ot_buffer_c_tmp ASSIGNING <ls_buffer_db>.
        ENDIF.
      ENDIF.

      IF <ls_buffer_db> IS NOT ASSIGNED." Special case: record already in temporary update buffer
        READ TABLE ot_buffer_u_tmp ASSIGNING <ls_buffer_db> WITH TABLE KEY task_id = <ls_db_update>-task_id
                                                                           vers_no = <ls_db_update>-vers_no.
      ENDIF.

      IF <ls_buffer_db> IS NOT ASSIGNED." Special case: record already in update buffer
        READ TABLE ot_buffer_u INTO ls_buffer_db WITH TABLE KEY task_id = <ls_db_update>-task_id
                                                                vers_no = <ls_db_update>-vers_no.
        IF sy-subrc IS INITIAL.
          INSERT ls_buffer_db INTO TABLE ot_buffer_u_tmp ASSIGNING <ls_buffer_db>.
        ENDIF.
      ENDIF.

      IF <ls_buffer_db> IS NOT ASSIGNED." Usual case: record not already in update buffer
        READ TABLE lt_db ASSIGNING FIELD-SYMBOL(<ls_db_old>) WITH TABLE KEY task_id = <ls_db_update>-task_id
                                                                            vers_no = <ls_db_update>-vers_no.
        IF sy-subrc IS INITIAL.
          INSERT <ls_db_old> INTO TABLE ot_buffer_u_tmp ASSIGNING <ls_buffer_db>.
          ASSERT sy-subrc = 0.
        ENDIF.
      ENDIF.

      " Error
      IF <ls_buffer_db> IS NOT ASSIGNED.
        APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '003' ) ) TO et_message.
        RETURN.
      ENDIF.

      DATA(ls_db) = <ls_db_update>.

      IF _check( EXPORTING is_db         = ls_db
                           i_change_mode = zjl_if_rap=>co_modstat_create
                 CHANGING  ct_message    = et_message ) = abap_false.
        RETURN.
      ENDIF.

      _determine( EXPORTING i_change_mode = zjl_if_rap=>co_modstat_update
                  CHANGING  cs_db         = ls_db ).

      DELETE ot_buffer_u_tmp WHERE task_id EQ ls_db-task_id
                               AND vers_no EQ ls_db-vers_no.
      INSERT ls_db INTO TABLE ot_buffer_u_tmp .

      APPEND ls_db TO et_db.

    ENDLOOP.

  ENDMETHOD.


  METHOD _delete.

    DATA lt_db_key TYPE tpt_db_key.

    CLEAR et_message.

    CHECK it_db IS NOT INITIAL.

    " Check for empty keys
    LOOP AT it_db ASSIGNING FIELD-SYMBOL(<ls_db_delete>) WHERE task_id IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'TASK_ID' ) ) TO et_message.
      RETURN.
    ENDLOOP.

    LOOP AT it_db ASSIGNING <ls_db_delete> WHERE vers_no = 0.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '001' attr1 = 'VERS_NO' ) ) TO et_message.
      RETURN.
    ENDLOOP.

    DATA(lt_db) = it_db.

    LOOP AT lt_db ASSIGNING <ls_db_delete>.
      " Special case: record already in create buffer
      READ TABLE ot_buffer_c TRANSPORTING NO FIELDS WITH TABLE KEY task_id = <ls_db_delete>-task_id
                                                                        vers_no = <ls_db_delete>-vers_no.
      IF sy-subrc IS INITIAL.
        INSERT VALUE #( task_id = <ls_db_delete>-task_id
                        vers_no = <ls_db_delete>-vers_no ) INTO TABLE ot_buffer_d_tmp.
        DELETE lt_db.
      ENDIF.
    ENDLOOP.

    IF i_no_delete_check EQ abap_false.
      SELECT task_id, vers_no FROM (co_db) FOR ALL ENTRIES IN @lt_db
                              WHERE task_id EQ @lt_db-task_id
                                AND vers_no EQ @lt_db-vers_no INTO CORRESPONDING FIELDS OF TABLE @lt_db_key.
    ENDIF.

    LOOP AT lt_db ASSIGNING <ls_db_delete>.
      IF i_no_delete_check EQ abap_false.
        READ TABLE lt_db_key TRANSPORTING NO FIELDS WITH TABLE KEY task_id = <ls_db_delete>-task_id
                                                                   vers_no = <ls_db_delete>-vers_no.
        IF NOT sy-subrc IS INITIAL.
          APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '007' attr1 = 'TASK_ID' ) ) TO et_message.
          RETURN.
        ENDIF.
      ENDIF.
      INSERT VALUE #( task_id = <ls_db_delete>-task_id
                      vers_no = <ls_db_delete>-vers_no ) INTO TABLE ot_buffer_d_tmp.
    ENDLOOP.

  ENDMETHOD.


  METHOD adjust_numbers.

    DATA: l_nrnr TYPE nrnr VALUE '01'.

    READ TABLE ot_buffer_c ASSIGNING FIELD-SYMBOL(<ls_buffer_c>) WITH KEY task_id = co_dummy_id.

    CHECK sy-subrc IS INITIAL.

    DATA(ls_buffer) = <ls_buffer_c>.

    TRY.
        CALL METHOD cl_numberrange_runtime=>number_get
          EXPORTING
            nr_range_nr = l_nrnr
            object      = co_nrobj
          IMPORTING
            number      = DATA(l_number)
            returncode  = DATA(l_rcode).

      CATCH cx_nr_object_not_found cx_number_ranges .
        APPEND NEW zjl_cx_behavior( textid = zjl_cx_behavior=>co_err_number_range ) TO et_message.
        RETURN.

    ENDTRY.

    IF NOT l_rcode IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = zjl_cx_behavior=>co_err_number_range ) TO et_message.
      RETURN.
    ENDIF.

    ls_buffer-task_id = l_number.

    DELETE ot_buffer_c WHERE task_id EQ co_dummy_id.

    APPEND ls_buffer TO ot_buffer_c.

    e_task_id = ls_buffer-task_id.
    e_vers_no = ls_buffer-vers_no.

  ENDMETHOD.


  METHOD get_next_vers_no.

    SELECT MAX( vers_no ) INTO @r_versno FROM (co_db) WHERE task_id EQ @i_taskid.

    r_versno = r_versno + 1.

  ENDMETHOD.


  METHOD _check.

    r_is_valid = abap_true.

  ENDMETHOD.


  METHOD _determine.

    CASE i_change_mode.
      WHEN zjl_if_rap=>co_modstat_create.
        IF cs_db-task_id IS INITIAL.
          cs_db-task_id          = co_dummy_id.
          cs_db-vers_no          = 1.
          cs_db-vers_from_dt     = cl_abap_context_info=>get_system_date( ).
          cs_db-vers_to_dt       = '99991231'.
          cs_db-vers_inactive_fl = space.
          cs_db-vers_etag_ts     = utclong_current( ).
          cs_db-vers_origin_no   = 0.
          cs_db-status_cd        = zjl_cl_task_bo=>co_status_inchange.
          cs_db-recipient_cd     = cl_abap_context_info=>get_user_technical_name( ).
        ENDIF.
        cs_db-create_user_cd   = cl_abap_context_info=>get_user_technical_name( ).
        cs_db-create_ts        = utclong_current( ).
      WHEN zjl_if_rap=>co_modstat_update.
        cs_db-vers_etag_ts     = utclong_current( ).
        cs_db-change_user_cd   = cl_abap_context_info=>get_user_technical_name( ).
        cs_db-change_ts        = utclong_current( ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
