SELECT 
work_unit,
(COUNT(*) +1) AS num_filas
FROM Work_instruction WI 

WHERE WI.to_work_zone  LIKE 'W-Mar Bodega%'
AND WI.item IN (
  SELECT item FROM item WHERE company='FM' AND item_category4 LIKE '%NAV%'
)

GROUP BY work_unit