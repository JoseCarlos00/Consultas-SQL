UPDATE location_inventory 
SET
    ON_HAND_QTY= CASE 
    -- WHEN internal_location_inv = '82075376' THEN ON_HAND_QTY

      ELSE ON_HAND_QTY END

WHERE warehouse='Mariano' 
AND internal_location_inv IN (

);
