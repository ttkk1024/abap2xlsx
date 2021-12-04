REPORT zdemo_excel40.


CLASS lcl_excel_generator DEFINITION INHERITING FROM zcl_demo_excel_generator.

  PUBLIC SECTION.
    METHODS zif_demo_excel_generator~get_information REDEFINITION.
    METHODS zif_demo_excel_generator~generate_excel REDEFINITION.

ENDCLASS.

DATA: lo_excel           TYPE REF TO zcl_excel,
      lo_excel_generator TYPE REF TO lcl_excel_generator.

CONSTANTS: gc_save_file_name TYPE string VALUE '40_Printsettings.xlsx'.
INCLUDE zdemo_excel_outputopt_incl.



START-OF-SELECTION.

  CREATE OBJECT lo_excel_generator.
  lo_excel = lo_excel_generator->zif_demo_excel_generator~generate_excel( ).

*** Create output
  lcl_output=>output( lo_excel ).



CLASS lcl_excel_generator IMPLEMENTATION.

  METHOD zif_demo_excel_generator~get_information.

    result-objid = sy-repid.
    result-text = 'abap2xlsx Demo: Print settings'.
    result-filename = gc_save_file_name.

  ENDMETHOD.

  METHOD zif_demo_excel_generator~generate_excel.

    DATA: lo_excel     TYPE REF TO zcl_excel,
          lo_worksheet TYPE REF TO zcl_excel_worksheet.

    DATA: lv_row       TYPE zexcel_cell_row,
          lv_col       TYPE i,
          lv_row_char  TYPE char10,
          lv_value     TYPE string,
          ls_fontcolor TYPE zexcel_style_color_argb.

    " Creates active sheet
    CREATE OBJECT lo_excel.

    " Get active sheet
    lo_worksheet = lo_excel->get_active_worksheet( ).
    lo_worksheet->set_title( ip_title = 'Demo Printsettings' ).

*--------------------------------------------------------------------*
*  Prepare sheet with trivial data
*    - first 4 columns will have fontocolor set
*    - first 3 rows will  have fontcolor set
*    These marked cells will be used for repeatable rows/columns on printpages
*--------------------------------------------------------------------*
    DO 100 TIMES.  " Rows

      lv_row = sy-index .
      WRITE lv_row TO lv_row_char.

      DO 20 TIMES.

        lv_col = sy-index - 1.
        CONCATENATE sy-abcde+lv_col(1) lv_row_char INTO lv_value.
        lv_col = sy-index.
        lo_worksheet->set_cell( ip_row    = lv_row
                                ip_column = lv_col
                                ip_value  = lv_value ).

        TRY.
            IF lv_row <= 3.
              lo_worksheet->change_cell_style(  ip_column           = lv_col
                                                ip_row              = lv_row
                                                ip_fill_filltype    = zcl_excel_style_fill=>c_fill_solid
                                                ip_fill_fgcolor_rgb = zcl_excel_style_color=>c_yellow ).
            ENDIF.
            IF lv_col <= 4.
              lo_worksheet->change_cell_style(  ip_column           = lv_col
                                                ip_row              = lv_row
                                                ip_font_color_rgb   = zcl_excel_style_color=>c_red ).
            ENDIF.
          CATCH zcx_excel .
        ENDTRY.

      ENDDO.



    ENDDO.


*--------------------------------------------------------------------*
*  Printsettings
*--------------------------------------------------------------------*
    TRY.
        lo_worksheet->zif_excel_sheet_printsettings~set_print_repeat_columns( iv_columns_from = 'A'
                                                                              iv_columns_to   = 'D' ).
        lo_worksheet->zif_excel_sheet_printsettings~set_print_repeat_rows(    iv_rows_from    = 1
                                                                              iv_rows_to      = 3 ).
      CATCH zcx_excel .
    ENDTRY.

    result = lo_excel.

  ENDMETHOD.

ENDCLASS.
