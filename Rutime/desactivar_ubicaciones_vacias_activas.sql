UPDATE location
SET active='N'
WHERE warehouse='Mariano'
AND location IN
(
  SELECT L.location
  FROM Location L
  LEFT JOIN item_location_assignment ILA ON L.Location = ILA.allocation_loc AND ILA.quantity_UM = 'PZ'

  WHERE L.warehouse = 'Mariano'
  AND L.location_type IN ('Generica Dinamico S', 'Generica Permanente S')
  AND L.active = 'Y'
  AND L.location_sts = 'Empty'
  AND ILA.allocation_loc IS NULL
  AND L.work_zone <> 'W-Mar Salida Rapida'
  AND L.work_zone IS NOT NULL
);
