SELECT 
  NumeroDeFila,
  INTERNAL_ID,
  DATE_TIME,
  PICK_LOC,
  TH_QTY,
  TH_ITEM,
  USER_NAME,
  WORK_UNIT,
  CONTAINER_ID,
  CONTAINER_QTY,
  CONTAINER_ITEM,
  SHIPMENT_ID

FROM (
  SELECT
      ROW_NUMBER() OVER (ORDER BY TH.internal_id) AS NumeroDeFila,
      TH.internal_id AS INTERNAL_ID,
      DATEADD(hour, -6, TH.activity_date_time) AS DATE_TIME,
      TH.location AS PICK_LOC,
      TH.quantity AS TH_QTY,
      TH.item AS TH_ITEM,
      TH.user_name AS USER_NAME,
      TH.work_unit AS WORK_UNIT,
      SD.shipment_id AS SHIPMENT_ID,
      SC.parent_container_id AS CONTAINER_ID,
      SC.quantity AS CONTAINER_QTY,
      SC.item AS CONTAINER_ITEM,
      SC.status AS CONTAINER_STS

  FROM transaction_history TH

  LEFT JOIN shipment_detail SD
    ON SD.erp_order_line_num = TH.reference_line_num

  LEFT JOIN shipping_container SC
      ON SC.internal_shipment_line_num = SD.internal_shipment_line_num

  WHERE TH.warehouse = 'Mariano'
    AND TH.reference_id LIKE '3405-%'
    AND TH.transaction_type = 130
    AND TH.direction = 'From'
    AND TH.work_zone <> 'W-Mar Pick and Drop ELEV'
    AND TH.work_zone <> 'W-Mar Pick and Drop'
    AND SC.quantity = TH.quantity
    AND SD.shipment_id = TH.reference_id

      --- CAMBIAR AQUÍ
    AND TH.user_name = 'LourdesCarreon'
    -- AND TH.reference_id LIKE '361-%'
    -- AND TH.work_unit = '45102773'

    AND CAST(TH.activity_date_time AS DATE) = CAST(GETDATE() AS DATE)
    ---  AND CONVERT(date, DATEADD(hour, -6, TH.activity_date_time)) = 'AAAAMMDD'

) AS RESULT

  -- NO,INTERNAL_ID,REFERENCE_ID,ACTIVITY_DATE_TIME,LOCATION,QUANTITY,ITEM,COLOR,USER_NAME,WORK_UNIT,PARENT_CONTAINER_ID,CONTAINER_QTY,CONTAINER_ITEM,CONTAINER_STS,CONTAINER_SHIPMENT_ID,
