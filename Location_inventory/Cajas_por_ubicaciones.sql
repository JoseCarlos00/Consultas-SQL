SELECT  
       LI.warehouse AS WAREHOUSE,
       LI.location AS LOCATION,
       LI.item AS ITEM,
       LI.item_color AS COLOR,
       LI.company AS COMPANY,
      CAST( LI.on_hand_qty AS INT) AS OH,
      CAST((LI.on_hand_qty / UOM.conversion_qty) AS DECIMAL(5, 2)) AS CAJAS,
       CAST(UOM.conversion_qty AS INT) AS Huella,
      ((LI.on_hand_qty + LI.IN_TRANSIT_QTY) - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS AV,
       LI.ALLOCATED_QTY AS AL,
       LI.IN_TRANSIT_QTY AS IT,
       LI.SUSPENSE_QTY AS SU,
       LI.logistics_Unit AS LP

FROM location_inventory LI
INNER JOIN Item_unit_of_measure UOM
ON LI.item = UOM.item

WHERE UOM.sequence = '2'
AND LI.warehouse = 'Mariano'

AND LI.location = 'LISTON-01'
ORDER BY 3, 2