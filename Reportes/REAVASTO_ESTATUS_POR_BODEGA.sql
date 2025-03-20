SELECT
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
  INNER JOIN Item_unit_of_measure UOM ON I.ITEM=UOM.item AND UOM.sequence='2' AND UOM.company='FM'

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
