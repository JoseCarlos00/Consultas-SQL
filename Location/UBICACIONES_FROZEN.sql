SELECT  
    L.warehouse,
    L.location,
    LI.item,
    LI.item_desc,
    L.location_type,
    L.allocation_zone,
    L.work_zone,
    L.locating_zone,
    L.multi_item,
    L.track_containers,
    L.location_sts AS status

FROM location L
INNER JOIN location_inventory LI
 ON LI.location = L.location

WHERE L.warehouse = 'Mariano'
AND L.location_sts = 'Frozen'
AND LI.ON_HAND_QTY > 0

GROUP BY 
      L.warehouse,
    L.location,
    LI.item,
    LI.item_desc,
    L.location_type,
    L.allocation_zone,
    L.work_zone,
    L.locating_zone,
    L.multi_item,
    L.track_containers,
    L.location_sts,
    LI.ON_HAND_QTY

ORDER BY L.location, LI.item