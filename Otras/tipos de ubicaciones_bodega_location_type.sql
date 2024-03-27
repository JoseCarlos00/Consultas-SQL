SELECT 
  l.work_zone,
  l.location,
  l.location_type,
  l.allocation_zone,
  l.location_sts

FROM location l


WHERE l.warehouse = 'Mariano'
AND l.location > '1-90-01-AA-01' 
AND l.location  LIKE '1%' 
AND l.work_zone LIKE 'W-Mar Bodega%'


-- WORK_ZONE,LOCATION,LOCATION_TYPE,DESCRIPTION,allocation_zone,STATUS


-- 1-89-09 al 16