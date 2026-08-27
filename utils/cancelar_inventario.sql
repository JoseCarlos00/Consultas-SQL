SELECT
  SD.item,
  SD.total_qty,
  CASE 
    WHEN SD.status1 > 301 AND SD.status1 <= 600 THEN 'EMP-01'
    WHEN SD.status1 = 650 THEN  'STG-01'
    ELSE '' END AS FROM_LOC,
  ILA.allocation_loc AS TO_LOC,
  SD.status1

FROM shipment_detail SD
LEFT JOIN item_location_assignment ILA ON ILA.item = SD.item AND ILA.quantity_um = 'PZ'

WHERE SD.warehouse = 'Mariano'
  AND SD.status1 <> 999
  AND SD.total_qty > 0
  AND SD.erp_order LIKE '%-180200'
-- AND sd.status1 = 650

-- Primero ELIMINAR PEDIDO
-- Segundo hacer TRANSFERENCIA para regresar inventario a Picking
