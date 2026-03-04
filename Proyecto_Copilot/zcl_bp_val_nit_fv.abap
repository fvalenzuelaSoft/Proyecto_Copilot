"! <p class="shorttext synchronized">NIT (Número de Identificación Tributaria) Validator</p>
"! Validates Guatemalan NIT tax identification numbers.
"! <br/>
"! <strong>Responsibilities:</strong>
"! <ul>
"! <li>Validate NIT format (7-9 digits + 1 check digit)</li>
"! <li>Clean input by removing spaces, dots, and hyphens</li>
"! <li>Normalize to uppercase</li>
"! <li>Format output as XXXXXXX-X (base digits + hyphen + check digit)</li>
"! </ul>
"! <strong>ASSUMPTIONS:</strong>
"! <ul>
"! <li>Valid NIT = 7-9 numeric digits + 1 check digit (0-9 or K)</li>
"! <li>Empty/initial value = Error</li>
"! <li>Valid but reformatted = Warning with proposal</li>
"! <li>Invalid format = Critical error, no proposal</li>
"! </ul>
CLASS zcl_bp_val_nit_fv DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_bp_validator_fv.
ENDCLASS.



CLASS zcl_bp_val_nit_fv IMPLEMENTATION.

  METHOD zif_bp_validator_fv~validate.
    " Validates NIT format:
    " 1. Empty check -> Error
    " 2. Clean input (uppercase, remove spaces/dots/hyphens)
    " 3. Validate via regex (7-9 digits + check digit 0-9 or K)
    " 4. Build standard format XXXXXXX-X
    " 5. Return OK if valid and unchanged, Warning if reformatted, Error if invalid

    IF iv_value IS INITIAL.
      ev_ok       = abap_false.
      ev_proposal = ''.
      ev_message = 'NIT vacío'.
      RETURN.
    ENDIF.

    DATA(lv_original) = iv_value.
    DATA(lv_clean)    = iv_value.

    " Normalize: uppercase, no spaces, no dots, no hyphens
    TRANSLATE lv_clean TO UPPER CASE.
    CONDENSE lv_clean NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN lv_clean WITH ``.
    REPLACE ALL OCCURRENCES OF `-` IN lv_clean WITH ``.

    " Validate format: 7-9 digits followed by check digit (0-9 or K)
    FIND REGEX '^\d{7,9}[0-9K]$' IN lv_clean.

    IF sy-subrc = 0.
      DATA(lv_len)      = strlen( lv_clean ).
      DATA(lv_base_idx) = lv_len - 1.

      " Build standard format: base digits + hyphen + check digit
      ev_proposal = |{ lv_clean(lv_base_idx) }-{ lv_clean+lv_base_idx(1) }|.

      " Check if original already had correct format
      IF lv_original = ev_proposal.
        ev_ok      = abap_true.
        ev_message = 'NIT válido (Ya tenía el formato correcto)'.
      ELSE.
        " Format was corrected -> Warning level (Yellow)
        ev_ok      = abap_false.
        ev_message = |Se corrigió formato: de "{ lv_original }" a "{ ev_proposal }"|.
      ENDIF.
      RETURN.
    ENDIF.

    " Invalid NIT - cannot be automatically corrected (Critical error)
    ev_ok       = abap_false.
    ev_proposal = ''.
    ev_message  = 'NIT inválido: no se puede corregir automáticamente'.
  ENDMETHOD.

ENDCLASS.