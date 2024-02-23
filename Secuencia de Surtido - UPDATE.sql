UPDATE LOCATION
SET picking_seq = CASE
  WHEN location = '1-59-01-AA-01' THEN '372125'
                      
  ELSE '372125' END,
    putaway_seq = CASE
   WHEN location = '1-59-01-AA-01' THEN '372125'
                       

   ELSE '372125' END

   
WHERE warehouse = 'Mariano' 
    AND work_zone = 'W-Mar Bodega 2'
    AND location IN (

    );