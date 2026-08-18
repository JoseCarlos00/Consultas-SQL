SELECT 
    work_zone,
    location,
    item,
    ITEM_COLOR,
    PICKING_QTY,
    HUELLA_CAJA,
    CAPACIDAD,
    PORCENTAJE,
    INV_DISPONIBLE

FROM (
  SELECT DISTINCT
    L.work_zone,
    L.location,
    I.item,
    I.ITEM_COLOR,
    CAST(LI.ON_HAND_QTY AS INT) AS PICKING_QTY,
    UOM.HUELLA_CJ,
    CAST(IUOM.conversion_qty AS INT) AS HUELLA_CAJA,
    CONCAT(
      CAST(ILC.MAXIMUM_QTY AS INT),
      ' ',
      ILC.quantity_um,
      CASE
          WHEN UOM.CAPACIDAD_TOTAL IS NOT NULL
          THEN CONCAT(' - ', CAST(UOM.CAPACIDAD_TOTAL AS INT), ' PZ')
          ELSE ''
      END
    ) AS CAPACIDAD,
    CASE WHEN 
      (LI.ON_HAND_QTY / (UOM.HUELLA_CJ * ILC.MAXIMUM_QTY)) * 100 IS NOT NULL 
      OR 
      (LI.ON_HAND_QTY / UOM.CAPACIDAD_TOTAL) * 100 IS NOT NULL
    THEN
      CONCAT(
      CAST(
          CASE 
            WHEN UOM.CAPACIDAD_TYPE = 'CJ' THEN 
              (LI.ON_HAND_QTY / (UOM.HUELLA_CJ * ILC.MAXIMUM_QTY)) * 100
            WHEN UOM.CAPACIDAD_TYPE = 'PZ' THEN 
              (LI.ON_HAND_QTY / UOM.CAPACIDAD_TOTAL) * 100
            ELSE 
              NULL
          END 
          AS DECIMAL(10, 2)
        ), 
        ' %'
      ) ELSE NULL END AS PORCENTAJE,
      CAST(
          CASE 
            WHEN UOM.CAPACIDAD_TYPE = 'CJ' THEN 
              (LI.ON_HAND_QTY / (UOM.HUELLA_CJ * ILC.MAXIMUM_QTY)) * 100
            WHEN UOM.CAPACIDAD_TYPE = 'PZ' THEN 
              (LI.ON_HAND_QTY / UOM.CAPACIDAD_TOTAL) * 100
            ELSE 
              NULL
          END 
          AS DECIMAL(10, 2)) AS PORCENTAJE_NUMERIC,
      CAST(DISP.DISPONIBLE AS INT) AS INV_DISPONIBLE

  FROM location_inventory LI
  LEFT OUTER JOIN item_location_capacity ILC ON ILC.item = LI.item
  INNER JOIN location L ON L.location = LI.location
  INNER JOIN item I ON I.item = LI.item AND I.company = 'FM'

  LEFT OUTER JOIN (
    SELECT
    ILC.ITEM AS ITEM, 
    ILC.quantity_um AS CAPACIDAD_TYPE, 
    ILC.MAXIMUM_QTY AS CAPACIDAD_QTY,
    CAST(UOM.conversion_qty AS INT) AS HUELLA_CJ, 
    UOM.sequence AS HUELLA_UM,
    CONCAT(
      CAST(ILC.MAXIMUM_QTY AS INT),
      ' ',
      ILC.quantity_um
    ) AS CAPACIDAD,

    -- CAPACIDAD TOTAL
    CASE 
      WHEN ILC.quantity_um = 'PZ' THEN ILC.MAXIMUM_QTY
      WHEN ILC.quantity_um = 'CJ' THEN ILC.MAXIMUM_QTY * UOM.conversion_qty
      ELSE NULL END AS CAPACIDAD_TOTAL

    FROM item_unit_of_measure UOM
    LEFT JOIN item_location_capacity ILC ON ILC.item = UOM.item AND UOM.sequence='2' AND UOM.company='FM'

    WHERE 
      ILC.company='FM'
  ) AS UOM ON UOM.ITEM = LI.ITEM

  LEFT OUTER JOIN item_unit_of_measure IUOM ON LI.ITEM=IUOM.item AND IUOM.sequence='2' AND IUOM.company='FM'

  INNER JOIN (
      SELECT
          LI.ITEM,
          SUM(
              (LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY)
              - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)
          ) AS DISPONIBLE
      FROM location_inventory LI
      INNER JOIN LOCATION L
          ON L.location = LI.location
      WHERE LI.company = 'FM'
        AND LI.warehouse = 'Mariano'
        AND L.warehouse = 'Mariano'
        AND L.location_type IN ('Generica Dinamico R', 'Generica Permanente R', 'Generica Dinamico S','Generica Permanente S')
        AND ((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) > 0

        AND (
          -- CAMBIO AQUÍ
          L.work_zone <> 'W-Mar Bodega 5'
            OR (
              -- CAMBIO AQUÍ
                L.work_zone = 'W-Mar Bodega 5' AND L.location_type NOT IN ('Generica Permanente S', 'Generica Dinamico S')
            ))
        
      GROUP BY LI.ITEM
    ) AS DISP
      ON DISP.ITEM = LI.ITEM

WHERE LI.warehouse = 'Mariano' AND L.warehouse = 'Mariano' AND (ILC.location_type NOT LIKE 'Generica Permanente R' OR ILC.location_type IS NULL) AND L.location_type IN ('Generica Permanente S', 'Generica Dinamico S')

  -- CAMBIO AQUÍ
  AND L.work_zone = 'W-Mar Bodega 5'
) AS RESULT

WHERE (RESULT.PORCENTAJE_NUMERIC <= 50 OR PORCENTAJE_NUMERIC IS NULL)

ORDER BY RESULT.work_zone, RESULT.location, RESULT.item

-- @headers: BODEGA,UBICACION,ITEM,COLOR,INVENTARIO_PICKING,HUELLA_CAJA,CAPACIDAD,OCUPACION,DISPONIBLE_REPOSICION,
