SELECT DISTINCT
    L.work_zone, 
    L.location,
    I.item,
    I.ITEM_COLOR,
    CAST(ILC.MAXIMUM_QTY AS INT) AS QTY,
    NUEVA = NULL,
    ILC.quantity_um AS UM
    CASE
        WHEN L.location_type = 'Generica Permanente S' THEN 'PERMANENTE'
        WHEN L.location_type = 'Generica Dinamico S' THEN 'DINAMICO'
    ELSE '' END AS TIPO

FROM location_inventory LI
LEFT OUTER JOIN item_location_capacity ILC  ON  ILC.item = li.item 
INNER JOIN location L  ON L.location = LI.location    
INNER JOIN item I  ON I.item = LI.item   

WHERE I.company='FM'    
AND L.warehouse='Mariano'
AND (ILC.location_type NOT LIKE 'Generica Permanente R' OR  ILC.location_type IS NULL)
AND L.location_type LIKE 'Generica%S'
AND L.work_zone='W-mar Bodega 1'   

ORDER BY  L.location

-- WORK_ZONE,LOCATION,ITEM,COLOR,QTY,NUEVA,UM,TIPO,