SELECT 
    work_zone,
    location,
    item,
    ITEM_COLOR,
    OH AS PICKING_QTY,
    CAPACIDAD,
    CAPACIDAD_TOTAL,
    PORCENTAJE, RESULT.PORCENTAJE_NUMERIC

FROM (
  SELECT DISTINCT
  L.work_zone,
  L.location,
  I.item,
  I.ITEM_COLOR,
  CAST(LI.ON_HAND_QTY AS INT) AS OH,
  CONCAT(
    CAST(ILC.MAXIMUM_QTY AS INT),
    ' ',
    ILC.quantity_um,
    CASE 
      WHEN ILC.quantity_um = 'PZ' THEN CONCAT(' -', CAST((ILC.MAXIMUM_QTY/UOM.HUELLA_CJ) AS INT), ' CJ')
      ELSE ''
    END
  ) AS CAPACIDAD,

  -- UOM.HUELLA_CJ,

  CONCAT(CAST(UOM.CAPACIDAD_TOTAL AS INT), ' PZ') AS CAPACIDAD_TOTAL,
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
  ) AS PORCENTAJE,
  CAST(
      CASE 
        WHEN UOM.CAPACIDAD_TYPE = 'CJ' THEN 
          (LI.ON_HAND_QTY / (UOM.HUELLA_CJ * ILC.MAXIMUM_QTY)) * 100
        WHEN UOM.CAPACIDAD_TYPE = 'PZ' THEN 
          (LI.ON_HAND_QTY / UOM.CAPACIDAD_TOTAL) * 100
        ELSE 
          NULL
      END 
      AS DECIMAL(10, 2)) AS PORCENTAJE_NUMERIC
  

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

  FROM Item_unit_of_measure UOM
  LEFT JOIN item_location_capacity ILC ON ILC.item = UOM.item AND UOM.sequence='2' AND UOM.company='FM'

  WHERE 
  ILC.company='FM'
  -- AND ILC.ITEM IN ('8015-62-14216','10349-10941-12701','4919-3203-7828','6220-342-29711','8095-5347-34273','1707-11395-29589','10606-8024-28824','1960-4850-5646','1953-4851-12111','1954-5009-12256','4728-7873-3217')
) AS UOM ON UOM.ITEM = LI.ITEM


WHERE LI.warehouse = 'Mariano'
  AND L.warehouse = 'Mariano'
  AND (
    ILC.location_type NOT LIKE 'Generica Permanente R'
    OR ILC.location_type IS NULL
  )
  AND L.location_type = 'Generica Permanente S' -- Verificar si el item existe en el inventario
  AND LI.ITEM IN (
    SELECT DISTINCT LI.item
    FROM location_inventory LI
      INNER JOIN LOCATION L ON L.location = LI.location
    WHERE LI.company = 'FM'
      AND LI.warehouse = 'Mariano'
      AND L.warehouse = 'Mariano'
      AND L.location_type IN (
        'Generica Dinamico R',
        'Generica Permanente R',
        'Generica Dinamico S',
        'Generica Permanente S'
      )
      AND (
        L.work_zone <> 'W-Mar Bodega 5' -- Cualquier ubicación fuera de Bodega 5
        OR (
          L.work_zone = 'W-Mar Bodega 5'
          AND L.location_type NOT IN ('Generica Permanente S', 'Generica Dinamico S')
        )
      )
      AND LI.on_hand_qty > 0
  )

  AND L.work_zone = 'W-Mar Bodega 5'
) AS RESULT

WHERE (RESULT.PORCENTAJE_NUMERIC <= 50 OR PORCENTAJE_NUMERIC IS NULL)

ORDER BY RESULT.work_zone, RESULT.location, RESULT.item

-- WORK_ZONE,LOCATION,ITEM,ITEM_COLOR,PICKING_QTY,CAPACIDAD,CAPACIDAD_TOTAL,PORCENTAJE,
