UPDATE location_inventory
SET
  IN_TRANSIT_QTY = 0
  -- ALLOCATED_QTY = 0

WHERE warehouse = 'Mariano' 
-- AND ALLOCATED_QTY > 0
AND location IN ()
AND item IN ()


-----

UPDATE UOM
SET UOM.conversion_qty = UMM.conversion_qty * 12
FROM Item_unit_of_measure UOM
INNER JOIN RECEIPT_DETAIL RD 
    ON UOM.item = RD.item 
    AND UOM.company = RD.company
INNER JOIN Item_unit_of_measure UMM 
    ON UMM.item = UOM.item
    AND UMM.company = UOM.company
    AND UMM.sequence = 2
WHERE UOM.sequence = 3
  AND RD.INTERNAL_RECEIPT_NUM = 350609;


--------
UPDATE UOM
SET UOM.conversion_qty = 576
FROM Item_unit_of_measure UOM
WHERE UOM.sequence = 3 -- 2=CJ, 3=TARIMA
  AND UOM.item LIKE '11869-11991-%'

-----------


SELECT status1, quantity_at_sts1, status2, quantity_at_sts2, * from   shipment_detail
  WHERE internal_shipment_line_num 
  IN ('24416497');
