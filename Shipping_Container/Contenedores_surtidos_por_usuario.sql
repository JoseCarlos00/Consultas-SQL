SELECT 
    ROW_NUMBER() OVER (ORDER BY TH.internal_id) AS NO,
    TH.internal_id AS INTERNAL_ID,
    TH.item AS TH_ITEM,
    DATEADD(hour, -6, TH.activity_date_time) AS DATE_TIME,
    TH.location AS PICK_LOC,
    CAST(TH.quantity AS INT) AS TH_QTY,
    TH.user_name AS USER_NAME,
    TH.work_unit AS WORK_UNIT,
    SD.shipment_id AS SHIPMENT_ID,

    STRING_AGG(
        CAST(SC.parent_container_id AS VARCHAR(MAX)),
        ', '
    ) AS CONTAINER_IDS,
    
    CONCAT(
        ' Qty: ', CAST(MAX(SC.quantity) AS INT),
        ', Item: ', MAX(SC.item), ' '
    ) AS CONTAINER_DETAIL,

    COUNT(SC.parent_container_id) AS CONTAINER_COUNT

FROM transaction_history TH

LEFT JOIN shipment_detail SD
    ON SD.erp_order_line_num = TH.reference_line_num
   AND SD.shipment_id = TH.reference_id

LEFT JOIN shipping_container SC
    ON SC.internal_shipment_line_num = SD.internal_shipment_line_num
   AND SC.quantity = TH.quantity

WHERE TH.warehouse = 'Mariano'
  AND TH.transaction_type = 130
  AND TH.direction = 'From'
  AND TH.work_zone <> 'W-Mar Pick and Drop ELEV'
  AND TH.work_zone <> 'W-Mar Pick and Drop'

  AND SD.status1 <> 999
  AND SD.total_qty > 02

  AND CAST(TH.activity_date_time AS DATE) = CAST(GETDATE() AS DATE)
  ---  AND CONVERT(date, DATEADD(hour, -6, TH.activity_date_time)) = 'AAAAMMDD'

  /* CAMBIAR AQUÍ */
  AND TH.reference_id LIKE '3405-%'
  AND TH.user_name = 'Mariano06'
--   AND TH.work_unit = '45102773'
-- AND TH.ITEM IN ('12756-12766-27123', '12889-12705-28133')


GROUP BY
    TH.internal_id,
    TH.activity_date_time,
    TH.location,
    TH.quantity,
    TH.item,
    TH.user_name,
    TH.work_unit,
    SD.shipment_id

ORDER BY
    TH.internal_id;
