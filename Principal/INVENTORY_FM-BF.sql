SELECT 
    ITEM,
    REPLACE(DESCRIPTION, ',', '.') AS DESCRIPTION,
    COLOR,
    CAST(SUM(CASE WHEN COMPANY = 'FM' AND WAREHOUSE  = 'Mariano' THEN AV ELSE 0 END) AS INT) AS FM_MAR,
    CAST(SUM(CASE WHEN COMPANY = 'BF' AND WAREHOUSE  = 'Mariano' THEN AV ELSE 0 END) AS INT) AS BF_MAR,
    CAST(SUM(CASE WHEN COMPANY = 'FM' AND WAREHOUSE  = 'Tultitlan' THEN AV ELSE 0 END) AS INT) AS FM_TUL,
    CAST(SUM(CASE WHEN COMPANY = 'BF' AND WAREHOUSE  = 'Tultitlan' THEN AV ELSE 0 END) AS INT) AS BF_TUL,
    CAST(SUM(OH) AS INT) AS TOTAL
FROM (
    SELECT 
        LI.warehouse AS WAREHOUSE,     
        LI.item AS ITEM,
        LI.item_desc AS DESCRIPTION,
        LI.item_color AS COLOR,
        LI.company AS COMPANY,
        ((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) AS AV,
        LI.on_hand_qty AS OH,
        LI.internal_location_inv

    FROM location_inventory LI
    INNER JOIN location L ON L.location = LI.location

    WHERE  
        L.location_class <> 'Shipping Dock' 
        AND (L.location_class = 'Inventory' OR L.location IN ('ELEVADOR', 'PRE-01', 'REC-01'))
        AND (LI.company = 'FM' OR LI.company = 'BF')

    GROUP BY LI.warehouse, LI.item, LI.item_color, LI.item_desc, LI.company, LI.on_hand_qty, LI.in_transit_qty, LI.allocated_qty,  LI.suspense_qty, LI.internal_location_inv
) AS principal

GROUP BY ITEM, DESCRIPTION, COLOR

HAVING 
  (SUM(CASE WHEN COMPANY = 'BF' AND WAREHOUSE = 'Mariano' THEN AV ELSE 0 END) > 0
    OR SUM(CASE WHEN COMPANY = 'BF' AND WAREHOUSE = 'Tultitlan' THEN AV ELSE 0 END) > 0)

ORDER BY ITEM

-- ITEM,DESCRIPTION,COLOR,FM_MAR,BF_MAR,FM_TUL,BF_TUL,