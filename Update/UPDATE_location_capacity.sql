UPDATE item_location_capacity
SET 
    MAXIMUM_QTY = CASE 
        -- WHEN ITEM = '1128-8879-26851' THEN '2'
  
        ELSE 1 
    END,
    MINIMUM_RPLN_PCT = 50,
    QUANTITY_UM = 'CJ'
WHERE
    ITEM IN (
        -- '1128-8879-26851',
  
    )
    AND location_type = 'Generica Permanente S';
