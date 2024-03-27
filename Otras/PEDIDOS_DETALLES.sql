SELECT 
SH.SHIPMENT_ID AS SHIPMENT_ID_HEADER,
SH.trailing_sts,
SH.leading_sts,
DATEADD(HOUR, -6, SH.creation_date_time_stamp) AS DATE_HEADER, 
SD.SHIPMENT_ID AS SHIPMENT_ID_LINEAS,
SD.erp_order,
SD.status1,
DATEADD(HOUR, -6, SD.date_time_stamp) AS DATE_LINEAS


FROM shipment_header SH
INNER JOIN shipment_detail SD ON SD.shipment_id = SH.shipment_id

WHERE 
SH.warehouse='Mariano'
AND trailing_sts <> 900 AND leading_sts <> 900
-- AND DATEADD(HOUR, -6, SH.creation_date_time_stamp)<'20240101'
AND DATEADD(HOUR, -6, SD.date_time_stamp) <'20240101'
AND SD.status1 <> '999'
