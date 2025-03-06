-- HUELLA
SELECT  UOM.item, UOM.conversion_qty
FROM Item_unit_of_measure UOM
WHERE UOM.company='FM'
AND UOM.sequence=2

	
--------------------------
DELETE item_location_assignment
WHERE QUANTITY_UM = 'CJ'
AND ALLOCATION_LOC LIKE '2-19-%'


UPDATE location_inventory 
SET LOGISTICS_UNIT = 'FMA0002772080', VOLUME_UM = 'CM3'
WHERE   warehouse='Mariano'  AND internal_location_inv IN ('56217267')
-----------------------------	


SELECT * FROM WORK_INSTRUCTION
-- UPDATE WORK_INSTRUCTION
SET CONDITION = 'Closed'
WHERE FROM_WHS = 'Mariano' AND  WORK_UNIT = 'T1911240624'
