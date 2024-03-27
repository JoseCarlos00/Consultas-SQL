SELECT 
  SUBSTRING(CONVERT(VARCHAR, NEW_DATE, 120), 9, 10) AS SUB_FECHA,
  ITEM,
  SUM(TOTAL_SUM) AS SUM_TOTAL
FROM 
(
  SELECT 
    SD.shipment_id,
    SD.ITEM AS ITEM, 
    SD.status1,
    DATEADD(HOUR, -6, SD.date_time_stamp) AS DATE,
    CAST(SD.TOTAL_QTY AS INT) AS TOTAL,
    SD.INTERNAL_SHIPMENT_LINE_NUM,
    CAST(SUM(SD.TOTAL_QTY) AS INT) AS TOTAL_SUM,
    CAST(DATEADD(HOUR, -6, SD.date_time_stamp) AS DATE) AS NEW_DATE

  FROM shipment_detail SD
  WHERE SD.warehouse = 'Mariano'
    AND SD.item IN ('5500-6371-7039', '7857-5256-1996', '8563-146-8508', '9865-7487-20951')
    AND CAST(DATEADD(HOUR, -6, SD.date_time_stamp) AS DATE) >= '2023-12-01' 
    AND CAST(DATEADD(HOUR, -6, SD.date_time_stamp) AS DATE) < '2023-12-08' -- Ajustado para incluir el último día
    AND SD.status1=900

  GROUP BY SD.item, SD.shipment_id, SD.status1, SD.INTERNAL_SHIPMENT_LINE_NUM, SD.date_time_stamp, SD.TOTAL_QTY

) AS DIAS

GROUP BY ITEM, NEW_DATE
