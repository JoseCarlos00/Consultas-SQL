SELECT 
  ROW_NUMBER() OVER (ORDER BY item),
  item

FROM item_location_assignment

WHERE item IN ();
