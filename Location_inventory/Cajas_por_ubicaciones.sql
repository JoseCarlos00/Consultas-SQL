SELECT  
 L.work_zone,
 L.location AS LOCATION,
 LI.item AS ITEM,
 LI.item_color AS COLOR,
 LI.company AS COMPANY,
 CAST(UOM.conversion_qty AS INT) AS Huella,
 CAST(((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS INT) AS AV,
 CAST(LI.ON_HAND_QTY AS INT) AS OH,
 CAST(LI.ALLOCATED_QTY AS INT) AS AL,
 CAST(LI.IN_TRANSIT_QTY AS INT) AS IT,
 CAST(LI.SUSPENSE_QTY AS INT) AS SU,
 CAST((LI.on_hand_qty / UOM.conversion_qty) AS DECIMAL(5, 2)) AS CAJAS,
 LI.logistics_Unit AS LP

FROM location_inventory LI

INNER JOIN Item_unit_of_measure UOM ON LI.item = UOM.item
INNER JOIN location L ON L.location = LI.location

WHERE UOM.sequence = '2'
AND L.warehouse = 'Mariano'
AND L.location_type LIKE 'Generica%'
AND L.location = 'LISTON-01'

ORDER BY L.location, LI.item

-- WORK_ZONE,LOCATION,ITEM,COLOR,COMPANYAV,HUELLA,AV,OH,AL,IT,SU,CAJAS,LP