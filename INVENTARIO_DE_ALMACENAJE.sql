SELECT
    ZONAS.WORK_ZONE AS WORK_ZONE,
    LI.LOCATION, 
    LI.ITEM, 
    REPLACE(LI.ITEM_DESC, ',', '.') AS DESCRIPTION, 
    LI.COMPANY, 
    CAST(LI.ON_HAND_QTY AS INT) AS OH,
    CAST((LI.ON_HAND_QTY/UOM.conversion_qty) AS INT) AS CAJAS,
    FECHA 
    --,THR.USER_NAME
FROM LOCATION_INVENTORY LI
INNER JOIN Item_unit_of_measure UOM ON LI.ITEM=UOM.item AND UOM.sequence='2' AND UOM.company='FM'

LEFT OUTER JOIN (
    SELECT 
        TH.LOCATION,
        TH.ITEM,
        TH.USER_NAME,
         CONVERT(varchar, DATEADD(hour, -6, TH.date_time_stamp), 6) AS FECHA,
        TH.transaction_Type, 
        CASE 
            WHEN TH.transaction_Type = 60 THEN 'Inventory transfer'
            WHEN TH.transaction_Type = 140 THEN 'Putaway confirmation'
            WHEN TH.transaction_Type = 40 THEN 'Inventory adjustment'
            ELSE '' 
        END AS TIPO,
        ROW_NUMBER() OVER (PARTITION BY TH.ITEM ORDER BY TH.date_time_stamp ASC) AS RowNum
    FROM 
        Transaction_history TH
    WHERE 
        TH.warehouse = 'Mariano'
        AND TH.LOCATION IN ('ALMACENAJE', 'ALMACENAJE-02', 'ALMACENAJE-01')
        AND TH.transaction_type IN (60, 140, 40)
) AS THR 
ON LI.LOCATION = THR.LOCATION  
   AND LI.ITEM = THR.ITEM 
   AND THR.RowNum = 1


LEFT OUTER JOIN (	 
    SELECT 
    ITEM, WORK_ZONE, LOCATION, AV, OH, AL, IT, SU, NumFila
    FROM (
    SELECT
        CASE WHEN (l.work_zone LIKE 'W-Mar Bodega%' OR l.work_zone = 'W-Mar No Banda') AND l.work_zone <> 'W-Mar Bodega Fiscal' THEN l.work_zone ELSE '' END AS WORK_ZONE,
          li.item AS ITEM,
          CASE 
              WHEN l.location_type LIKE 'Generica%S' AND l.location NOT LIKE '0-%' THEN l.location 
              WHEN (li.item LIKE '4110-%' OR li.item LIKE '1310-%' OR li.item LIKE '1346-%') THEN l.location
              ELSE '' 
          END AS LOCATION,
          ROW_NUMBER() OVER (PARTITION BY li.item ORDER BY
              CASE
                  WHEN li.permanent='Y' THEN 1
                  WHEN (l.work_zone LIKE 'W-Mar Bodega%' OR l.work_zone = 'W-Mar No Banda') AND l.work_zone <> 'W-Mar Bodega Fiscal' THEN 2
                  WHEN l.work_zone IS NOT NULL THEN 3
                  ELSE 4
              END
          ) AS NumFila,
          
          ((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) AS AV,
          on_hand_qty AS OH, allocated_qty AS AL, in_transit_qty AS IT, suspense_qty AS SU

      FROM location_inventory li
      INNER JOIN location l ON l.location = li.location

      WHERE li.warehouse = 'Mariano'
      AND L.location_type LIKE 'Generica%S'

    ) AS FILAS

    WHERE NumFila=1

  ) AS ZONAS ON ZONAS.item = LI.ITEM


WHERE 
    LI.WAREHOUSE = 'Mariano'
    AND LI.LOCATION IN ('ALMACENAJE', 'ALMACENAJE-02', 'ALMACENAJE-01')
    -- AND ZONAS.WORK_ZONE = 'W-Mar Bodega 6'

ORDER BY 1, FECHA

-- WORK_ZONE,LOCATION,ITEM,DESCRIPTION,COMPANY,OH,CAJAS,FECHA,
