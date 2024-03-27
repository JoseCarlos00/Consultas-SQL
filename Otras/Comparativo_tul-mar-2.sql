SELECT
  li.item,
  MAX(CASE WHEN li.permanent = 'Y' OR loc.location_type = 'Generica Dinamico S' THEN 'Piking' END) AS PERMANENTE,
  MAX(CASE WHEN li.location = 'ELEVADOR' THEN 'Elevador' END) AS ELEVADOR,
  MAX(CASE WHEN li.location LIKE 'REC%' THEN 'REC' END) AS REC,
  MAX(CASE WHEN li.location LIKE 'PRE%' THEN 'PRE' END) AS PRE,
  MAX(CASE WHEN li.permanent <> 'Y' AND li.location <> 'ELEVADOR' AND li.location NOT LIKE 'REC%' AND li.location NOT LIKE 'PRE%' AND loc.location_type <> 'Generica Dinamico S'THEN 'Reserva' END) AS RESERVA
FROM location_inventory li
JOIN location loc ON li.location = loc.location

WHERE li.company <> 'AMD'
  AND li.on_hand_qty>0
  AND li.warehouse = 'Mariano'
  AND li.location IN (
    SELECT DISTINCT location
    FROM location
    WHERE
      location_type <> 'Muelle'
      AND location_class <> 'Shipping Dock'
      AND (location_type <> 'Piso' OR location IN ('ELEVADOR', 'REC-01'))
  )
AND li.item IN (

 )

GROUP BY li.item

ORDER BY li.item DESC;

-- ITEM, PERMANENTE, ELEVADOR, REC, PRE, RESERVA,
