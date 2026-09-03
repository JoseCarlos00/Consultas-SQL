SELECT 
  Warehouse, Location, Location_sts AS status, Work_zone
--COUNT(*)
 FROM location
WHERE warehouse='Tultitlan' AND work_zone = 'W-Tul Producto Terminado'
 AND location_class<>'Shipping Dock' 
 AND location_type <> 'Piso'
 AND location NOT LIKE 'AMZ%'
 
ORDER BY location

-- @headers: Warehouse, Location, Status, Work_zone
