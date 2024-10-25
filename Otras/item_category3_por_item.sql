SELECT  DISTINCT
    LI.location,
    I.ITEM,
    REPLACE(I.DESCRIPTION, ',', '.'),
    I.ITEM_CATEGORY3

FROM item I 
INNER JOIN location_inventory LI ON LI.item = I.item
INNER JOIN  location L ON  LI.location = L.location


WHERE I.company='FM' 
AND LI.warehouse = 'Mariano'
AND L.warehouse  = 'Mariano'

AND L.location_type 'Generica%S'
-- AND L.WORK_ZONE = 'W-Mar Bodega 5'

ORDER BY 1
-- LOCATION, ITEM, DESCRIPTION,  ITEM_CATEGORY3,
