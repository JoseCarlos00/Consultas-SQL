SELECT lista.item
FROM (
    VALUES
    -- ('item'),
    
) AS lista(item)
WHERE NOT EXISTS (
    SELECT 1
    FROM item
    -- FROM item_location_assignment item
    WHERE item.item = lista.item
);
