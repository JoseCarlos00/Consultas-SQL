SELECT DISTINCT   
    I.item,
    I.item_color,
    CAST(ILC.MAXIMUM_QTY AS INT) AS MAXIMUM_QTY,
    ILC.quantity_um,
    ILC.MINIMUM_RPLN_PCT,
    ILC.location_type 
    
FROM item I
LEFT JOIN item_location_capacity ILC  ON  ILC.item = I.item 

WHERE I.company='FM'  
  AND (I.item_category1 <> 'Bulk' OR I.item_category1 IS NULL)
  AND (ILC.location_type NOT LIKE 'Generica Permanente R' OR  ILC.location_type IS NULL)
  AND I.item IN ()

ORDER BY I.item
