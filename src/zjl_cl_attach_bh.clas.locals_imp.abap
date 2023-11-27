CLASS lhc_attachment DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ attachment RESULT result.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE attachment.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE attachment.

    METHODS rba_task FOR READ
      IMPORTING keys_rba FOR READ attachment\_task FULL result_requested RESULT result LINK association_links.

    METHODS map_with_control
      IMPORTING is_entity  TYPE zjl_cl_attach_bo=>tp_entity
                is_control TYPE any
      CHANGING  cs_entity  TYPE zjl_cl_attach_bo=>tp_entity.

ENDCLASS.

CLASS lhc_attachment IMPLEMENTATION.

  METHOD update.

    DATA: ls_entity TYPE zjl_cl_attach_bo=>tp_entity.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      zjl_cl_attach_bo=>get_instance( )->read( EXPORTING i_taskid  = <ls_entity>-%key-taskid
                                                         i_versno  = <ls_entity>-%key-versno
                                                         i_atacno  = <ls_entity>-%key-atacno
                                               IMPORTING es_entity  = DATA(ls_entity_in)
                                                         et_message = DATA(lt_message) ).

      MOVE-CORRESPONDING <ls_entity> TO ls_entity.

      map_with_control( EXPORTING is_entity  = ls_entity
                                  is_control = <ls_entity>-%control
                        CHANGING  cs_entity  =  ls_entity_in ).

      zjl_cl_attach_bo=>get_instance( )->update( EXPORTING is_entity  = ls_entity_in
                                                 IMPORTING es_entity  = DATA(ls_etity_out) ##needed
                                                           et_message = lt_message ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_attach_bo=>handle_messages( EXPORTING i_cid      = <ls_entity>-%cid_ref
        i_taskid  = <ls_entity>-%key-taskid
        i_versno  = <ls_entity>-%key-versno
        i_atacno  = <ls_entity>-%key-atacno
        it_message = lt_message
        CHANGING failed     = failed-attachment
        reported   = reported-attachment ).
      ELSE.
        APPEND INITIAL LINE TO mapped-task ASSIGNING FIELD-SYMBOL(<ls_mapped>).
        <ls_mapped>-%cid = <ls_entity>-%cid_ref.
        <ls_mapped>-%key = <ls_entity>-%key.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      zjl_cl_attach_bo=>get_instance( )->delete( EXPORTING i_taskid  = <ls_key>-%key-taskid
      i_versno  = <ls_key>-%key-versno
      i_atacno  = <ls_key>-%key-atacno
      IMPORTING et_message = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_attach_bo=>handle_messages( EXPORTING i_cid      = space
        i_taskid  = <ls_key>-%key-taskid
        i_versno  = <ls_key>-%key-versno
        i_atacno  = <ls_key>-%key-atacno
        it_message = lt_message
        CHANGING failed     = failed-attachment
        reported   = reported-attachment ).
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      zjl_cl_attach_bo=>get_instance( )->read( EXPORTING i_taskid  = <ls_key>-%key-taskid
      i_versno  = <ls_key>-%key-versno
      i_atacno  = <ls_key>-%key-atacno
      IMPORTING es_entity  = DATA(ls_entity)
      et_message = DATA(lt_message) ).

      IF NOT lt_message IS INITIAL.
        zjl_cl_attach_buffer=>handle_messages( EXPORTING i_cid      = space
        i_task_id  = <ls_key>-%key-taskid
        i_vers_no  = <ls_key>-%key-versno
        i_atac_no  = <ls_key>-%key-atacno
        it_message = lt_message
        CHANGING failed     = failed-attachment
        reported   = reported-attachment ).
      ELSE.
        APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
        MOVE-CORRESPONDING ls_entity TO <ls_result>.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD rba_task.

    DATA(l) = 1 ##needed.

  ENDMETHOD.

  METHOD map_with_control.

    DATA: lr_control       TYPE REF TO data.
    DATA: lr_control_descr TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS: <l_field>     TYPE any.
    FIELD-SYMBOLS: <l_field_in>  TYPE any.
    FIELD-SYMBOLS: <l_field_out> TYPE any.

    CLEAR: lr_control.
    CLEAR: lr_control_descr.

    CREATE DATA lr_control LIKE is_control.

    lr_control_descr ?= cl_abap_structdescr=>describe_by_data_ref( p_data_ref = lr_control ).

    LOOP AT lr_control_descr->components ASSIGNING FIELD-SYMBOL(<l_component>).

      ASSIGN COMPONENT <l_component>-name OF STRUCTURE is_control TO <l_field>.

      IF  <l_field> IS ASSIGNED
      AND <l_field> EQ if_abap_behv=>mk-on.

        ASSIGN COMPONENT <l_component>-name OF STRUCTURE is_entity TO <l_field_in>.
        ASSIGN COMPONENT <l_component>-name OF STRUCTURE cs_entity TO <l_field_out>.

        IF  <l_field_in>  IS ASSIGNED
        AND <l_field_out> IS ASSIGNED.
          <l_field_out> = <l_field_in>.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
