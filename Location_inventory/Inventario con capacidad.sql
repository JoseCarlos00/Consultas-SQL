SELECT DISTINCT
    
    L.work_zone, 
    L.location,
    I.item,
    I.ITEM_COLOR,
    ((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS AV,
    LI.ON_HAND_QTY,LI.ALLOCATED_QTY,LI.IN_TRANSIT_QTY,LI.SUSPENSE_QTY,
    ILC.MAXIMUM_QTY AS CAPACIDAD,
    ILC.quantity_um

FROM location_inventory LI
LEFT JOIN item_location_capacity ILC ON ILC.item = LI.item 
INNER JOIN location L ON L.location = LI.location    
INNER JOIN item I ON I.item = LI.item   

WHERE I.company='FM'    
AND (ILC.location_type NOT LIKE 'Generica Permanente R' 
        OR  ILC.location_type IS NULL)
AND L.location_type='Generica Permanente S'
AND L.work_zone='W-Mar Bodega 10'
ORDER BY 2

WORK_ZONE,LOCATION,ITEM,COLOR,AV,OH,AL,IT,SU,QTY,UM,