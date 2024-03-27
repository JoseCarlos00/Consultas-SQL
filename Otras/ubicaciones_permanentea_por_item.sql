SELECT DISTINCT
  item,
  allocation_loc

FROM item_location_assignment 
WHERE item IN (
  
)



SELECT DISTINCT 
  li.item, l.location 
FROM location_inventory li
INNER JOIN location l ON l.location = li.location

WHERE li.warehouse = 'Mariano'
AND l.location_type = 'Generica Dinamico S'
-- AND l.location_type = 'Generica Permanente S'
AND li.item IN (

)