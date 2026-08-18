SELECT DISTINCT
  L.work_zone,
  L.location,
  I.item,
  I.ITEM_COLOR,
 CAST( LI.ON_HAND_QTY AS INT) AS OH,
  CAST(LI.ALLOCATED_QTY AS INT) AS AL
 

FROM location_inventory LI
  LEFT OUTER JOIN item_location_capacity ILC ON ILC.item = LI.item
  INNER JOIN location L ON L.location = LI.location
  INNER JOIN item I ON I.item = LI.item AND I.company = 'FM'

WHERE LI.warehouse = 'Mariano'
  AND L.warehouse = 'Mariano'
  AND (
    ILC.location_type NOT LIKE 'Generica Permanente R'
    OR ILC.location_type IS NULL
  )
  AND L.location_type = 'Generica Permanente S' -- Verificar si el item existe en el inventario
  AND LI.ITEM NOT IN (
    SELECT DISTINCT LI.item
    FROM location_inventory LI
      INNER JOIN LOCATION L ON L.location = LI.location
    WHERE LI.company = 'FM'
      AND LI.warehouse = 'Mariano'
      AND L.warehouse = 'Mariano'
      AND (L.location_type<>'Muelle' OR L.location IN ('PRE-01', 'REC-01'))
      AND L.location_class<>'Shipping Dock' 
      AND (L.location_type<>'Piso' OR L.location IN ('ELEVADOR', 'REC-01', 'HOT-01', 'HOT-02', 'LISTONES-00', 'LISTONES-01', 'DEVOLUCIONES'))
      AND (
        L.work_zone <> 'W-Mar Bodega 6' -- Cualquier ubicación fuera de Bodega 6
        OR (
          L.work_zone = 'W-Mar Bodega 6'
          AND L.location_type NOT IN ('Generica Permanente S', 'Generica Dinamico S')
        )
      )
      AND LI.on_hand_qty > 0
  )
  AND L.work_zone = 'W-Mar Bodega 6'

AND  LI.ON_HAND_QTY <= 25
AND  LI.ON_HAND_QTY > 0

ORDER BY L.location
-- WORK_ZONE,LOCATION,ITEM,ITEM_COLOR,OH,AL,
