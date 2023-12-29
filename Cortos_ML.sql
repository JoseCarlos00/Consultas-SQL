SELECT 
 SD.shipment_id AS SHIPMENT_ID,
 SD.ITEM,
 SUBSTRING(SD.item_desc, 1, 15) AS DESCRIPTION,
 CAST(SD.ALLOCATION_REJECTED_QTY AS INT) AS CORTO,
 LI.LOCATION, 
 CAST(CASE 
          WHEN (on_hand_qty - allocated_qty) > 0 THEN ((on_hand_qty + in_transit_qty) - (allocated_qty + suspense_qty))
          WHEN (on_hand_qty - suspense_qty) > 0 THEN ((on_hand_qty + in_transit_qty)- (suspense_qty + allocated_qty))
          WHEN in_transit_qty > 0 THEN in_transit_qty
          ELSE 0
      END AS INT) AS AV,
   CAST(on_hand_qty AS INT) AS OH, CAST(allocated_qty AS INT) AS AL, CAST(in_transit_qty AS INT) AS IT, CAST(suspense_qty AS INT) AS SU 


FROM shipment_detail SD
INNER JOIN location_inventory LI
ON LI.item=SD.item


WHERE SD.ALLOCATION_REJECTED_QTY>0
AND SD.status1=100
AND SD.warehouse='Mariano'
AND LI.warehouse='Mariano'
AND LI.location IN (SELECT location FROM location WHERE location_type LIKE 'Generica%S')

AND SD.erp_order LIKE '%-ML-%'
-- AND SD.shipment_id LIKE '%-C-%'

-- SHIPMENT_ID, ITEM, DESCRIPTION,CORTO, LOCATION, AV, OH, AL, IT, SU,


AND SD.item IN (
    SELECT  
      item
      
      FROM location_inventory
      WHERE company<>'AMD'
      AND warehouse='Mariano'
      AND (((on_hand_qty + in_transit_qty) - (allocated_qty + suspense_qty)) > 0 )
      
      AND location IN (
        SELECT DISTINCT location FROM location 
        WHERE  (location_type<>'Muelle' OR location IN ('PRE-01', 'REC-01'))
        AND location_class<>'Shipping Dock'
        AND (location_type<>'Piso' OR location IN ('ELEVADOR', 'REC-01', 'HOT-01', 'HOT-02', 'LISTONES-00', 'LISTONES-01')))

    GROUP BY ITEM, ON_HAND_QTY, ALLOCATED_QTY, IN_TRANSIT_QTY, SUSPENSE_QTY, internal_location_inv
  )
