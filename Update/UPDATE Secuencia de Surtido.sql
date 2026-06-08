UPDATE LOCATION
SET 
    picking_seq = CASE
       --  WHEN LOCATION = '1-10-08-DD-11' THEN '41500'
        
        ELSE picking_seq
    END,
    
    putaway_seq = CASE
        --WHEN LOCATION = '1-10-08-DD-11' THEN '41500'
        
        ELSE putaway_seq
    END
WHERE 
    warehouse = 'Mariano' 
    AND work_zone = 'W-Mar Bodega 2'
    AND location IN (
        -- 'LOCATION',
    );
