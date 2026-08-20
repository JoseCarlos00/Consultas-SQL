UPDATE item_location_capacity
SET
  MAXIMUM_QTY=2,
  QUANTITY_UM = 'CJ',
  MINIMUM_RPLN_PCT = 50
  
WHERE location_type = 'Generica Permanente S'
AND ITEM IN ();
