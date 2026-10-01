SELECT 
  PRINCIPAL.ITEM,
  PRINCIPAL.ITEM_DESC,
  PRINCIPAL.COMPANY,
  CAST(SUM(AV) AS INT) AS AV,
  I.ITEM_CATEGORY4 AS GRUPO
  
FROM (
 SELECT
    L.WORk_ZONE,
    LI.ITEM,
    REPLACE(LI.ITEM_DESC, ',', '.') AS ITEM_DESC,
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

  WHERE L.warehouse='Tultitlan'
  AND LI.warehouse='Tultitlan'
  AND LI.company <> 'AMD'
  AND L.work_zone = 'W-Tul Producto Terminado' 
  AND L.location_class<>'Shipping Dock' 
  AND L.location_type <> 'Piso'
  AND L.location NOT LIKE 'AMZ%'

  GROUP BY 
    LI.LOCATION, LI.ITEM, LI.ITEM_DESC, LI.COMPANY, LI.ON_HAND_QTY, LI.ALLOCATED_QTY, LI.IN_TRANSIT_QTY, LI.SUSPENSE_QTY, LI.internal_location_inv,
    L.work_zone, L.warehouse, L.location_type, L.location_class, L.location_type, L.location
) AS PRINCIPAL

LEFT OUTER JOIN (SELECT ITEM, ITEM_CATEGORY4 FROM ITEM WHERE Company = 'FM' AND ITEM_CATEGORY1 <> 'Bulk') AS I on I.Item = PRINCIPAL.ITEM

GROUP BY PRINCIPAL.ITEM, PRINCIPAL.ITEM_DESC, PRINCIPAL.COMPANY, I.ITEM_CATEGORY4

ORDER BY PRINCIPAL.ITEM

-- @headers: ITEM,DESCRIPTION,COMPANY,AV,GRUPO,
