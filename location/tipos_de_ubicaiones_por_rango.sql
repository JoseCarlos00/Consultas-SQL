SELECT 
    L.location, L.location_type, L.allocation_zone, L.work_zone, L.locating_zone, L.multi_item, L.track_containers, L.location_sts AS status
FROM location L

WHERE L.warehouse = 'Mariano'
AND L.location >= '1-90-01%'
AND L.location <= '1-90-05%'
--AND L.location LIKE '%BB%'

-- LOCATION,LOCATION_TYPE,ALLOCATION_ZONE,WORK_ZONE,LOCATING_ZONE,MULTI_ITEM,TRACK_CONTAINER,STATUS

