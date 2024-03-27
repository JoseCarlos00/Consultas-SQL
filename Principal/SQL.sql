-- Consultar Ubicaciones
SELECT
L.warehouse, 
    lista.location,
 L.location_type, L.allocation_zone, L.work_zone, L.multi_item, L.track_containers, L.location_sts AS status

FROM location L
RIGHT JOIN (
    VALUES 
    -- ('2-10-07-AA-01'),

) AS lista(location) ON lista.location = L.location

WHERE (L.location = lista.location OR l.location IS NULL)
ORDER BY lista.location;


--- consultar ubicaciones por asignar
select distinct item, allocation_loc from item_location_assignment
-- where allocation_loc 
where item
in (

)

---
select distinct item, location, on_hand_qty from location_inventory
where location 



-- Estatus del pedido
UPDATE shipment_header
SET trailing_sts=650, leading_sts=650
where internal_shipment_num='1715542'

UPDATE shipment_detail
SET status1=650
where internal_shipment_line_num IN ('18884200')
-- AND internal_shipment_num='1731141'

UPDATE shipping_container
SET status=650
WHERE  
 internal_shipment_num='1753115'
--  internal_container_num IN ('1652908')


--__________________________________________________________________________
--Ubicaciones sin capacidad
SELECT   
	C.work_zone, C.location, D.item, D.ITEM_COLOR, B.MAXIMUM_QTY, B.quantity_um, B.location_type 

FROM location_inventory A 
LEFT JOIN item_location_capacity B  ON  B.item = A.item 
INNER JOIN location C   ON C.location = A.location    
INNER JOIN item D  ON D.item = A.item   

WHERE D.company='FM'    
AND (B.location_type NOT LIKE 'Generica Permanente R' 
        OR  B.location_type IS NULL)
AND C.location_type = 'Generica Permanente S'
and B.location_type IS NULL
and c.work_zone LIKE 'W-Mar Bodega%'
order by 1, 2
--___________________________________________________________________________

-- HUELLA
SELECT  UOM.item, UOM.conversion_qty
FROM Item_unit_of_measure UOM
WHERE UOM.company='FM'
AND UOM.sequence=2


--- CASE Surtidos
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

	--- Status de pedidos
	select distinct 
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


-- Verificar item
SELECT lista.item
FROM (
    VALUES
    
    
) AS lista(item)
WHERE NOT EXISTS (
    SELECT 1
    FROM item
    WHERE item.item = lista.item
);


-- Ubicaciones
SELECT distinct 
item, allocation_loc from item_location_assignment
where item
in (

)
