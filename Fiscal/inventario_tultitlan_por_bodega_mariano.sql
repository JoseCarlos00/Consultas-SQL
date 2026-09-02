SELECT
  PRINCIPAL.ITEM, 
  PRINCIPAL.ITEM_DESC, 
  PRINCIPAL.COMPANY,
  CAST(SUM(PRINCIPAL.OH) AS INT) AS OH,
  CAST(SUM(PRINCIPAL.CAJAS) AS DECIMAL(10, 2)) AS CAJAS

FROM (

  SELECT
    L.work_zone, L.location_type, L.location_class,
    LI.LOCATION,
    LI.ITEM,
    REPLACE(LI.ITEM_DESC, ',', '.') AS ITEM_DESC,
    LI.COMPANY,
    LI.ON_HAND_QTY AS OH,
    LI.internal_location_inv,
    (LI.on_hand_qty / UOM.conversion_qty) AS CAJAS,
    LI.logistics_Unit AS LICENSE_PLATE


  FROM location_inventory LI
  INNER JOIN location L ON L.location = LI.location AND L.warehouse = 'Tultitlan'
  INNER JOIN item_unit_of_measure UOM ON LI.item = UOM.item AND UOM.sequence = '2'

  WHERE LI.warehouse='Tultitlan'
    AND L.warehouse='Tultitlan'
    AND L.location_type <> 'Piso'
    AND L.location_class = 'Inventory'
    AND L.work_zone IN ('W-Tul Producto Terminado', 'W-Tul Picos')
  
  GROUP BY LI.LOCATION, LI.ITEM, LI.ITEM_DESC, LI.COMPANY, LI.ON_HAND_QTY, LI.internal_location_inv, UOM.conversion_qty, LI.logistics_Unit, L.work_zone, L.location_type, L.location_class

) AS PRINCIPAL

INNER JOIN (
  SELECT DISTINCT
    LI.ITEM,
    L.WORK_ZONE
  
  FROM location_inventory LI
  INNER JOIN location L ON L.location = LI.location AND L.warehouse='Mariano'

 WHERE L.location_type LIKE 'Generica%S'
 AND LI.warehouse = 'Mariano'

  -- SELECCIONAR BODEGA
 AND L.work_zone = 'W-Mar Bodega 6'

) AS WORK_ZONE ON WORK_ZONE.ITEM = PRINCIPAL.ITEM


GROUP BY  PRINCIPAL.ITEM, PRINCIPAL.ITEM_DESC, PRINCIPAL.COMPANY, WORK_ZONE.WORK_ZONE

ORDER BY PRINCIPAL.ITEM

-- @headers: ITEM,ITEM_DESC,COMPANY,OH,CAJAS,
