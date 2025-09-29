UPDATE location_inventory
SET
  IN_TRANSIT_QTY = 0
  -- ALLOCATED_QTY = 0

WHERE warehouse = 'Mariano' 
-- AND ALLOCATED_QTY > 0
AND location IN ()
AND item IN ()


----- CAMBIO DE HUELLA DE TARIMA A HUELLA DE CAJA POR UNA CANTIDAD ESPECIFICA
UPDATE UOM
SET UOM.conversion_qty = UMM.conversion_qty * 60 -- 60 CAJAS POR TARIMA

FROM Item_unit_of_measure UOM
INNER JOIN RECEIPT_DETAIL RD ON UOM.item = RD.item AND UOM.company = RD.company

INNER JOIN Item_unit_of_measure UMM ON UMM.item = UOM.item AND UMM.company = UOM.company AND UMM.sequence = 2

WHERE UOM.sequence = 3
  AND RD.INTERNAL_RECEIPT_NUM = 358034;


--------
UPDATE UOM
SET UOM.conversion_qty = 576
FROM Item_unit_of_measure UOM
WHERE UOM.sequence = 3 -- 2=CJ, 3=TARIMA
  AND UOM.item LIKE '11869-11991-%'

-----------
SELECT status1, quantity_at_sts1, status2, quantity_at_sts2, * from  shipment_detail
  WHERE internal_shipment_line_num 
  IN ('24623514');

UPDATE shipment_detail
SET quantity_at_sts1 = 36
WHERE internal_shipment_line_num 
  IN ('24623514');


--- INSERTAR PEDIMENTO EN LOCATION INVENTORY ATTRIBUTES
SELECT TOP 2 * FROM LOCATION_INVENTORY_ATTRIBUTES
WHERE LOC_INV_ATTRIBUTE1 = '25 20 9020 5008207'
ORDER BY 1 desc


INSERT INTO LOCATION_INVENTORY_ATTRIBUTES (LOC_INV_ATTRIBUTE1, USER_STAMP, PROCESS_STAMP, DATE_TIME_STAMP)
VALUES ('25 20 9020 5008207', 'ILSSRV', 'FANT_PedimentoInvAttribute', DATEADD(HOUR, 6, GETDATE()))

UPDATE location_inventory
SET
  COMPANY = 'BF',
  INVENTORY_STS = 'Available',
  LOC_INV_ATTRIBUTES_ID = '1423998'

WHERE warehouse = 'Tultitlan'
AND internal_location_inv = '72689752'

---
SELECT 
COUNT(DISTINCT LI.item) AS TOTAL_ITEMS
-- DISTINCT LI.ITEM, L.LOCATION, L.WORK_ZONE
FROM location_inventory LI
INNER JOIN location L 
  ON L.location = LI.location
WHERE LI.warehouse = 'Tultitlan' 
  AND L.warehouse = 'Tultitlan'
  AND LI.COMPANY = 'FM'
  AND L.location_class = 'Inventory'
  AND L.WORK_ZONE IN ('W-Tul Producto Terminado', 'W-Tul Picos', 'W-Tul Bodega Fiscal')
  

-- PICK_LOK
