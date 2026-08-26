SELECT
    L.warehouse,
    LI.inventory_sts,
    L.location_sts,
    L.location,
    LI.item,
    REPLACE(LI.item_desc, ',', '.') AS item_desc,
    L.location_type,
    L.allocation_zone,
    L.work_zone,
    L.locating_zone,
    L.multi_item,
    L.track_containers

FROM location L

INNER JOIN location_inventory LI
    ON LI.location = L.location
    AND LI.warehouse = L.warehouse

WHERE L.warehouse = 'Mariano'
  AND (
        L.location_sts = 'Frozen'
        OR LI.inventory_sts = 'Held'
      )
  AND L.location_class = 'Inventory'

ORDER BY
    L.location,
    LI.item;
