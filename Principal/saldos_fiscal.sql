SELECT 
    A.warehouse, 
    A.PEDIMENTO,
    A.item AS ITEM, 
    A.item_color AS COLOR, 
    A.company AS COMPANY, 
    SUM(A.CAJAS) AS CAJAS
    
FROM 
(
    SELECT 
        LI.warehouse,     
        LI.item,
        LI.item_color,
        LI.company,
        ((CAST(LI.on_hand_qty AS INT)) /  CAST(UOM.conversion_qty AS INT)) AS CAJAS,
        LIA.loc_inv_attribute1 AS PEDIMENTO   
    
    FROM 
        location_inventory LI
    INNER JOIN 
        Item_unit_of_measure UOM ON LI.item = UOM.item
    LEFT JOIN 
        location_inventory_attributes LIA ON LIA.OBJECT_ID = LI.loc_inv_attributes_id

    WHERE 
        UOM.sequence = '2'
        AND LI.company='BF'
        

    GROUP BY 
        LI.ITEM, LI.ITEM_COLOR, UOM.conversion_qty, LI.on_hand_qty, LI.company, LI.internal_location_inv, LI.warehouse, LIA.loc_inv_attribute1 
) AS A

GROUP BY  
    A.item, A.item_color, A.company, A.warehouse, A.PEDIMENTO
ORDER BY 
    A.warehouse, A.PEDIMENTO, A.item;
