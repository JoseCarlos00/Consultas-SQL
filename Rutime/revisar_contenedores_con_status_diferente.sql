SELECT 
  -- DISTINCT CONCAT('''', SD.internal_shipment_line_num, '''')
  CONCAT('''', SD.internal_shipment_line_num, '''') AS SD_internal_num, SD.internal_shipment_line_num , SH.trailing_sts AS SH_trailing_sts, SH.leading_sts AS SH_leading_sts, SH.internal_shipment_num As  SH_int_shipment_num, SH.shipment_id  AS SH_shipment_id,  SH.shipping_load_num  AS SH_shipping_load, SD.ITEM AS SD_item, SD.status1 AS SD_status1, SD.internal_shipment_line_num  AS  SD_internal_line_num, SC.status AS Container_sts, SC.item  AS Container_item, SD.total_qty AS SD_total_qty, SC.location AS Container_location, SC.internal_container_num  AS Container_internal_num, SC.parent_container_id  AS Parent_container_id

FROM shipment_header SH
INNER JOIN  shipment_detail SD ON SH.internal_shipment_num = SD.internal_shipment_num 
INNER JOIN shipping_container SC ON SD.internal_shipment_num = SC.internal_shipment_num AND SD.item = SC.item 

WHERE SD.status1 <> '999'
AND SD.status1 = 600 AND sc.status = 401
--AND SD.status1 <> sc.status AND SC.parent_container_id IN ()

-- @headers: Detail_internal_shipment_line_num,Detail_internal_shipment_line_num,Header_trailing_sts,Header_leading_sts,Header_internal_shipment_num,Header_shipment_id,Header_shipping_load_num,Detail_item,Detail_status1,Detail_internal_shipment_line_num,Container_status,Container_item,Detail_QTY,Container_location,Container_internal_container_num,Container_parent_container_id,
