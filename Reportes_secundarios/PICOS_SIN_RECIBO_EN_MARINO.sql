SELECT
  SC.parent_container_id AS CONTAINER_ID,
  SC.item AS ITEM,
  CAST(SC.quantity AS INT) AS QUANTITY,
  ILA.allocation_loc AS LOC_PERMNENT,
  CONTAINER.CONTAINER_TULTI,
  CONTAINER.DATE_STAMP,
  CONTAINER.SHIPMENT_ID

FROM shipping_container SC
LEFT OUTER JOIN item_location_assignment ILA ON ILA.item = SC.item

INNER JOIN (
 SELECT  
  CONTAINER_ORIGINAL, CONTAINER_TULTI, CONTAINER_MARIANO,SHIPMENT_ID, DATE_STAMP, USUARIO

 FROM (
 SELECT
   SC.container_id AS CONTAINER_ORIGINAL,
   LEFT(SC.container_id, LEN(SC.container_id) - 1) AS CONTAINER_TULTI,
   DATEADD(hour, -6, SH.DATE_TIME_STAMP) AS DATE_STAMP,
   SH.shipment_id AS SHIPMENT_ID,
   SH.user_stamp AS USUARIO
 
   FROM shipping_container SC
   INNER JOIN shipment_header SH
    ON SC.internal_shipment_num = SH.internal_shipment_num
    
   WHERE SC.warehouse = 'Tultitlan'
   AND SH.shipment_id LIKE '%PICOS%'
   AND SC.container_id IS NOT NULL
   AND SC.status = 900
 ) AS TUL

 LEFT OUTER JOIN (
   SELECT
      container_id AS CONTAINER_MARIANO
  FROM  Receipt_Container
  WHERE receipt_id LIKE '%PICOS%' AND parent=0
 ) AS MAR ON MAR.CONTAINER_MARIANO = TUL.CONTAINER_TULTI
 
 WHERE CONTAINER_MARIANO IS NULL
) AS CONTAINER ON CONTAINER.CONTAINER_ORIGINAL = SC.parent_container_id

WHERE (ILA.quantity_um = 'PZ' OR ILA.allocation_loc IS NULL)
AND CONTAINER.DATE_STAMP > '20240612'

ORDER BY  CONTAINER.DATE_STAMP,SC.parent_container_id, SC.item

-- PARENT_CONTAINER_ID,ITEM,QUANTITY,LOC_PERMNENT,CONTAINER,DATE_STAMP,SHIPMENT_ID