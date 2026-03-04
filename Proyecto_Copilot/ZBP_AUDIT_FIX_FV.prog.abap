*&---------------------------------------------------------------------*
*& Report ZBP_AUDIT_FIX_FV
*&---------------------------------------------------------------------*
*& <p class="shorttext synchronized">Business Partner Audit & Fix Tool</p>
*& Audit and correction tool for Business Partners validation.
*& <br/>
*& <strong>Features:</strong>
*& <ul>
*& <li>Filter by BP type (All/Person/Organization)</li>
*& <li>Simulation mode for dry-run validation</li>
*& <li>Display only errors option</li>
*& <li>ALV output with validation results</li>
*& </ul>
*& <strong>ASSUMPTIONS:</strong>
*& <ul>
*& <li>Requires zcl_bp_processor_fv for processing logic</li>
*& <li>Uses zcx_bp_audit_fv for custom exceptions</li>
*& <li>Text elements must be maintained for translations</li>
*& </ul>
*&---------------------------------------------------------------------*
REPORT zbp_audit_fix_fv.

TABLES but000. " BUT000 table for SELECT-OPTIONS declaration

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*
* Block 1: Business Partner Selection Filters
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(15) TEXT-101. " Label: Business Partner
    SELECT-OPTIONS s_partn FOR but000-partner.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.

* Block 2: BP Type Filter
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(15) TEXT-102. " Label: BP Type
    PARAMETERS p_tbp TYPE char01 AS LISTBOX VISIBLE LENGTH 20 DEFAULT 'A'.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

* Block 3: Execution Options
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-b03.
  " Simulation mode checkbox
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_sim   TYPE abap_bool AS CHECKBOX DEFAULT abap_true.
    SELECTION-SCREEN COMMENT 3(25) TEXT-c01. " Label: Run in simulation mode
  SELECTION-SCREEN END OF LINE.

  " Errors only filter checkbox
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_error TYPE abap_bool AS CHECKBOX DEFAULT abap_false.
    SELECTION-SCREEN COMMENT 3(25) TEXT-c02. " Label: Show errors only
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b3.

*----------------------------------------------------------------------*
* SCREEN EVENTS
*----------------------------------------------------------------------*

AT SELECTION-SCREEN OUTPUT.
  " Initialize BP type dropdown values
  PERFORM set_listbox.

*----------------------------------------------------------------------*
* MAIN LOGIC
*----------------------------------------------------------------------*
START-OF-SELECTION.

  TRY.
      " Execute BP validation processor with method chaining
      " Creates processor instance and runs validation in single call
      DATA(lt_rows) = NEW zcl_bp_processor_fv(
                            iv_simulation     = p_sim
                            iv_only_errors    = p_error
                            iv_bp_type_filter = p_tbp
                          )->run( it_partner = s_partn[] ).

      " Display ALV results if data exists
      IF lt_rows IS NOT INITIAL.
        zcl_bp_processor_fv=>display_alv( lt_rows ).
      ELSE.
        MESSAGE s004(zbp_msg) DISPLAY LIKE 'I'. " No data found
      ENDIF.

    CATCH zcx_bp_audit_fv INTO DATA(lx).
      " Handle custom audit exceptions
      MESSAGE lx TYPE 'E'.

    CATCH cx_root INTO DATA(lx_fatal).
      " Catch unexpected errors to prevent dumps
      MESSAGE lx_fatal->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

*----------------------------------------------------------------------*
* SUBROUTINES
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form SET_LISTBOX
*&---------------------------------------------------------------------*
*& Initializes dropdown values for BP type filter parameter.
*& Values: A=All, P=Person, O=Organization
*&---------------------------------------------------------------------*
FORM set_listbox.
  DATA: lt_values TYPE vrm_values,
        lv_id     TYPE vrm_id VALUE 'P_TBP'.

  " Load dropdown values using text symbols for translation support
  lt_values = VALUE #(
    ( key = 'A' text = TEXT-l01 ) " All
    ( key = 'P' text = TEXT-l02 ) " Person
    ( key = 'O' text = TEXT-l03 ) " Organization
  ).

  " Set dropdown values via VRM function
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = lv_id
      values          = lt_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

  IF sy-subrc <> 0.
    " Silent warning if dropdown initialization fails
    MESSAGE 'Error loading dropdown list' TYPE 'S' DISPLAY LIKE 'I'.
  ENDIF.
ENDFORM.