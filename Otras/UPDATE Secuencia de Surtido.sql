UPDATE LOCATION
SET 
    (picking_seq, putaway_seq) = 
    CASE
        -- WHEN location = 'LOCATION' THEN ('372125', '372125')

  
        ELSE ('372125', '372125')
    END

WHERE 
    warehouse = 'Mariano' 
    AND work_zone = 'W-Mar Bodega 2'
    AND location IN (
      -- 'LOCATION'

    );
