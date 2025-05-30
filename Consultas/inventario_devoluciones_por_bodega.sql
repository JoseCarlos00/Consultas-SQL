SELECT
    ZONAS.WORK_ZONE AS WORK_ZONE,
    LI.LOCATION, 
    LI.ITEM, 
    REPLACE(LI.ITEM_DESC, ',', '.') AS DESCRIPTION, 
    LI.COMPANY, 
    CAST(LI.ON_HAND_QTY AS INT) AS OH,
    CAST((LI.on_hand_qty / UOM.conversion_qty) AS DECIMAL(10, 2)) AS CAJAS,
    ILA.allocation_loc AS PICKING

FROM 
    LOCATION_INVENTORY LI
INNER JOIN ITEM I ON I.ITEM = LI.ITEM AND I.COMPANY = 'FM'
INNER JOIN Item_unit_of_measure UOM ON I.ITEM = UOM.item AND UOM.sequence='2' AND UOM.company='FM'
INNER JOIN item_location_assignment ILA ON ILA.item = I.item AND ILA.quantity_um = 'PZ'


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

  ) 
  AS ZONAS ON ZONAS.item = LI.ITEM


WHERE 
    LI.WAREHOUSE = 'Mariano'
    AND LI.LOCATION = 'DEVOLUCIONES'
    -- AND I.ITEM_CATEGORY4 NOT LIKE '%NAV%MAD%'
    -- AND ZONAS.WORK_ZONE = 'W-Mar Bodega 8'

ORDER BY 1, 3

-- WORK_ZONE,LOCATION,ITEM,DESCRIPTION,COMPANY,OH,CAJAS,PICKING,
