/* ==== */
SELECT status1, total_qty, quantity_at_sts1, status2, quantity_at_sts2, * from  shipment_detail
  WHERE internal_shipment_line_num 
  IN ('24623514');

UPDATE shipment_detail
SET quantity_at_sts1 = 36
WHERE internal_shipment_line_num 
  IN ('24623514');


/* ==== INSERTAR PEDIMENTO EN LOCATION INVENTORY ATTRIBUTES ====== */
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


/* ========== */
UPDATE UOM
  SET UOM.conversion_qty = 576
FROM item_unit_of_measure UOM
WHERE UOM.sequence = 3 -- 2=CJ, 3=TARIMA
  AND UOM.item LIKE '11869-11991-%'

/* ========== */

SELECT * FROM SHIPPING_LOAD WHERE internal_load_num='42452'

UPDATE SHIPPING_LOAD 
  SET leading_sts=700, trailing_sts=700
WHERE internal_load_num='42452'



/* ========== */
UPDATE location_inventory 
SET LOGISTICS_UNIT = 'FMA0002772080', VOLUME_UM = 'CM3'
WHERE   warehouse='Mariano'  AND internal_location_inv IN ('56217267')
