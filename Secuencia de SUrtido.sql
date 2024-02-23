SELECT  location
       ,location_type
       ,allocation_zone
       ,picking_seq
       ,putaway_seq
       ,work_zone
       ,multi_item
       ,track_containers
       ,location_sts
       ,allocate_in_transit
       ,warehouse
FROM LOCATION
WHERE warehouse = 'Mariano'
AND work_zone = 'W-Mar Bodega 2'
ORDER BY picking_seq