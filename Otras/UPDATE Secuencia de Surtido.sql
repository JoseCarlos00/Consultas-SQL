UPDATE LOCATION
SET 
    picking_seq = CASE
       --  WHEN LOCATION = '1-10-08-DD-11' THEN '41500'
        
        ELSE '41500'
    END,
    
    putaway_seq = CASE
        --WHEN LOCATION = '1-10-08-DD-11' THEN '41500'
        
        ELSE '41500'
    END
WHERE 
    warehouse = 'Mariano' 
    AND work_zone = 'W-Mar Bodega 2'
    AND location IN (
        -- 'LOCATION',
    );
