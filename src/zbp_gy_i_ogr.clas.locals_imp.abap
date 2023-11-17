CLASS lhc_Ogrenci DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Ogrenci RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Ogrenci RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Ogrenci RESULT result.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Ogrenci.

    METHODS onayla FOR MODIFY
      IMPORTING keys FOR ACTION Ogrenci~onayla RESULT result.

    METHODS dersSaat FOR DETERMINE ON SAVE
      IMPORTING keys FOR Ogrenci~dersSaat.

    METHODS uygunYas FOR VALIDATE ON SAVE
      IMPORTING keys FOR Ogrenci~uygunYas.

    METHODS is_update_allowed
      RETURNING VALUE(update_allowed) TYPE abap_bool.

ENDCLASS.

CLASS lhc_Ogrenci IMPLEMENTATION.

  METHOD is_update_allowed.
* bunu production environmentta kullanmamalıymışız! normalde authorization objesi olmalı
    update_allowed = abap_true.
*    update_allowed = abap_false.
  ENDMETHOD.

  METHOD get_instance_features.
    "durum  X  ise onayla butonu disabled olacak
    "durum ' ' ise onayla butonu enabled olacak

    READ ENTITIES OF zgy_i_ogr IN LOCAL MODE
    ENTITY Ogrenci
    FIELDS ( Durum ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_onayla)
    FAILED failed.

    result = VALUE #( FOR ogr IN lt_onayla LET durumval = COND #( WHEN ogr-Durum = abap_true
                                                                     THEN if_abap_behv=>fc-o-disabled
                                                                     ELSE if_abap_behv=>fc-o-enabled )

                                                                     IN ( %tky = ogr-%tky
                                                                          %action-onayla = durumval ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA: update_requested TYPE abap_bool,
          update_granted   TYPE abap_bool.

    READ ENTITIES OF zgy_i_ogr IN LOCAL MODE
    ENTITY Ogrenci
    FIELDS ( Durum ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_ogr)
    FAILED failed.

    CHECK lt_ogr IS NOT INITIAL.

    update_requested = COND #( WHEN requested_authorizations-%update      = if_abap_behv=>mk-on
                               OR   requested_authorizations-%action-Edit = if_abap_behv=>mk-on THEN abap_true
                                                                                                ELSE abap_false ).

    LOOP AT lt_ogr ASSIGNING FIELD-SYMBOL(<lfs_ogr>).

      IF <lfs_ogr>-Durum = abap_false.

        IF update_requested = abap_true.

          update_granted = is_update_allowed( ).

          IF update_granted = abap_false. " authorization check failed olmuş oluyor yetki sağlanamıyor
            APPEND VALUE #( %tky = <lfs_ogr>-%tky ) TO failed-ogrenci.
            APPEND VALUE #( %tky = keys[ 1 ]-%tky
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = |Durum alanını Update etmek yetki yoktur! (instance authorization)|
                                   )  ) TO reported-ogrenci.
          ENDIF.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations. "instance authorizationda importing parametresinde keys de var global da yok

    IF requested_authorizations-%update = if_abap_behv=>mk-on OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on.

      IF is_update_allowed( ) = abap_true.

        result-%update      = if_abap_behv=>auth-allowed.
        result-%action-Edit = if_abap_behv=>auth-allowed.

      ELSE.

        result-%update      = if_abap_behv=>auth-unauthorized.
        result-%action-Edit = if_abap_behv=>auth-unauthorized.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD precheck_update.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entity>).

      "01 = değer güncellendi / değişti , 00 = değer değişmedi -> entities de update tablosu control alanları var

      CHECK <lfs_entity>-%control-Ders EQ '01' OR <lfs_entity>-%control-Derssure EQ '01'.

      READ ENTITIES OF zgy_i_ogr IN LOCAL MODE
      ENTITY Ogrenci
      FIELDS ( Derssure ) WITH VALUE #( ( %key = <lfs_entity>-%key ) )
      RESULT DATA(lt_precheck).

      IF sy-subrc IS INITIAL.

        READ TABLE lt_precheck ASSIGNING FIELD-SYMBOL(<lfs_db_precheck>) INDEX 1.

        IF sy-subrc IS INITIAL.

          "değişim varsa ya frontend değerini ya da database değerini alacak.

          <lfs_db_precheck>-Ders = COND #( WHEN <lfs_entity>-%control-Ders EQ '01' THEN <lfs_entity>-Ders
                                           ELSE <lfs_db_precheck>-Ders ).
          <lfs_db_precheck>-Derssure = COND #( WHEN <lfs_entity>-%control-Derssure EQ '01' THEN <lfs_entity>-Derssure
                                               ELSE <lfs_db_precheck>-Derssure ).

          IF <lfs_db_precheck>-Derssure < 6.

            IF <lfs_db_precheck>-Ders = 'C' OR <lfs_db_precheck>-Ders = 'E'.

              APPEND VALUE #( %tky = <lfs_entity>-%tky ) TO failed-ogrenci.
              APPEND VALUE #( %tky = <lfs_entity>-%tky
                              %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-error
                                       text     = 'Geçersiz Ders Saati Girdiniz!!!'
                                     ) ) TO reported-ogrenci.
            ENDIF.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD onayla.

    "durum değiştirme action butonu için EML

    MODIFY ENTITIES OF zgy_i_ogr IN LOCAL MODE
    ENTITY Ogrenci
    UPDATE
    FIELDS ( Durum ) WITH VALUE #( FOR key IN keys ( %tky = key-%tky    Durum = abap_true ) )
    FAILED failed
    REPORTED reported.

    "update işleminden sonra veri okunmalı:

    READ ENTITIES OF zgy_i_ogr IN LOCAL MODE
    ENTITY Ogrenci
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_onay).

    result = VALUE #( FOR data IN lt_onay ( %tky = data-%tky    %param = data ) ).

  ENDMETHOD.

  METHOD dersSaat.
    "determination ders için ders saatini değiştirir

    READ ENTITIES OF zgy_i_ogr IN LOCAL MODE
    ENTITY Ogrenci
    FIELDS ( Ders ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_ders).

    LOOP AT lt_ders INTO DATA(ls_ders).

      CASE ls_ders-Ders.
        WHEN 'C'.
          MODIFY ENTITIES OF zgy_i_ogr IN LOCAL MODE
          ENTITY Ogrenci
          UPDATE
          FIELDS ( Derssure ) WITH VALUE #( ( %tky = ls_ders-%tky   Derssure = 9 ) ).
        WHEN 'E'.
          MODIFY ENTITIES OF zgy_i_ogr IN LOCAL MODE
          ENTITY Ogrenci
          UPDATE
          FIELDS ( Derssure ) WITH VALUE #( ( %tky = ls_ders-%tky   Derssure = 6 ) ).
        WHEN 'M'.
          MODIFY ENTITIES OF zgy_i_ogr IN LOCAL MODE
          ENTITY Ogrenci
          UPDATE
          FIELDS ( Derssure ) WITH VALUE #( ( %tky = ls_ders-%tky   Derssure = 7 ) ).
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD uygunYas.
    READ ENTITIES OF zgy_i_ogr IN LOCAL MODE
    ENTITY Ogrenci
    FIELDS ( Yas ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_yas).

    LOOP AT lt_yas INTO DATA(ls_yas). "GROUP BY ( yas = ls_yas-Yas keys-%tky = ls_yas-%tky ) ascending ASSIGNING FIELD-SYMBOL(<lfs_yas>).

      IF ls_yas-Yas < 18.

        APPEND VALUE #( %tky = ls_yas-%tky ) TO failed-ogrenci.
        APPEND VALUE #( %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = |Yaş alanı 18'den küçük olamaz!|
                               ) ) TO reported-ogrenci.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
