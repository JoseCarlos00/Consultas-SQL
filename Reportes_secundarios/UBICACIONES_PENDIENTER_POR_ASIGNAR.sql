SELECT 
  L.work_zone AS WORK_ZONE,
  L.location AS LOCATION,
  LI.item AS ITEM,
  REPLACE(LI.item_desc, ',', '.') AS DESCRIPTION,
   CAST(((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) -  (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS INT) AS AV,
  CAST(LI.ON_HAND_QTY AS INT) AS OH,
  CAST(LI.ALLOCATED_QTY AS INT) AS AL,
  CAST(LI.IN_TRANSIT_QTY AS INT) AS IT,
  CAST(LI.SUSPENSE_QTY AS INT) AS SU,
   CASE
    WHEN L.work_zone IN 
      ('W-Mar Bodega 1', 'W-Mar Bodega 2', 'W-Mar Bodega 3', 'W-Mar Bodega 4', 'W-Mar Bodega 5', 'W-Mar Bodega 6', 'W-Mar Bodega 7', 'W-Mar Bodega 8', 'W-Mar Bodega 9', 'W-Mar Vinil', 'W-Mar Mayoreo')
    THEN '1ER PISO'

    WHEN L.work_zone IN 
      ('W-Mar Bodega 10', 'W-Mar Bodega 11', 'W-Mar Bodega 12', 'W-Mar Bodega 13', 'W-Mar Bodega 14', 'W-Mar Bodega 15', 'W-Mar Bodega 16', 'W-Mar Bodega 17', 'W-Mar No Banda')
    THEN '2DO PISO'
  ELSE '' 
  END AS ZONA

  
FROM location_inventory LI
INNER JOIN location L 
  ON L.location = LI.location

WHERE L.warehouse = 'Mariano'
AND L.location_type = 'Generica Permanente S'
AND LI.permanent = 'N'
AND L.multi_item = 'N'
AND L.allocation_zone = 'A-Surtido Permanente'

-- WORK_ZONE,LOCATION,ITEM,DESCRIPTION,AV,OH,AL,IT,SU,ZONA