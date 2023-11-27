CLASS zjl_cl_task_amdp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_amdp_marker_hdb.
    CLASS-METHODS: get_task_my     FOR TABLE FUNCTION zjl_o_h_task_my.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS zjl_cl_task_amdp IMPLEMENTATION.


  METHOD get_task_my BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY USING zjl_tako zjl_reco.

* Alle direkt zugeordneten Aufgaben
    lt_mytako_1 = select DISTINCT tak.mandt, tak.task_id, tak.vers_no, 1 as mytaskfl
                    from zjl_tako as tak
                   where mandt        = session_context('CLIENT')
                     and recipient_cd = p_uname;

* Alle direkt zugeordneten Aufgaben
    lt_mytako_2 = select distinct tak.mandt, tak.task_id, tak.vers_no, 1 as mytaskfl
                    from zjl_tako as tak
                   inner join zjl_reco as rec
                          on tak.mandt              = rec.mandt
                         and tak.recipient_group_cd = rec.recipient_group_cd
                   where tak.mandt        = session_context('CLIENT')
                     AND rec.recipient_cd = p_uname;

* Alle meine Aufgaben
    lt_mytako = SELECT * FROM :lt_mytako_1
                UNION
                SELECT * FROM :lt_mytako_2;

    RETURN SELECT DISTINCT tak.mandt as clientcd, tak.task_id as taskid, tak.vers_no as versno,
                case when my.mytaskfl = 1 then 'X' ELSE ' ' END as mytaskfl
                from zjl_tako as tak
                left outer join :lt_mytako as my
                             ON tak.mandt              = my.mandt
                            and tak.task_id            = my.task_id
                            and tak.vers_no            = my.vers_no;

  endmethod.


ENDCLASS.
