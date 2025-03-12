UPDATE location_inventory
SET inventory_sts = 'Held'
WHERE warehouse = 'Mariano'
AND location = 'NORECIBIDO'
AND inventory_sts <> 'Held' ;
