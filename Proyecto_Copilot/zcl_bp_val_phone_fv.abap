"! <p class="shorttext synchronized">Phone Number Validator (Guatemala)</p>
"! Validates Guatemalan phone numbers with +502 country code.
"! <br/>
"! <strong>Responsibilities:</strong>
"! <ul>
"! <li>Validate phone format (+502 + 8 digits)</li>
"! <li>Clean input by removing spaces and hyphens</li>
"! <li>Auto-prepend country code when missing</li>
"! <li>Propose normalized value when format corrections are needed</li>
"! </ul>
"! <strong>ASSUMPTIONS:</strong>
"! <ul>
"! <li>Valid phone = +502 followed by exactly 8 digits</li>
"! <li>Empty/initial value = Error (optional field)</li>
"! <li>Accepts: +502XXXXXXXX, 502XXXXXXXX, or XXXXXXXX (8 digits)</li>
"! <li>Valid but reformatted = Warning with proposal</li>
"! <li>Invalid format = Critical error, no proposal</li>
"! </ul>
CLASS zcl_bp_val_phone_fv DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_bp_validator_fv.
ENDCLASS.



CLASS zcl_bp_val_phone_fv IMPLEMENTATION.

  METHOD zif_bp_validator_fv~validate.
    " Validates phone format:
    " 1. Empty check -> Error (optional field)
    " 2. Clean input (remove spaces, hyphens)
    " 3. Build proposal based on input pattern:
    "    - Already +502... -> keep as is
    "    - 502XXXXXXXX -> prepend +
    "    - 8 digits only -> prepend +502
    " 4. Validate via regex (+502 + 8 digits)
    " 5. Return OK if valid and unchanged, Warning if reformatted, Error if invalid

    IF iv_value IS INITIAL.
      ev_ok       = abap_false.
      ev_proposal = ''.
      ev_message  = 'Teléfono vacío (opcional)'.
      RETURN.
    ENDIF.

    DATA(lv_original) = iv_value.
    DATA(lv_clean)    = iv_value.
    CONDENSE lv_clean NO-GAPS.
    REPLACE ALL OCCURRENCES OF `-` IN lv_clean WITH ``.

    " Build proposal based on input pattern
    IF lv_clean CP '+502*'.
      " Case A: Already has correct format +502...
      ev_proposal = lv_clean.

    ELSEIF strlen( lv_clean ) = 11 AND lv_clean(3) = '502'.
      " Case B: Comes as 502XXXXXXXX -> prepend +
      ev_proposal = |+{ lv_clean }|.

    ELSEIF strlen( lv_clean ) = 8 AND lv_clean CO '0123456789'.
      " Case C: Only 8 digits -> prepend +502
      ev_proposal = |+502{ lv_clean }|.

    ELSE.
      ev_proposal = lv_clean.
    ENDIF.

    " Final validation: +502 followed by exactly 8 digits
    FIND REGEX '^\+502\d{8}$' IN ev_proposal.

    IF sy-subrc = 0.
      IF lv_original = ev_proposal.
        ev_ok      = abap_true.
        ev_message = 'Teléfono válido'.
      ELSE.
        ev_ok      = abap_false.
        ev_message = |Se corrigió formato: de "{ lv_original }" a "{ ev_proposal }"|.
      ENDIF.
    ELSE.
      ev_ok       = abap_false.
      ev_proposal = ''.
      ev_message  = 'Teléfono inválido. Se espera +502 seguido de 8 dígitos'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.