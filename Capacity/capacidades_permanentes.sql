SELECT DISTINCT
    L.work_zone, 
    L.location,
    I.item,
    REPLACE(I.description, ',', '.') AS DESCRIPTION,
    CONCAT( CAST(ILC.MAXIMUM_QTY AS INT), ' ', ILC.quantity_um),
    NUEVA = NULL

FROM item_location_assignment ILA
LEFT JOIN item_location_capacity ILC  ON  ILC.item = ILA.item 
INNER JOIN location L  ON L.location = ILA.allocation_loc    
INNER JOIN item I  ON I.item = ILA.item   

WHERE I.company='FM'    
AND (ILC.location_type NOT LIKE 'Generica Permanente R' 
        OR  ILC.location_type IS NULL)
AND L.warehouse='Mariano'   
AND L.work_zone='W-mar Bodega 1'

ORDER BY 1,2

-- WORK_ZONE,LOCATION,ITEM,description,CAPACIDAD,NUEVA,
