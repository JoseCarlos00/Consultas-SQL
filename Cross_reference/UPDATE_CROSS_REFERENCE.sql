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


SELECT 
  LEFT(ICR.item, CHARINDEX('-', ICR.item) - 1) AS EXTRAER_CODIGO,
  ITEM,
  STUFF(X_REF_ITEM, 1, 1, '') AS REMPLAZAR_CARACTER
FROM  item_cross_reference
WHERE X_REF_ITEM LIKE '7%'
AND company = 'FM'
-- AND ITEM IN ()
AND ITEM LIKE '1310-%'

