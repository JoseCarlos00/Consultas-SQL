SELECT 
CUSTOMER AS TIENDA,
Shipment_id AS ID_PEDIDO, ERP_ORDER,  ITEM AS ARTICULO, SUBSTRING(item_desc, 1, 20) AS DESCRIPCION, TOTAL_QTY AS TOTAL,
  CASE
        WHEN status1 = 100 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Pendiente por surtir'
        WHEN status1 = 200 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Pendiente por surtir'
        WHEN status1 = 201 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Pendiente por surtir'
        WHEN status1 = 300 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Pendiente por surtir'
        WHEN status1 = 301 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Surtiendose'
        WHEN status1 = 400 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Surtiendose'
        WHEN status1 = 401 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Surtiendose'
        WHEN status1 = 600 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Pendiente por Cargar'
        WHEN status1 = 650 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Pendiente por Cargar'
        WHEN status1 = 700 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Llega en la siguiente camioneta'
        WHEN status1 = 800 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Llega en la siguiente camioneta'
        WHEN status1 = 100 AND ALLOCATION_REJECTED_QTY > 0 THEN 'Pendiente por surtir sin inventario'
        ELSE ' '
  END AS ESTATUS, status1

FROM  shipment_detail 
WHERE  status1<>900
AND status1<>999
AND status1=100 

-- Verificar si el item existe en el inventario y negarlo
AND item NOT IN (
  SELECT  DISTINCT
  li.item
  FROM location_inventory li
  INNER JOIN location l ON li.location=l.location

  WHERE li.company<>'AMD'
  AND LI.warehouse='Mariano'
  AND (L.location_type<>'Muelle' OR L.location IN ('PRE-01', 'REC-01'))
  AND L.location_class<>'Shipping Dock' 
  AND (L.location_type<>'Piso' OR L.location IN ('ELEVADOR', 'REC-01', 'HOT-01', 'HOT-02', 'LISTONES-00', 'LISTONES-01'))

  -- Verificar si el item existe en el inventario
  AND on_hand_qty>0
)
-- order by 3
  ---  TIENDA, ID_PEDIDO, ERP_ORDER, ARTICULO, DESCRIPCION, TOTAL, ESTATUS, STATUS1,