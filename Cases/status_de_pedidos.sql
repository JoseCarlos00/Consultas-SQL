--- CASE Surtidos Original
CASE
        WHEN status1 = 100 AND ALLOCATION_REJECTED_QTY = 0 THEN 'In Pool'
        WHEN status1 = 200 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Wave Pending'
        WHEN status1 = 201 AND ALLOCATION_REJECTED_QTY = 0 THEN 'In Wave'
        WHEN status1 = 300 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Picking Pending'
        WHEN status1 = 301 AND ALLOCATION_REJECTED_QTY = 0 THEN 'In Picking'
        WHEN status1 = 400 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Packing Pending'
        WHEN status1 = 401 AND ALLOCATION_REJECTED_QTY = 0 THEN 'In Packing'
        WHEN status1 = 600 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Staging Pending'
        WHEN status1 = 650 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Loading Pending'
        WHEN status1 = 700 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Ship Confirm Pending'
        WHEN status1 = 800 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Load Confirm Pending'
        WHEN status1 = 900 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Closed'
        WHEN status1 = 999 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Rejeted'
        ELSE ' ' 
  END AS ESTATUS

	--- Status de pedidos -- SHIPMENT_ID,ERP_ORDER,STATUS,STATUS,
	SELECT DISTINCT 
shipment_id,
erp_order,
status1,
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
        WHEN status1 = 900 AND ALLOCATION_REJECTED_QTY = 0 THEN 'Enviado'
        WHEN status1 = 100 AND ALLOCATION_REJECTED_QTY > 0 THEN 'Pendiente por surtir sin inventario'
        ELSE ' ' 
    END AS ESTATUS
FROM  shipment_detail
WHERE company='FM'
AND warehouse='Mariano'
AND status1 <> 999
AND erp_order LIKE '3408-141%'
-- SHIPMENT_ID,ERP_ORDER,STATUS,STATUS,
