SELECT  DISTINCT
    I.ITEM,
    I.ITEM_COLOR,
    I.ITEM_CATEGORY3

FROM item I 
INNER JOIN location_inventory LI
    ON LI.item = I.item

WHERE I.company='FM' 
AND LI.warehouse = 'Mariano'
AND LI.permanent = 'Y'
AND LI.location LIKE '2-19-%-AA-%'
-- AND I.item LIKE '2697-%'
-- AND (I.ITEM = '2697-10315-36306' OR I.ITEM = '2696-10311-36305')


ORDER BY I.ITEM;