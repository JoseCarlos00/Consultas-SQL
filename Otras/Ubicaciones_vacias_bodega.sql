SELECT 
  l.work_zone,
  l.location,
  li.item,
  SUBSTRING(li.item_desc, 1, 15) as description,
  ((li.on_hand_qty + li.in_transit_qty) - (li.allocated_qty + li.suspense_qty)) AS AV,
  li.on_hand_qty as OH,
  li.allocated_qty as AL,
  li.in_transit_qty as IT,
  li.suspense_qty AS SU

FROM location_inventory li  
INNER JOIN location l
ON l.location = li.location


WHERE li.warehouse = 'Mariano'
AND l.location_type LIKE 'Generica%S'
AND li.on_hand_qty = 0
AND l.work_zone = 'W-Mar Bodega 6'

-- WORK_ZONE,LOCATION,ITEM,DESCRIPTION,AV,OH,AL,IT,SU,