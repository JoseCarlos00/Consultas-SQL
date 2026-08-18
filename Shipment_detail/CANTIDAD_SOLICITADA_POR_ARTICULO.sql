SELECT 
ITEM, 
DESCRIPTION, 
CAST(SUM(TOTAL) AS INT) AS TOTAL, 
SUM(CAST((TOTAL/ HUELLA) AS DECIMAL(5, 2))) AS CAJAS,
CAST(HUELLA AS INT) AS HUELLA

FROM (
  SELECT 
  SD.item AS ITEM,
  REPLACE(SD.item_desc, ',', '.') AS DESCRIPTION,
 SD.total_qty AS TOTAL,
 UOM.conversion_qty AS HUELLA,
 SD.internal_shipment_line_num

FROM  shipment_detail SD
  INNER JOIN Item_unit_of_measure UOM
 ON SD.item = UOM.item

WHERE SD.status1 = '200'
AND SD.warehouse = 'Mariano'
AND SD.shipment_id LIKE '%-M-%'
AND SD.ITEM LIKE '1922-%'
-- AND SD.ITEM_DESC LIKE '%Past%'

AND UOM.sequence = '2'

GROUP BY SD.item, SD.item_desc, SD.total_qty, UOM.conversion_qty, SD.internal_shipment_line_num, SD.status1, SD.warehouse, SD.shipment_id, UOM.sequence
) AS PRINCIPAL

GROUP BY ITEM, DESCRIPTION, HUELLA

-- ITEM,DESCRIPTION,TOTAL,CAJAS,HUELLA,

-- Item y cantidad solicitadápor item