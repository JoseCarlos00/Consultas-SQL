SELECT 
  WAREHOUSE, LOCATION, ITEM, ITEM_COLOR, COMPANY,
  CAST(SUM(AV) AS INT) AS AV,
  CAST(SUM(OH) AS INT) AS OH,
  CAST(SUM(AL) AS INT) AS AL,
  CAST(SUM(IT) AS INT) AS IT,
  CAST(SUM(SU) AS INT) AS SU

FROM 
(
SELECT
  LI.WAREHOUSE,
  LI.LOCATION,
  LI.ITEM,
  LI.ITEM_COLOR,
  LI.COMPANY,
  ((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) -  (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS AV,
  LI.ON_HAND_QTY AS OH,
  LI.ALLOCATED_QTY AS AL,
  LI.IN_TRANSIT_QTY AS IT,
  LI.SUSPENSE_QTY AS SU,
  LI.internal_location_inv
 

FROM location_inventory LI
INNER JOIN location L
 ON L.location = LI.location


WHERE LI.warehouse='Mariano'
AND L.location LIKE '3%'

AND LI.item IN (
  SELECT ITEM
  FROM location_inventory LI
  INNER JOIN location L
 ON L.location = LI.location
 WHERE L.work_zone = 'W-Mar Bodega 6'
)

GROUP BY LI.WAREHOUSE, LI.LOCATION, LI.ITEM,
  LI.ITEM_COLOR,
  LI.COMPANY,
  LI.ON_HAND_QTY,
  LI.ALLOCATED_QTY,
  LI.IN_TRANSIT_QTY,
  LI.SUSPENSE_QTY,
  LI.internal_location_inv

) AS PRINCIPAL

GROUP BY WAREHOUSE, LOCATION, ITEM, ITEM_COLOR, COMPANY

ORDER BY 3, 2

-- WAREHOUSE,LOCATION,ITEM,ITEM_COLOR,COMPANY,AV,OH, AL, IT, SU,