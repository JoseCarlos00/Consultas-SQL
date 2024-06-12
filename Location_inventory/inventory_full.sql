SELECT 
  LI.warehouse AS WAREHOUSE,   
  LI.item AS ITEM,
  REPLACE(LI.ITEM_DESC, ',', '.') AS DESCRIPTION,
  LI.company AS COMPANY,
  L.location AS LOCATION,
  L.work_zone AS WORK_ZONE,
  CAST(((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS INT) AS AV,
  CAST(LI.ON_HAND_QTY AS INT) AS OH,
  CAST(LI.ALLOCATED_QTY AS INT) AS AL,
  CAST(LI.IN_TRANSIT_QTY AS INT) AS IT,
  CAST(LI.SUSPENSE_QTY AS INT) AS SU,
  LI.logistics_Unit AS LICENCE_PLATE,
  LI.internal_location_inv

FROM location_inventory LI
INNER JOIN location L ON L.location = LI.location

WHERE  
    L.location_class <> 'Shipping Dock' 
AND (L.location_class = 'Inventory' OR L.location IN ('ELEVADOR', 'PRE-01', 'REC-01'))
AND (LI.company = 'FM' OR LI.company = 'BF')

AND LI.item IN ( )

ORDER BY LI.warehouse, LI.item

-- WAREHOUSE,ITEM,DESCRIPTION,COLOR,COMPANY,LOCATION,WORK_ZONE,AV,OH,AL,IT,SU,LP,internal_location_inv,