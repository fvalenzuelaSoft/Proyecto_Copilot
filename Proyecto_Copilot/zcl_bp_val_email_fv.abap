"! <p class="shorttext synchronized">Email Address Validator</p>
"! Validates email addresses based on RFC 5322 simplified format.
"! <br/>
"! <strong>Responsibilities:</strong>
"! <ul>
"! <li>Validate email format using regex pattern</li>
"! <li>Normalize to lowercase and remove spaces</li>
"! <li>Propose corrected value when format changes are needed</li>
"! </ul>
"! <strong>ASSUMPTIONS:</strong>
"! <ul>
"! <li>Valid email = user@domain.tld (minimum 2 letter TLD)</li>
"! <li>Empty/initial value = Error</li>
"! <li>Valid but reformatted = Warning with proposal</li>
"! <li>Invalid format = Critical error, no proposal</li>
"! </ul>
CLASS zcl_bp_val_email_fv DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_bp_validator_fv.
ENDCLASS.



CLASS zcl_bp_val_email_fv IMPLEMENTATION.

  METHOD zif_bp_validator_fv~validate.
    " Validates email format:
    " 1. Empty check -> Error
    " 2. Normalize to lowercase and remove spaces
    " 3. Validate via RFC 5322 simplified regex
    " 4. Return OK if valid and unchanged, Warning if reformatted, Error if invalid

    IF iv_value IS INITIAL.
      ev_ok       = abap_false.
      ev_proposal = ''.
      ev_message  = 'Email vacío o no informado'.
      RETURN.
    ENDIF.

    DATA(lv_original) = iv_value.
    DATA(lv_clean)    = iv_value.

    TRANSLATE lv_clean TO LOWER CASE.
    CONDENSE lv_clean NO-GAPS.

    FIND REGEX '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$' IN lv_clean.

    IF sy-subrc = 0.
      ev_proposal = lv_clean.

      IF lv_original = ev_proposal.
        ev_ok      = abap_true.
        ev_message = 'Email válido'.
      ELSE.
        ev_ok      = abap_false.
        ev_message = |Se corrigió formato: de "{ lv_original }" a "{ ev_proposal }"|.
      ENDIF.
    ELSE.
      ev_ok       = abap_false.
      ev_proposal = ''.
      ev_message  = 'Email inválido. Se espera usuario@dominio.com'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.