-- Consultar Ubicaciones
SELECT
warehouse, location, location_type, allocation_zone, work_zone, multi_item, track_containers, location_sts AS status
FROM location
 WHERE location IN (

)
ORDER BY 2


--- consultar ubicaciones por asignar
select distinct item, allocation_loc from item_location_assignment
where allocation_loc 
in (

)

select distinct item, location from location_inventory 
where  ON_HAND_QTY>0 AND location 


				Item_unit_of_measure = Item_UOM



-- Status del pedido
UPDATE shipment_header
SET trailing_sts=650, leading_sts=650
where internal_shipment_num='1493911'

UPDATE shipment_detail
SET status1=650
where internal_shipment_line_num IN ('17436320')
-- AND internal_shipment_num='1495908'

UPDATE shipping_container
SET status=650
WHERE  internal_container_num IN ('17653661')
-- AND internal_shipment_num='1663081'


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


select  A.item, A.conversion_qty, B.maximum_qty, B.MINIMUM_RPLN_PCT, B.quantity_um
from Item_unit_of_measure A
where A.company='FM'
and sequence=2


-- _______________________________________
-- 	-NAVIDAD SIN ASIGNAR-
-- ITEM, COLOR, CATEGORIA, LOCATION, OH,

select distinct
A.item, A.item_color, A.item_category4, B.location, B.on_hand_qty
from item A
inner join location_inventory B on A.item=B.item

where warehouse='Mariano'
and A. item_category4 like 'NAV%'
and A.item  not in (select distinct item from item_location_assignment)
and B.location in (select location from location where location_class='Inventory') 
and not B.location like '2-91-%'
and not B.location like '2-93-%'
order by 3, 1


-- _______________________________________________________________

select 
A.warehouse, A.company,A.location, A.item, A.item_color, B.conversion_qty as Huella, A.on_hand_qty, A.ALLOCATED_QTY, A.IN_TRANSIT_QTY, A.SUSPENSE_QTY, A.logistics_Unit

from location_inventory A
inner join Item_unit_of_measure B ON A.item=B.item

where A.warehouse='Tultitlan'
and B.sequence='2'
and A.on_hand_qty<B.conversion_qty
and A.location in (select location from location where work_zone='W-Tul Producto Terminado')




