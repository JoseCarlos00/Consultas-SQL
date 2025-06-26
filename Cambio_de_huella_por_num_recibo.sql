UPDATE UOM
SET UOM.conversion_qty = RD.open_qty
FROM Item_unit_of_measure UOM
INNER JOIN RECEIPT_DETAIL RD 
    ON UOM.item = RD.item 
   AND UOM.company = RD.company
WHERE UOM.sequence = 3
  AND RD.INTERNAL_RECEIPT_NUM = 'ITERNAL_RECEIPT_NUMBER';
