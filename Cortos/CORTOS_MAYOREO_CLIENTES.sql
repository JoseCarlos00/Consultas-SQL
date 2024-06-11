SELECT
  CUSTOMER, ITEM, DESCRIPTION, SUM(TOTAL) AS TOTAL,
  CAST((SUM(TOTAL) / HUELLA) AS DECIMAL(5, 2)) AS CAJAS,
  HUELLA

FROM (
  SELECT 
  CASE 
    WHEN SD.shipment_id LIKE '%-C-%' THEN 'CLIENTES' 
    WHEN SD.shipment_id LIKE '%-M-%' THEN 'MAYOREO'
    ELSE '' END  AS CUSTOMER,
  SD.item AS ITEM,
  SUBSTRING(SD.item_desc, 1, 16) AS DESCRIPTION,
  SD.total_qty AS TOTAL,
  CAST(UOM.conversion_qty AS INT) AS HUELLA,
  SD.internal_shipment_line_num

FROM shipment_detail SD
INNER JOIN Item_unit_of_measure UOM ON SD.item = UOM.item
 
WHERE SD.status1=100
  AND SD.ALLOCATION_REJECTED_QTY > 0
  AND SD.company='FM'
  AND SD.warehouse='Mariano'
  AND (SD.shipment_id LIKE '%-C-%' OR SD.shipment_id LIKE '%-M-%')
  AND UOM.sequence = '2'


GROUP BY SD.internal_shipment_line_num, SD.status1, SD.company, SD.warehouse, SD.shipment_id, SD.item, SD.item_desc, SD.total_qty, UOM.conversion_qty
) AS cosulta_principal

GROUP BY CUSTOMER, ITEM, DESCRIPTION, HUELLA

-- CUSTOMER,ITEM,ITEM_COLOR,TOTAL,CAJAS,