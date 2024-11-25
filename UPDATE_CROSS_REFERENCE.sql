INSERT INTO item_cross_reference (ITEM, X_REF_ITEM, COMPANY, USER_STAMP, DATE_TIME_STAMP, QUANTITY_UM, GTIN_ENABLED)
VALUES 
-- ('ITEM', 'CODIGO_DE_BARRAS', 'FM', 'JoseCarlos', DATEADD(HOUR, 6, GETDATE()), 'PZ', 'N'),


UPDATE item_cross_reference
SET X_REF_ITEM = CONCAT('0', X_REF_ITEM)
WHERE 
  company = 'FM'
  AND X_REF_ITEM LIKE '7%'
  AND item IN ();

UPDATE item_cross_reference
SET X_REF_ITEM = STUFF(X_REF_ITEM, 1, 1, '')
WHERE 
  company = 'FM'
  AND X_REF_ITEM LIKE '07%'
  AND item IN ();


SELECT ITEM, COUNT(*), MAX(X_REF_ITEM)
FROM  item_cross_reference
WHERE X_REF_ITEM LIKE '07%'
AND company = 'FM'
AND ITEM IN ()

GROUP BY ITEM
HAVING  COUNT(*) > 1
