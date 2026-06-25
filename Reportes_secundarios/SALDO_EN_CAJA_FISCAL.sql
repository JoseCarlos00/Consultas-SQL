SELECT 
    A.warehouse, 
    A.PEDIMENTO,
    A.item AS ITEM, 
    A.item_color AS COLOR, 
    A.company AS COMPANY, 
    SUM(A.CAJAS) AS CAJAS,
    LOCATIONS
    
FROM 
(
    SELECT 
        LI.warehouse,     
        LI.item,
        LI.item_color,
        LI.company,
        ((CAST(LI.on_hand_qty AS INT)) /  CAST(UOM.conversion_qty AS INT)) AS CAJAS,
        LIA.loc_inv_attribute1 AS PEDIMENTO,
        LOCATIONS
    
    FROM 
        location_inventory LI
    INNER JOIN 
        Item_unit_of_measure UOM ON LI.item = UOM.item
    LEFT JOIN 
        location_inventory_attributes LIA ON LIA.OBJECT_ID = LI.loc_inv_attributes_id

    LEFT JOIN (
        SELECT
            loc_inv_attribute1,
            ITEM,
            STRING_AGG(LOCATION, ' - ') AS LOCATIONS
        FROM (
            SELECT DISTINCT LI.ITEM, LI.LOCATION, LIA.loc_inv_attribute1
            FROM location_inventory LI

            LEFT JOIN location_inventory_attributes LIA ON LIA.OBJECT_ID = LI.loc_inv_attributes_id
            WHERE LI.warehouse = 'Mariano'
            AND LI.company = 'BF'
        ) T

        GROUP BY ITEM, loc_inv_attribute1
    ) AS LOC ON LOC.ITEM = LI.item AND LOC.loc_inv_attribute1 = LIA.loc_inv_attribute1

    WHERE 
        UOM.sequence = '2'
        AND LI.company='BF'
        

    GROUP BY 
        LI.ITEM, LI.ITEM_COLOR, UOM.conversion_qty, LI.on_hand_qty, LI.company, LI.internal_location_inv, LI.warehouse, LIA.loc_inv_attribute1, LOCATIONS
) AS A

GROUP BY  
    A.item, A.item_color, A.company, A.warehouse, A.PEDIMENTO,LOCATIONS
ORDER BY 
    A.warehouse, A.PEDIMENTO, A.item

-- WAREHOUSE,PEDIMENTO,ITEM,COLOR,COMPANY,CAJAS,LOCATIONS,
