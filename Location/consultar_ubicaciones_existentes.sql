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
