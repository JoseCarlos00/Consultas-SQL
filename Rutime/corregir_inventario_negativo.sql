UPDATE location_inventory
SET ON_HAND_QTY = ABS(ON_HAND_QTY)
WHERE warehouse = 'Mariano'
    AND ON_HAND_QTY < 0

UPDATE location_inventory
SET ALLOCATED_QTY= ABS(ALLOCATED_QTY)
WHERE warehouse = 'Mariano'
    AND ALLOCATED_QTY< 0

UPDATE location_inventory
SET IN_TRANSIT_QTY= ABS(IN_TRANSIT_QTY)
WHERE warehouse = 'Mariano'
    AND IN_TRANSIT_QTY< 0;
