SELECT 
    LI.warehouse, LI.internal_location_inv, LI.company, LI.location, LI.item, SUBSTRING(LI.item_desc, 1, 15) AS DESCRIPCION, CAST(LI.on_hand_qty AS INT) AS OH, CAST(LI.ALLOCATED_QTY AS INT) AS AL, CAST(LI.IN_TRANSIT_QTY AS INT) AS IT, CAST(LI.SUSPENSE_QTY AS INT) AS SU, LI.logistics_Unit AS LP
    -- CONCAT('''', LI.internal_location_inv, '''') AS INTERNAL_NUM
    
FROM location_inventory LI

WHERE LI.warehouse = 'Tultitlan'
    AND LI.location = 'STG-01'
    AND LI.in_transit_qty = 0

AND NOT EXISTS (
    SELECT 1
    FROM shipment_detail SD
    WHERE LI.item = SD.item 
      AND SD.warehouse = 'Tultitlan' 
      AND SD.status1 NOT IN (900, 999)
      AND SD.status1 >= 650
)

ORDER BY LI.item DESC

-- @headers: warehouse,internal_location_inv,company,location,item,item_desc,OH,AL,IT,SU,LP
