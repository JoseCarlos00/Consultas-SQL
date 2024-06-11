SELECT 
    SD.previous_wave_num AS OLA,
    SD.shipment_id AS SHIPMENT_ID,
    SD.erp_order AS ERP_ORDER,
    SD.ITEM,
    SUBSTRING(SD.item_desc, 1, 15) AS DESCRIPTION,
    CAST(SD.TOTAL_QTY AS INT) AS CORTO

FROM 
    shipment_detail SD
INNER JOIN 
    location_inventory LI ON LI.item = SD.item
LEFT JOIN 
    location L ON LI.location = L.location AND L.location_type LIKE 'Generica%S' AND L.location_class <> 'Shipping Dock'  AND (L.location_class = 'Inventory' OR L.location IN ('ELEVADOR', 'PRE-01', 'REC-01'))

WHERE 
    SD.ALLOCATION_REJECTED_QTY > 0
    AND SD.status1 = 100
    AND SD.warehouse = 'Mariano'
    AND LI.warehouse = 'Mariano'
    AND SD.shipment_id LIKE '%-M-%'
