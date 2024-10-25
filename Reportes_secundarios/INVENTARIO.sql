SELECT 
  CP.LOCATION,
  CP.ITEM,
  CP.DESCRIPCION,
  CAST(UOM.conversion_qty AS INT) AS HUELLA_CJ,
  CAST(SUM(CP.PIEZAS) AS INT) AS PIEZAS,
  CAST((SUM(CP.PIEZAS) / UOM.conversion_qty) AS DECIMAL(10, 2)) AS CAJAS,
  CP.PICK_LOCK AS PICKING,
  CONCAT(CP.CAPACIDAD,  ' ', CP.CAP_UM) AS CAPACIDAD,
  CAST(LIPICK.PIEZAS AS INT) AS PICK_PIEZAS,
  CAST((LIPICK.PIEZAS / UOM.conversion_qty) AS DECIMAL(10, 2)) AS PICK_CAJAS,
  CASE 
    WHEN CP.CAP_UM = 'CJ' AND LIPICK.PIEZAS IS NOT NULL THEN CONCAT(ROUND(CAST((((LIPICK.PIEZAS / CP.CAPACIDAD) / UOM.conversion_qty) * 100) AS DECIMAL(10, 2)), 2), '%')
    WHEN CP.CAP_UM = 'PZ' AND LIPICK.PIEZAS IS NOT NULL  THEN CONCAT(CAST(((LIPICK.PIEZAS / CP.CAPACIDAD) * 100) AS DECIMAL(10, 2)), '%')
    ELSE '' END AS PORCENTAJE

FROM (
  SELECT
  L.location AS LOCATION,
  LI.ITEM AS ITEM,
  REPLACE(LI.ITEM_DESC, ',', '.') AS DESCRIPCION,
  LI.ON_HAND_QTY AS PIEZAS,
  ILA.allocation_loc AS PICK_LOCK,
  LI.internal_location_inv AS INTERNAL_NUM,
  CAST(ILC.MAXIMUM_QTY AS INT) AS CAPACIDAD,
  ILC.QUANTITY_UM AS CAP_UM

  FROM location L
  INNER JOIN location_inventory LI  ON L.location = LI.location
  LEFT JOIN item_location_capacity ILC  ON  ILC.item = LI.item  AND (ILC.location_type NOT LIKE 'Generica Permanente R' OR  ILC.location_type IS NULL)
  LEFT JOIN item_location_assignment   ILA  ON  ILA.item = LI.item OR ILA.ITEM IS  NULL

WHERE 
  L.warehouse = 'Mariano'
  AND L.location_type LIKE 'Generica%R'

  AND LI.warehouse  = 'Mariano'

-- RANGO DE PASILLOS
  AND LI.location >= '1-86-01-AA-01'
  AND LI.location < '1-92-01-AA-01'
) AS CP

LEFT JOIN (
  SELECT
    LI.location,
    (LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY - LI.ALLOCATED_QTY - LI.SUSPENSE_QTY) AS PIEZAS
  FROM location_inventory LI
  WHERE LI.warehouse = 'Mariano'
    AND LI.permanent = 'Y'
) AS LIPICK ON CP.PICK_LOCK = LIPICK.location

INNER JOIN Item_unit_of_measure UOM ON CP.ITEM = UOM.item AND UOM.sequence='2' AND UOM.company = 'FM'

GROUP BY 
  CP.LOCATION, 
  CP.ITEM, 
  CP.DESCRIPCION, 
  CP.PICK_LOCK, 
  CP.CAPACIDAD,
  CP.CAP_UM,
  UOM.conversion_qty,
  LIPICK.PIEZAS

  HAVING SUM(CP.PIEZAS) / UOM.conversion_qty <= 1 -- Cajas menores o igual a 1

  ORDER BY CP.LOCATION, CP.ITEM

-- LOCATION,ITEM,DESCRIPCION,HUELLA_CJ,PIEZAS,CAJAS,PICKING,CAPACIDAD,PICK_PIEZAS,PICK_CAJAS,PORCENTAJE,
