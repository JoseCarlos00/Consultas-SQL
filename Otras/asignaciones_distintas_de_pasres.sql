SELECT 
ITEM, QUANTITY_UM

FROM  item_location_assignment 

WHERE ITEM IN (
  SELECT item
  FROM item_location_assignment   
  WHERE item NOT LIKE '4110-%'
    AND item NOT LIKE '1310-%' 
    AND item NOT LIKE '1346-%'
  GROUP BY item
)