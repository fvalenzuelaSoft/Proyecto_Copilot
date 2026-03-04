@EndUserText.label : 'Tabla persistir valores corregidos por BP y campo'
@AbapCatalog.enhancementCategory : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zbp_bp_fix_fv {
  key mandt   : abap.clnt not null;
  key partner : bu_partner not null;
  key field   : abap.char(30) not null;
  key erdat   : erdat not null;
  key erzet   : erzet not null;
  old_value   : abap.char(255);
  new_value   : abap.char(255);
  status      : abap.char(1);
  message     : abap.char(255);
  ernam       : ernam;
}