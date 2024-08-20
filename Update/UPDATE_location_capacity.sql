UPDATE item_location_capacity
SET 
    MAXIMUM_QTY = CASE 
        -- WHEN ITEM = '1128-8879-26851' THEN '2'
  
        ELSE null
    END,
    MINIMUM_RPLN_PCT = CASE 
       --  WHEN ITEM = '1128-8879-26851' THEN '50'

        ELSE null
    END,
    QUANTITY_UM = 'CJ'
WHERE
    ITEM IN (
        -- '1128-8879-26851',
  
    )
    AND location_type = 'Generica Permanente S';
