CLASS zjl_cl_recipient_bo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS co_feature_recipientcd      TYPE zjl_feature VALUE 'RecipientCD' ##NO_TEXT.
    CONSTANTS co_feature_recipientgroupcd TYPE zjl_feature VALUE 'RecipientGroupCD' ##NO_TEXT.

    TYPES: tp_db      TYPE zjl_reco .

    TYPES: tp_entity  TYPE zjl_o_d_recipient .
    TYPES: tpt_entity TYPE STANDARD TABLE OF zjl_o_d_recipient .

    TYPES:
      tpt_failed  TYPE TABLE FOR FAILED   zjl_o_d_recipient .
    TYPES:
      tpt_mapped   TYPE TABLE FOR MAPPED   zjl_o_d_recipient .
    TYPES:
      tpt_reported TYPE TABLE FOR REPORTED zjl_o_d_recipient .

    TYPES:
      tpt_failed_late   TYPE TABLE FOR FAILED LATE  zjl_o_d_recipient .
    TYPES:
      tpt_mapped_late   TYPE TABLE FOR MAPPED LATE   zjl_o_d_recipient .
    TYPES:
      tpt_reported_late TYPE TABLE FOR REPORTED LATE zjl_o_d_recipient .

    TYPES:
      tpt_update    TYPE TABLE FOR UPDATE zjl_o_d_recipient.

    CLASS-METHODS get_instance
      RETURNING
        VALUE(rr_instance) TYPE REF TO zjl_cl_recipient_bo .

    CLASS-METHODS handle_messages
      IMPORTING
        !i_cid                TYPE string OPTIONAL
        !i_recipient_group_cd TYPE zjl_group OPTIONAL
        !i_recipient_cd       TYPE syuname OPTIONAL
        !it_message           TYPE zjl_if_rap=>tpt_message
      CHANGING
        !failed               TYPE tpt_failed_late
        !reported             TYPE tpt_reported_late.

    METHODS validate
      IMPORTING
        !is_entity TYPE tp_entity
      EXPORTING
        et_message TYPE zjl_if_rap=>tpt_message.

    METHODS determine
      IMPORTING
        !i_change_mode TYPE c
      CHANGING
        !cs_entity     TYPE tp_entity.

    METHODS get_instance_features
      IMPORTING
        !i_recipientgroupcd TYPE zjl_group
        !i_recipientcd      TYPE syuname
        !i_feature          TYPE zjl_feature
      RETURNING
        VALUE(r_flag)       TYPE zjl_enable .

  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-DATA or_instance TYPE REF TO zjl_cl_recipient_bo .


ENDCLASS.

CLASS zjl_cl_recipient_bo IMPLEMENTATION.

  METHOD get_instance.

    or_instance = COND #( WHEN or_instance IS BOUND THEN or_instance ELSE NEW #( ) ).

    rr_instance = or_instance.

  ENDMETHOD.

  METHOD handle_messages.

    DATA: lr_struc       TYPE REF TO data.
    DATA: lr_struc_descr TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS: <l_field> TYPE any.

    LOOP AT it_message INTO DATA(ls_message).

      APPEND VALUE #( recipientgroupcd = i_recipient_group_cd
                      recipientcd = i_recipient_cd ) TO failed.

      APPEND INITIAL LINE TO reported ASSIGNING FIELD-SYMBOL(<ls_reported>).
      <ls_reported>-%msg        = ls_message.
      <ls_reported>-%key-recipientgroupcd = i_recipient_group_cd.
      <ls_reported>-%key-recipientcd = i_recipient_cd.
      <ls_reported>-recipientgroupcd = i_recipient_group_cd.
      <ls_reported>-recipientcd = i_recipient_cd.

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

  METHOD validate.

    CLEAR et_message.

* Technische Prüfung "Empfängergruppe"
    IF is_entity-recipientgroupcd IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '008' attr1 = 'Empfängergruppe' )
                                  uifield = 'RECIPIENT_GROUP_CD' ) TO et_message.
      RETURN.
    ELSE.
      SELECT SINGLE * FROM zjl_b_v_group WHERE code EQ @is_entity-recipientgroupcd INTO @DATA(ls_dummy) ##needed.
      IF NOT sy-subrc IS INITIAL.
        APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '009' attr1 = 'Empfängergruppe' )
                                    uifield = 'RECIPIENT_GROUP_CD' ) TO et_message.
        RETURN.
      ENDIF.
    ENDIF.

* Technische Prüfung "Empfänger"
    IF is_entity-recipientcd IS INITIAL.
      APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '008' attr1 = 'Empfänger' )
                                  uifield = 'RECIPIENT_CD' ) TO et_message.
      RETURN.
    ELSE.
      SELECT SINGLE * FROM zjl_b_v_uname WHERE code EQ @is_entity-recipientcd INTO @DATA(ls_dummy_2) ##needed.
      IF NOT sy-subrc IS INITIAL.
        APPEND NEW zjl_cx_behavior( textid = VALUE #( msgid = zjl_if_rap=>co_msgid msgno = '009' attr1 = 'Empfänger' )
                                    uifield = 'RECIPIENT_CD' ) TO et_message.
        RETURN.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD determine.

    CASE i_change_mode.
      WHEN zjl_if_rap=>co_modstat_create.
        cs_entity-createusercd   = cl_abap_context_info=>get_user_technical_name( ).
        cs_entity-createts       = utclong_current( ).
        cs_entity-versetagts     = utclong_current( ).
      WHEN zjl_if_rap=>co_modstat_update.
        cs_entity-changeusercd   = cl_abap_context_info=>get_user_technical_name( ).
        cs_entity-changets       = utclong_current( ).
        cs_entity-versetagts     = utclong_current( ).
    ENDCASE.

  ENDMETHOD.

  METHOD get_instance_features.

    r_flag = zjl_if_rap=>co_feature_disabled.

    SELECT COUNT( * ) FROM zjl_b_o_tak WHERE recipientgroupcd EQ @i_recipientgroupcd INTO @DATA(l_count).

    CASE i_feature.

      WHEN zjl_if_rap=>co_feature_delete.
        IF  l_count EQ 0.
          r_flag = zjl_if_rap=>co_feature_enabled.
        ENDIF.

      WHEN co_feature_recipientcd.
        IF  l_count NE 0.
          r_flag = zjl_if_rap=>co_feature_readonly.
        ENDIF.

      WHEN co_feature_recipientgroupcd.
        IF  l_count NE 0.
          r_flag = zjl_if_rap=>co_feature_readonly.
        ENDIF.

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
