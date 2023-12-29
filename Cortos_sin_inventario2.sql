SELECT 
CUSTOMER AS TIENDA,
Shipment_id AS ID_PEDIDO, ERP_ORDER,  ITEM AS ARTICULO, SUBSTRING(item_desc, 1, 20) AS DESCRIPCION, TOTAL_QTY AS TOTAL,
  CASE
        WHEN status1 = 100 AND ALLOCATION_REJECTED_QTY > 0 THEN 'Sin Inventario'
        ELSE ' ' 
  END AS ESTATUS

FROM  shipment_detail 
WHERE status1=100
AND ALLOCATION_REJECTED_QTY > 0

-- Verificar si el item existe en el inventario y negarlo
AND item NOT IN (
  SELECT  DISTINCT
  li.item
  FROM location_inventory li
  INNER JOIN location l ON li.location=l.location

  WHERE li.company<>'AMD'
  AND LI.warehouse='Mariano'
  AND (li.on_hand_qty>0 OR li.allocated_qty>0 OR li.in_transit_qty>0 OR li.suspense_qty>0 )

  AND (L.location_type<>'Muelle' OR L.location IN ('PRE-01', 'REC-01'))
  AND L.location_class<>'Shipping Dock' 
  AND (L.location_type<>'Piso' OR L.location IN ('ELEVADOR', 'REC-01', 'HOT-01', 'HOT-02', 'LISTONES-00', 'LISTONES-01'))

)  

AND Shipment_id LIKE '%-T-%'
AND warehouse='Mariano'

AND customer<>'BCN-Tijuana'


-- ORDER BY 3
--  TIENDA, ID_PEDIDO, ERP_ORDER, ARTICULO, DESCRIPCION, TOTAL, ESTATUS,