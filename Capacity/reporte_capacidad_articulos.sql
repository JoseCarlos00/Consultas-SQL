SELECT DISTINCT   
    I.item,
    I.item_color,
    CONCAT(
      CAST(ILC.MAXIMUM_QTY AS INT),
      ' ',
      ILC.quantity_um
    ) AS CAPACIDAD,
    ILC.MINIMUM_RPLN_PCT,
    ILC.location_type 
    
FROM item I
LEFT JOIN item_location_capacity ILC  ON  ILC.item = I.item AND ILC.company = 'FM'

WHERE I.company='FM'  
  AND (I.item_category1 <> 'Bulk' OR I.item_category1 IS NULL)
  AND (ILC.location_type NOT LIKE 'Generica Permanente R' OR  ILC.location_type IS NULL)
  -- AND I.item IN ()
  AND I.item LIKE '1532-%'

ORDER BY I.item

-- @headers: ITEM,COLOR,CAPACIDAD,% DE REPOSICIÓN, LOCATION_TYPE,
