---  TIENDA, ID_PEDIDO, ERP_ORDER, ARTICULO, DESCRIPCION, TOTAL, ESTATUS, STATUS1,
---  TIENDA; ID_PEDIDO; ERP_ORDER; ARTICULO; DESCRIPCION; TOTAL; ESTATUS; STATUS1;
SELECT 
CUSTOMER AS TIENDA, Shipment_id AS ID_PEDIDO, ERP_ORDER,  ITEM AS ARTICULO, SUBSTRING(item_desc, 1, 20) AS DESCRIPCION, TOTAL_QTY AS TOTAL,
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
    END AS ESTATUS, STATUS1

FROM  shipment_detail 
WHERE  status1<>900
AND status1<>999
AND  ERP_ORDER LIKE 'TIENDA-%'

ORDER BY 3

