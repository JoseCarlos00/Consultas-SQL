SELECT
-- 1. La consulta final que selecciona las columnas
    company,
    ISNULL([1], 0) AS TOTAL_ITEMS_1_CAJA,
    ISNULL([2], 0) AS TOTAL_ITEMS_2_CAJAS,
    ISNULL([3], 0) AS TOTAL_ITEMS_3_CAJAS,
    ISNULL([1], 0) + ISNULL([2], 0) + ISNULL([3], 0) AS TOTAL_GENERAL

FROM (
    -- 2. La consulta de origen (SourceData)
    SELECT
        UOM.company,
        UOM.item,
        CAST(UOM.conversion_qty / UMM.conversion_qty AS INT) AS CAJAS_X_TARIMA
    FROM Item_unit_of_measure AS UOM
    INNER JOIN Item_unit_of_measure AS UMM
        ON UMM.item = UOM.item
        AND UMM.company = UOM.company
        AND UMM.sequence = 2
    WHERE UOM.sequence = 3
      AND UOM.company <> 'AMD'
      AND UMM.conversion_qty > 0

    AND UOM.item IN (
        SELECT DISTINCT ITEM
        FROM location_inventory LI 
        INNER JOIN location L ON L.location = LI.location
        
        WHERE LI.company <> 'AMD'
        --   AND LI.warehouse = 'Tultitlan'
        --   AND L.warehouse = 'Tultitlan'
          AND LI.on_hand_qty > 0
          AND L.location_class = 'Inventory'
    )
) AS SourceData

-- 3. El operador PIVOT
PIVOT (
    COUNT(item) -- 3a. Función de agregación
    FOR CAJAS_X_TARIMA -- 3b. Columna de pivote
    IN ([1], [2], [3]) -- 3c. Valores que se convertirán en columnas
) AS PivotTable

-- COMPANY,TOTAL_1_CAJA,TOTAL_2_CAJAS,TOTAL_3_CAJAS,TOTAL_GENERAL,
ORDER BY company;
