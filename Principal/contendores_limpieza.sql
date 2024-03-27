SELECT
SC.container_id,
CASE 
  WHEN SC.container_id LIKE '0%' THEN CONCAT('CERO', SUBSTRING(SC.container_id, 2, LEN(SC.container_id) - 1))  
  WHEN SC.container_id LIKE ',%' THEN CONCAT('COMA', SUBSTRING(SC.container_id, 2, LEN(SC.container_id) - 1))  
  ELSE SC.container_id END AS container_id,
SC.status, SH.shipment_id, FORMAT(SC.date_time_stamp, 'dd/MM/yyyy') AS DATE_CONTAINER, FORMAT(DATEADD(HOUR, -6, SH.creation_date_time_stamp), 'dd/MM/yyyy') AS DATE_PEDIDO,
CASE WHEN SC.container_id IN (
'AMD0001221256'
) THEN 'CON ERROR' ELSE '' END AS ERROR

FROM  shipping_container SC
INNER JOIN  shipment_header SH ON SH.internal_shipment_num=SC.internal_shipment_num

WHERE  SC.container_id IS NOT NULL
AND SC.warehouse='Mariano'
AND SC.status<>900
AND SC.status<>700
AND SH.trailing_sts<>900
-- AND (SC.status='401' OR SC.status='650')
AND SH.shipment_id LIKE '%-T-%'
AND SH.shipping_load_num='57083'
AND DATEADD(HOUR, -6, SH.creation_date_time_stamp)<'20231210'

ORDER BY 1

-- CONTAINER_ID1,CONTAINER_ID,STATUS,SHIPMENT_ID,DATE_CONTAINER,DATE_PEDIDO,ERROR,