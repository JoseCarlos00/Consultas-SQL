SELECT  
       location,
       location_type,
       allocation_zone,
       picking_seq,
       putaway_seq,
       work_zone,
       multi_item,
       track_containers,
       location_sts AS status,
       allocate_in_transit,
       warehouse

FROM LOCATION

WHERE warehouse = 'Mariano'
AND work_zone = 'W-Mar Bodega 2'
AND location_type LIKE 'Generica%S'
ORDER BY picking_seq

-- LOCATION,LOCATION_TYPE,ALLOCATION_ZONE,PICKING_SEQ,PUTAWAY_SEQ,WORK_ZONE,MULTI_ITEM,TRACK_CONTAINERS,STATUS, ALLOCATE_IN_TRANSIT,WAREHOUSE,
