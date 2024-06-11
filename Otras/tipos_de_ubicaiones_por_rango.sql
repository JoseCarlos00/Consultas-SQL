SELECT 
    L.location, L.location_type, L.allocation_zone, L.work_zone, L.locating_zone, L.multi_item, L.track_containers, L.location_sts AS status

FROM location L

WHERE L.warehouse = 'Mariano'
AND L.location >= '1-90-01-AA-01'
AND L.location <= '1-90-05-AA-01'
AND L.location  LIKE '1%' 
AND L.work_zone LIKE 'W-Mar Bodega%'


-- LOCATION,LOCATION_TYPE,ALLOCATION_ZONE,WORK_ZONE,LOCATING_ZONE,MULTI_ITEM,TRACK_CONTAINER,STATUS

