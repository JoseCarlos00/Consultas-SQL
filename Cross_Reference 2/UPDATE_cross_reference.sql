UPDATE item_cross_reference
SET X_REF_ITEM = CONCAT('0', X_REF_ITEM)
WHERE 
  company = 'FM'
  AND X_REF_ITEM LIKE '7%'
  AND item IN ();

-- ===========================

UPDATE item_cross_reference
SET X_REF_ITEM = STUFF(X_REF_ITEM, 1, 1, '')
WHERE 
  company = 'FM'
  AND X_REF_ITEM LIKE '07%'
  AND item IN ();

-- ===========================

SELECT 
  LEFT(ICR.item, CHARINDEX('-', ICR.item) - 1) AS EXTRAER_CODIGO,
  ITEM,
  STUFF(X_REF_ITEM, 1, 1, '') AS REMPLAZAR_CARACTER
FROM  item_cross_reference
WHERE X_REF_ITEM LIKE '7%'
AND company = 'FM'
-- AND ITEM IN ()
AND ITEM LIKE '1310-%';


-- ===========================
SELECT
    ITEM,
    sequence,

    LENGTH AS LENGTH_ACTUAL,
    CASE
        WHEN LENGTH > 70 THEN 70
        ELSE LENGTH
    END AS LENGTH_NUEVO,

    WIDTH AS WIDTH_ACTUAL,
    CASE
        WHEN WIDTH > 58 THEN 58
        ELSE WIDTH
    END AS WIDTH_NUEVO,

    HEIGHT AS HEIGHT_ACTUAL,
    CASE
        WHEN HEIGHT > 69 THEN 69
        ELSE HEIGHT
    END AS HEIGHT_NUEVO

FROM item_unit_of_measure

WHERE COMPANY = 'FM'
  AND sequence <> '3'
  AND ITEM LIKE '10034-%'
  AND (
       LENGTH > 70
       OR WIDTH > 58
       OR HEIGHT > 69
  );


-- ===========================

UPDATE item_unit_of_measure
SET 
    LENGTH = CASE WHEN LENGTH > 70 THEN 70 ELSE LENGTH END,
    WIDTH  = CASE WHEN WIDTH > 58 THEN 58 ELSE WIDTH END,
    HEIGHT = CASE WHEN HEIGHT > 69 THEN 69 ELSE HEIGHT END

WHERE COMPANY = 'FM'
  AND SEQUENCE <> '3'
  AND ITEM LIKE '10034-%'
  AND (
      LENGTH > 70
      OR WIDTH > 58
      OR HEIGHT > 69
  );
