SELECT DISTINCT
  L.work_zone,
  L.location,
  I.item,
  I.ITEM_COLOR,
  LI.ON_HAND_QTY,
  CONCAT(
    CAST(ILC.MAXIMUM_QTY AS INT),
    ' ',
    ILC.quantity_um
  ) AS CAPACIDAD,
  CONCAT(CAST((LI.ON_HAND_QTY / (UOM.conversion_qty * ILC.MAXIMUM_QTY)) * 100 AS DECIMAL(5, 2)), ' ', '%') AS PORCENTAJE


FROM location_inventory LI
  LEFT OUTER JOIN item_location_capacity ILC ON ILC.item = LI.item
  INNER JOIN location L ON L.location = LI.location
  INNER JOIN item I ON I.item = LI.item AND I.company = 'FM'

INNER JOIN (
  SELECT
  ILC.ITEM AS ITEM, 
  ILC.quantity_um AS CAPACIDAD_TYPE, 
  ILC.MAXIMUM_QTY AS CAPACIDAD_QTY,
  UOM.conversion_qty AS HUELLA_CJ, 
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
  LEFT JOIN item_location_capacity ILC  ON  ILC.item = UOM.item 

  WHERE UOM.sequence='2'
  AND ILC.company='FM'
  AND UOM.company='FM'
  AND ILC.ITEM IN ('8015-62-14216','10349-10941-12701','4919-3203-7828','6220-342-29711','8095-5347-34273','1707-11395-29589','10606-8024-28824','1960-4850-5646','1953-4851-12111','1954-5009-12256','4728-7873-3217')
  
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

AND ((LI.ON_HAND_QTY / (UOM.conversion_qty * ILC.MAXIMUM_QTY)) * 100) < 50

ORDER BY L.location
-- WORK_ZONE,LOCATION,ITEM,ITEM_COLOR,OH,CAPACIDAD,PORCENTAJE,
