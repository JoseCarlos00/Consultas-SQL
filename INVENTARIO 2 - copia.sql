SELECT 
  P.LOCATION,
  P.ITEM,
  P.DESCRIPCION,
  SUM(P.PIEZAS) AS PIEZAS,
  SUM(P.PIEZAS) / UOM.conversion_qty AS CAJAS,
  P.PICK_LOCK,
  P.CAPACIDAD,
  LIPICK.PIEZAS AS PIEZAS_PICK,
  SUM(LIPICK.PIEZAS) / UOM.conversion_qty AS CAJAS_PICK,
  CONCAT(ROUND(CAST((((SUM(LIPICK.PIEZAS) / P.CAPACIDAD) / UOM.conversion_qty) * 100) AS DECIMAL(10, 2)), 2), '%') AS PORCENTAJE

FROM (
  SELECT
    L.location AS LOCATION,
    LI.ITEM AS ITEM,
    REPLACE(LI.ITEM_DESC, ',', '.') AS DESCRIPCION,
    (LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY - LI.ALLOCATED_QTY - LI.SUSPENSE_QTY) AS PIEZAS,
    ILA.allocation_loc AS PICK_LOCK,
    CAST(ILC.MAXIMUM_QTY AS INT) AS CAPACIDAD

  FROM location L
  INNER JOIN location_inventory LI ON L.location = LI.location
  LEFT JOIN item_location_capacity ILC ON ILC.item = LI.item AND (ILC.location_type NOT LIKE 'Generica Permanente R' OR ILC.location_type IS NULL)
  LEFT JOIN item_location_assignment ILA ON ILA.item = LI.item

  WHERE 
    L.warehouse = 'Mariano'
    AND L.location_type LIKE 'Generica%R'
    AND LI.warehouse = 'Mariano'
    AND LI.location LIKE '1-88%'
    AND LI.ITEM = '2504-6590-24377'
) AS P

LEFT JOIN (
  SELECT
    LI.LOCATION,
    (LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY - LI.ALLOCATED_QTY - LI.SUSPENSE_QTY) AS PIEZAS
  FROM location_inventory LI
  WHERE LI.warehouse = 'Mariano'
    AND LI.permanent = 'Y'
) AS LIPICK ON P.PICK_LOCK = LIPICK.LOCATION

INNER JOIN Item_unit_of_measure UOM ON P.ITEM = UOM.item

WHERE UOM.sequence = '2'

GROUP BY 
  P.LOCATION, 
  P.ITEM, 
  P.DESCRIPCION, 
  P.PICK_LOCK, 
  P.CAPACIDAD,
  UOM.conversion_qty,
  LIPICK.PIEZAS

HAVING SUM(P.PIEZAS) / UOM.conversion_qty <= 2
