CLASS lhc_recipient DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR recipient RESULT result.

    METHODS determine_create FOR DETERMINE ON MODIFY
      IMPORTING keys FOR recipient~determination_create.

    METHODS determine_update FOR DETERMINE ON MODIFY
      IMPORTING keys FOR recipient~determination_update.

    METHODS validation FOR VALIDATE ON SAVE
      IMPORTING keys FOR recipient~validation.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR recipient RESULT result.

ENDCLASS.

CLASS lhc_recipient IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD determine_create.

*    DATA: ls_db     TYPE zjl_cl_recipient_buffer=>tp_db.
*    DATA: lt_update TYPE zjl_cl_recipient_buffer=>tpt_update.
*
*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
*
*      READ ENTITIES OF zjl_o_d_recipient IN LOCAL MODE
*      ENTITY recipient ALL FIELDS WITH VALUE #( ( recipientgroupcd = <ls_key>-recipientgroupcd recipientcd = <ls_key>-recipientcd ) )
*       RESULT DATA(lt_entity)
*       FAILED DATA(lt_failed_1)
*       REPORTED DATA(lt_reported_1).
*
*      ASSERT lines( lt_entity ) = 1.
*
*      READ TABLE lt_entity INTO DATA(ls_entity) INDEX 1.
*
*      map_without_control( EXPORTING is_entity  = ls_entity
*                           CHANGING  cs_db      = ls_db ).
*
*      zjl_cl_recipient_buffer=>get_instance( )->determine( EXPORTING i_change_mode = zjl_if_rap=>co_modstat_create
*                                                           CHANGING  cs_db         = ls_db ).
*
*      ls_entity = CORRESPONDING #( BASE ( ls_entity ) ls_db MAPPING TO ENTITY CHANGING CONTROL ).
*
*      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
*      MOVE-CORRESPONDING ls_entity TO <ls_update>.
*
*      MODIFY ENTITIES OF zjl_o_d_recipient IN LOCAL MODE
*      ENTITY recipient UPDATE FROM lt_update
*      FAILED DATA(lt_failed_2)
*      REPORTED DATA(lt_reported_2).
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD determine_update.

*    DATA: ls_db     TYPE zjl_cl_recipient_buffer=>tp_db.
*    DATA: lt_update TYPE zjl_cl_recipient_buffer=>tpt_update.
*
*    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
*
*      READ ENTITIES OF zjl_o_d_recipient IN LOCAL MODE
*      ENTITY recipient ALL FIELDS WITH VALUE #( ( recipientgroupcd = <ls_key>-recipientgroupcd recipientcd = <ls_key>-recipientcd ) )
*       RESULT DATA(lt_entity)
*       FAILED DATA(lt_failed_1)
*       REPORTED DATA(lt_reported_1).
*
*      ASSERT lines( lt_entity ) = 1.
*
*      READ TABLE lt_entity INTO DATA(ls_entity) INDEX 1.
*
*      map_without_control( EXPORTING is_entity  = ls_entity
*                           CHANGING  cs_db      = ls_db ).
*
*      zjl_cl_recipient_buffer=>get_instance( )->determine( EXPORTING i_change_mode = zjl_if_rap=>co_modstat_update
*                                                           CHANGING  cs_db         = ls_db ).
*
*      ls_entity = CORRESPONDING #( BASE ( ls_entity ) ls_db MAPPING TO ENTITY ).
*
*      APPEND INITIAL LINE TO lt_update ASSIGNING FIELD-SYMBOL(<ls_update>).
*      MOVE-CORRESPONDING ls_entity TO <ls_update>.
*
*      MODIFY ENTITIES OF zjl_o_d_recipient IN LOCAL MODE
*      ENTITY recipient UPDATE FROM lt_update
*      FAILED DATA(lt_failed_2)
*      REPORTED DATA(lt_reported_2).
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD validation.

    DATA: ls_entity_in  TYPE zjl_cl_recipient_bo=>tp_entity.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      READ ENTITIES OF zjl_o_d_recipient IN LOCAL MODE
      ENTITY recipient ALL FIELDS WITH VALUE #( ( recipientgroupcd = <ls_key>-recipientgroupcd recipientcd = <ls_key>-recipientcd ) )
       RESULT DATA(lt_entity)
       FAILED DATA(lt_failed)
       REPORTED DATA(lt_reported).

      ASSERT lines( lt_entity ) = 1.

      READ TABLE lt_entity INTO DATA(ls_entity) INDEX 1.

      MOVE-CORRESPONDING ls_entity TO ls_entity_in.

      zjl_cl_recipient_bo=>get_instance( )->validate( EXPORTING is_entity  = ls_entity_in
                                                      IMPORTING et_message = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_recipient_bo=>handle_messages( EXPORTING i_cid                 = space
                                                            i_recipient_group_cd  = <ls_key>-recipientgroupcd
                                                            i_recipient_cd        = <ls_key>-recipientcd
                                                            it_message            = lt_message
                                                  CHANGING  failed                = failed-recipient
                                                            reported              = reported-recipient ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result>-%key = <ls_keys>-%key.
      IF requested_features-%delete EQ if_abap_behv=>mk-on.
        <ls_result>-%features-%delete = zjl_cl_recipient_bo=>get_instance( )->get_instance_features( EXPORTING i_recipientgroupcd = <ls_keys>-recipientgroupcd
                                                                                                               i_recipientcd      = <ls_keys>-recipientcd
                                                                                                               i_feature          = zjl_if_rap=>co_feature_delete ).
      ENDIF.
      IF requested_features-%field-RecipientCD EQ if_abap_behv=>mk-on.
        <ls_result>-%features-%field-RecipientCD = zjl_cl_recipient_bo=>get_instance( )->get_instance_features( EXPORTING i_recipientgroupcd = <ls_keys>-recipientgroupcd
                                                                                                               i_recipientcd      = <ls_keys>-recipientcd
                                                                                                               i_feature          = zjl_cl_recipient_bo=>co_feature_recipientcd ).
      ENDIF.
      IF requested_features-%field-RecipientgroupCD EQ if_abap_behv=>mk-on.
        <ls_result>-%features-%field-RecipientGroupCD = zjl_cl_recipient_bo=>get_instance( )->get_instance_features( EXPORTING i_recipientgroupcd = <ls_keys>-recipientgroupcd
                                                                                                                               i_recipientcd      = <ls_keys>-recipientcd
                                                                                                                               i_feature          = zjl_cl_recipient_bo=>co_feature_recipientgroupcd ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
