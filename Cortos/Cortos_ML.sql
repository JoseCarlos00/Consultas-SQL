SELECT 

 SD.previous_wave_num AS OLA,
 SD.shipment_id AS SHIPMENT_ID,
 SD.ITEM,
 SUBSTRING(SD.item_desc, 1, 15) AS DESCRIPTION,
 CAST(SD.ALLOCATION_REJECTED_QTY AS INT) AS CORTO,
 LI.LOCATION, 
 CAST(((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) AS INT) AS AV,
 CAST(LI.on_hand_qty AS INT) AS OH, 
 CAST(LI.allocated_qty AS INT) AS AL, 
 CAST(LI.in_transit_qty AS INT) AS IT, 
 CAST(LI.suspense_qty AS INT) AS SU


FROM shipment_detail SD
INNER JOIN location_inventory LI
ON LI.item=SD.item


WHERE SD.ALLOCATION_REJECTED_QTY>0
AND SD.status1=100
AND SD.warehouse='Mariano'
AND LI.warehouse='Mariano'
AND LI.location IN (SELECT location FROM location WHERE location_type LIKE 'Generica%S')

AND SD.erp_order LIKE '%-ML-%'
-- AND SD.shipment_id LIKE '%-M-%'

-- SHIPMENT_ID, ITEM, DESCRIPTION,CORTO, LOCATION, AV, OH, AL, IT, SU,
