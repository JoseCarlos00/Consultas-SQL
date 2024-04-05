SELECT 
  LOCATION, ITEM, ITEM_COLOR,
  CAST(SUM(AV) AS INT) AS AV,
  CAST(SUM(OH) AS INT) AS OH,
  CAST(SUM(AL) AS INT) AS AL,
  CAST(SUM(IT) AS INT) AS IT,
  CAST(SUM(SU) AS INT) AS SU,
  HUELLA,
  CAJAS

FROM 
(
SELECT
  LI.LOCATION,
  LI.ITEM,
  LI.ITEM_COLOR,
  ((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) -  (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS AV,
  LI.ON_HAND_QTY AS OH,
  LI.ALLOCATED_QTY AS AL,
  LI.IN_TRANSIT_QTY AS IT,
  LI.SUSPENSE_QTY AS SU,
  LI.internal_location_inv,
  UOM.conversion_qty AS HUELLA,
  CAST((LI.on_hand_qty / UOM.conversion_qty) AS DECIMAL(5, 2)) AS CAJAS
 

FROM location_inventory LI
INNER JOIN location L
 ON L.location = LI.location

INNER JOIN Item_unit_of_measure UOM
 ON LI.item = UOM.item

WHERE UOM.sequence = '2'
AND LI.warehouse = 'Mariano'
AND  L.location_type NOT LIKE 'Gene%S'
AND L.work_zone = 'W-Mar Bodega 6'


GROUP BY LI.LOCATION, LI.ITEM,
  LI.ITEM_COLOR,
  LI.ON_HAND_QTY,
  LI.ALLOCATED_QTY,
  LI.IN_TRANSIT_QTY,
  LI.SUSPENSE_QTY,
  LI.internal_location_inv,
  LI.logistics_Unit,
  UOM.sequence,
  UOM.conversion_qty

) AS PRINCIPAL



GROUP BY LOCATION, ITEM, ITEM_COLOR, HUELLA, CAJAS

ORDER BY 1

-- LOCATION,ITEM,ITEM_COLOR,AV,OH,AL,IT,SU,HUELLA,CAJAS,