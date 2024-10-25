SELECT 
  SH.trailing_sts AS Header_trailing_sts,
  SH.leading_sts  AS Header_leading_sts,
  SH.internal_shipment_num As  Header_internal_shipment_num,
  SH.shipment_id  AS Header_shipment_id,
  SH.shipping_load_num   AS Header_shipping_load_num,


  SD.ITEM AS  Detail_item,
  SD.status1 AS  Detail_status1,
  SD.internal_shipment_line_num  AS  Detail_internal_shipment_line_num,

  SC.status AS Container_status,
  SC.item  AS Container_item,
  SC.internal_container_num   AS Container_internal_container_num,
  SC.parent_container_id  AS Container_parent_container_id


FROM shipment_header SH 
INNER JOIN  shipment_detail SD ON SH.internal_shipment_num = SD.internal_shipment_num 
INNER JOIN shipping_container SC ON SD.internal_shipment_num = SC.internal_shipment_num AND SD.item = SC.item 

WHERE SD.status1 <> '999'
-- AND (SH.trailing_sts <> 700 OR SD.status1 <> 700)

--Header_trailing_sts,Header_leading_sts,Header_internal_shipment_num,Header_shipment_id,Header_shipping_load_num,Detail_item,Detail_status1,Detail_internal_shipment_line_num,Container_status,Container_item,Container_internal_container_num,Container_parent_container_id,

AND SC.parent_container_id IN (
-- 'AMD0001242181 ',

)
