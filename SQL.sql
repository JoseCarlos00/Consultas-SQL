-- Consultar Ubicaciones
SELECT
    L.warehouse, 
    lista.location,
    L.location_type, L.allocation_zone, L.work_zone, L.locating_zone, L.multi_item, L.track_containers, L.location_sts AS status

FROM location L
RIGHT JOIN (
    VALUES 
    -- ('2-10-07-AA-01'),

) AS lista(location) ON lista.location = L.location
WHERE (L.location = lista.location OR l.location IS NULL)
ORDER BY lista.location;


--- consultar ubicaciones por asignar
SELECT DISTINCT item, allocation_loc FROM item_location_assignment
-- WHERE allocation_loc
WHERE item
in (

)

---
SELECT DISTINCT item, location, on_hand_qty FROM location_inventory
WHERE location 



-- Estatus del pedido
UPDATE shipment_header
SET trailing_sts=650, leading_sts=650
WHERE internal_shipment_num='1715542'

UPDATE shipment_detail
SET status1=650
WHERE internal_shipment_line_num IN ('19443403')
-- AND internal_shipment_num='1731141'

UPDATE shipping_container
SET status=650
WHERE  
--  internal_shipment_num='1753115'
 internal_container_num IN ('19490406', '19490407')


--___________________________________________________________________________

-- HUELLA
SELECT  UOM.item, UOM.conversion_qty
FROM Item_unit_of_measure UOM
WHERE UOM.company='FM'
AND UOM.sequence=2

	
--------------------------
DELETE item_location_assignment
WHERE QUANTITY_UM = 'CJ'
AND ALLOCATION_LOC LIKE '2-19-%'


UPDATE location_inventory 
SET LOGISTICS_UNIT = 'FMA0002772080', VOLUME_UM = 'CM3'
WHERE   warehouse='Mariano'  AND internal_location_inv IN ('56217267')
-----------------------------	

-- Verificar items
SELECT lista.item
FROM (
    VALUES
    -- ('item'),
    
) AS lista(item)
WHERE NOT EXISTS (
    SELECT 1
    -- FROM item
    FROM item_location_assignment item
    WHERE item.item = lista.item
);
