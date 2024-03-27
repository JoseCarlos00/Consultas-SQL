UPDATE location_inventory 
SET
    ON_HAND_QTY= CASE 
    -- WHEN location = 'LOCATION' AND ITEM = 'ITEM' THEN 'ON_HAND_QTY'

      ELSE '1' END
WHERE   
warehouse='Mariano' 
AND location IN (

)


