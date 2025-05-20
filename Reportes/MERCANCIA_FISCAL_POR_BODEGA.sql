SELECT
  LOCATION, 
  ITEM, 
  ITEM_DESC, 
  COMPANY,
  CAST(SUM(AV) AS INT) AS AV,
  CAST(SUM(OH) AS INT) AS OH,
  CAST(SUM(AL) AS INT) AS AL,
  CAST(SUM(IT) AS INT) AS IT,
  CAST(SUM(SU) AS INT) AS SU,
  CAST(SUM(CAJAS) AS DECIMAL(5, 2)) AS CAJAS
  -- ,CASE
  --       WHEN COUNT(LICENCE_PLATE) = 0 THEN ''
  --       WHEN COUNT(LICENCE_PLATE) > 1 THEN 'Multiple'
  --       ELSE MAX(LICENCE_PLATE)
  --   END AS LICENCE_PLATE

FROM (
SELECT
  L.WORK_ZONE,
  LI.LOCATION,
  LI.ITEM,
  REPLACE(LI.ITEM_DESC, ',', '.') AS ITEM_DESC,
  LI.COMPANY,
  ((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) -  (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS AV,
  LI.ON_HAND_QTY AS OH,
  LI.ALLOCATED_QTY AS AL,
  LI.IN_TRANSIT_QTY AS IT,
  LI.SUSPENSE_QTY AS SU,
  LI.internal_location_inv,
  (LI.on_hand_qty / UOM.conversion_qty) AS CAJAS,
  LI.logistics_Unit AS LICENCE_PLATE

FROM location_inventory LI
INNER JOIN location L ON L.location = LI.location
INNER JOIN Item_unit_of_measure UOM ON LI.item = UOM.item

WHERE LI.warehouse='Mariano'
AND L.warehouse = 'Mariano'
AND L.location LIKE '3%'
AND UOM.sequence = '2'
  
AND LI.item IN (
  SELECT ITEM
  FROM location_inventory LI
  INNER JOIN location L
 ON L.location = LI.location

  --- SELECIONAR BODEGA
 WHERE L.work_zone = 'W-Mar Bodega 6'
 AND L.location_type LIKE 'Generica%S'
)

GROUP BY
  LI.LOCATION,
  LI.ITEM,
  LI.ITEM_DESC,
  LI.COMPANY,
  LI.ON_HAND_QTY,
  LI.ALLOCATED_QTY,
  LI.IN_TRANSIT_QTY,
  LI.SUSPENSE_QTY,
  LI.internal_location_inv,
  UOM.conversion_qty,
  LI.logistics_Unit

) AS PRINCIPAL

GROUP BY LOCATION, ITEM, ITEM_DESC, COMPANY

ORDER BY LOCATION

-- LOCATION,ITEM,ITEM_DESC,COMPANY,AV,OH,AL,IT,SU,CAJAS,
