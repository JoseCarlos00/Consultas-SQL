SELECT 
    LI.warehouse, LI.internal_location_inv, LI.company, LI.location, LI.item, SUBSTRING(LI.item_desc, 1, 15) AS DESCRIPCION,
    LI.on_hand_qty, LI.ALLOCATED_QTY, LI.IN_TRANSIT_QTY, LI.SUSPENSE_QTY, LI.logistics_Unit,
    NULL AS shipment_id, NULL AS status1, NULL AS TOTAL_QTY, NULL AS requested_qty, NULL AS allocation_rejected_qty

FROM location_inventory LI
WHERE LI.warehouse = 'Tultitlan' AND LI.location = 'STG-01'

AND NOT EXISTS (
    SELECT 1
    FROM shipment_detail SD
    WHERE LI.item = SD.item AND SD.warehouse = 'Tultitlan' AND SD.status1 <> 999 AND SD.status1 <> 900
)

ORDER BY LI.item DESC

-- warehouse,internal_location_inv,company,location,item,item_desc,OH,AL,IT,SU,LP,shipment_id,status1,TOTAL_QTY,requested_qty,allocation_rejected_qty,