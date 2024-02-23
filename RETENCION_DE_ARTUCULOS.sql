SELECT  DISTINCT
SD.shipment_id, SD.item, SD.item_desc, SD.status1

FROM shipment_detail SD
INNER JOIN shipment_header SH
ON SD.shipment_id = SH.shipment_id

WHERE SD.warehouse='Mariano'
AND SH.order_type = 'TDMX'
AND SD.status1 <> 900
AND SD.status1 <> 999
AND SD.status1 <> 700
AND SD.status1 <> 650
AND SD.shipment_id NOT LIKE '3407-%'
AND SD.shipment_id NOT  LIKE '3409-%'
AND SD.shipment_id NOT  LIKE '415-%'
AND SD.shipment_id NOT  LIKE '353-%'
AND SD.shipment_id NOT  LIKE '351-%'
AND SD.shipment_id NOT  LIKE '361-%'

AND SD.status1 = 300

AND SD.item <> '1723-1685-23231'
AND SD.item <> '8764-1506-5069'
AND SD.item <> '7230-3013-32048'
AND SD.item <> '1080-9016-26766'
AND SD.item <> '8444-5153-34184'
AND SD.item NOT LIKE '2332-9008-%'
AND SD.item_desc NOT LIKE '%UNICEL%'

AND SD.item IN (
  SELECT item FROM item WHERE company='FM' AND (
    item_desc LIKE '%ecologica%' OR
    item_desc LIKE '%bol%ecol%' OR
    item_desc LIKE '%globo%' OR
    item_desc LIKE '%glob%' OR
    item_desc LIKE '%mantel%' OR
    item_desc LIKE '%faldon%' OR
    item_desc LIKE '%BOL%CEL%' OR
    item_desc LIKE '%cortina%' OR 
    item_desc LIKE '%BOLSA%DE%CIERRE%' OR
    item_desc LIKE '%BOL%ADH%' OR
    item_desc LIKE '%BOLSA%IMP%' OR
    item_desc LIKE '%BOLSA%TERMOENCOGIBLE%' OR
    item_desc LIKE '%SOBRE%CEL%' OR
    item_desc LIKE '%CELOFAN%' OR
    item_desc LIKE '%BOLSA%MANTA%' OR
    item_desc LIKE '%BOLSA%MET%' OR

    item LIKE '8611-%' OR

    item='303-11275-9756' OR
    item='1114-854-26997' OR
    item='6249-10291-10827' OR
    item='4117-3719-18752' OR
    item='8444-5153-34184' OR
    item='9449-11298-20196' OR
    item='1138-11418-18474'
    )
)

ORDER BY 2