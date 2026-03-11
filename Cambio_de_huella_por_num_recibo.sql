DECLARE @NUM_CAJAS INT = 10;

UPDATE UOM
SET UOM.conversion_qty = UAM.conversion_qty * @NUM_CAJAS
FROM Item_unit_of_measure UOM
INNER JOIN Item_unit_of_measure UAM
    ON UOM.item = UAM.item
   AND UOM.company = UAM.company
   AND UAM.sequence = 2
INNER JOIN receipt_detail RD
    ON RD.item = UOM.item
   AND RD.company = UOM.company
WHERE UOM.sequence = 3
  AND RD.internal_receipt_num = 'INTERNAL_RECEIPT_NUMBER';

SELECT 
    UOM.item,
    Caja = UAM.conversion_qty,
    Tarima_actual = UOM.conversion_qty,
    Tarima_nueva = UAM.conversion_qty * 36
FROM Item_unit_of_measure UOM
INNER JOIN Item_unit_of_measure UAM
    ON UOM.item = UAM.item
   AND UOM.company = UAM.company
   AND UAM.sequence = 2
INNER JOIN receipt_detail RD
    ON RD.item = UOM.item
   AND RD.company = UOM.company
WHERE UOM.sequence = 3
  AND RD.internal_receipt_num = 'INTERNAL_RECEIPT_NUMBER';
