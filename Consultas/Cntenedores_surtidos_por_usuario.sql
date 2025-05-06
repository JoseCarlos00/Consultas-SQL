SELECT
  TH.internal_id,
  TH.reference_id,
  TH.activity_date_time,
  TH.location,
  TH.quantity,
  TH.item,
  TH.user_name,
  container.parent_container_id,
  container.quantity,
  container.item,
  container.status
  
FROM transaction_history TH
LEFT OUTER JOIN (
  SELECT 
    SC.parent_container_id,
    SC.quantity,
    SC.item,
    SC.status
  FROM shipping_container SC
  INNER JOIN shipment_header SH ON SH.internal_shipment_num = SC.internal_shipment_num
  -- AND SH.trailing_sts < 900 AND SH.leading_sts < 900
  WHERE SH.customer_name = 'Mex-Mylin'
  
) AS container ON container.item = TH.item AND container.quantity = TH.quantity

WHERE TH.warehouse = 'Mariano'

  AND TH.user_name = 'GabrielRamirez'
  AND TH.reference_id LIKE '1171-%'

  AND TH.transaction_type = 130
  AND TH.direction = 'From'
  AND TH.work_zone <> 'W-Mar Pick and Drop ELEV'
  AND TH.work_zone <> 'W-Mar Pick and Drop'
  AND CAST(TH.activity_date_time AS DATE) = CAST(GETDATE() AS DATE);
