SELECT
    ROW_NUMBER() OVER (ORDER BY TH.internal_id) AS NumeroDeFila,
    TH.internal_id,
    TH.reference_id,
    TH.activity_date_time,
    TH.location,
    TH.quantity,
    TH.item,
    I.description,
    TH.user_name,
    TH.work_unit,
    container.parent_container_id,
    container.quantity AS container_quantity,
    container.item AS container_item,
    container.status,
    container.shipment_id
FROM transaction_history TH
LEFT OUTER JOIN (
    SELECT
        SC.parent_container_id,
        SC.quantity,
        SC.item,
        SC.status,
        SH.shipment_id
    FROM shipping_container SC
    INNER JOIN shipment_header SH ON SH.internal_shipment_num = SC.internal_shipment_num

    --- CAMBIAR AQUÍ
    WHERE SH.shipment_id LIKE '361-%'
     ---- CAMBIAR AQUÍ

) AS container ON container.item = TH.item AND container.quantity = TH.quantity AND container.shipment_id = TH.reference_id
INNER JOIN item I ON I.item = TH.item AND I.company = 'FM'
WHERE TH.warehouse = 'Mariano'

    --- CAMBIAR AQUÍ
  AND TH.user_name = 'Mariano06'
  AND TH.reference_id LIKE '361-%'
  -- AND TH.work_unit = '45102773'
    ---- CAMBIAR AQUÍ

  AND CAST(TH.activity_date_time AS DATE) = CAST(GETDATE() AS DATE)
  ---  AND CONVERT(date, DATEADD(hour, -6, TH.activity_date_time)) = 'AAAAMMDD'

  AND TH.transaction_type = 130
  AND TH.direction = 'From'
  AND TH.work_zone <> 'W-Mar Pick and Drop ELEV'
  AND TH.work_zone <> 'W-Mar Pick and Drop'

-- NO,INTERNAL_ID,REFERENCE_ID,ACTIVITY_DATE_TIME,LOCATION,QUANTITY,ITEM,COLOR,USER_NAME,WORK_UNIT,PARENT_CONTAINER_ID,CONTAINER_QTY,CONTAINER_ITEM,CONTAINER_STS,CONTAINER_SHIPMENT_ID,



