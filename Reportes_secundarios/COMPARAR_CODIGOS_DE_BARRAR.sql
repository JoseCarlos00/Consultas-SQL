SELECT 
  ITEM, 
  COMPANY, 
  MAX(SINCERO) AS SINCERO, 
  MAX(CONCERO) AS CONCERO
  -- COUNT(*)

FROM (
  SELECT 
    ICR.item AS ITEM,
    CASE WHEN ICR.X_REF_ITEM LIKE '7%' THEN ICR.X_REF_ITEM ELSE '' END AS SINCERO,
    CASE WHEN ICR.X_REF_ITEM LIKE '07%' THEN ICR.X_REF_ITEM ELSE '' END AS CONCERO,
    ICR.X_REF_ITEM AS CODIGO,
    ICR.company AS COMPANY,
    ICR.internal_item_cross_num
  FROM item_cross_reference ICR
  WHERE ICR.company <> 'AMD'
    AND ( ICR.X_REF_ITEM LIKE '7%' OR ICR.X_REF_ITEM LIKE '07%')
    
    AND ICR.item LIKE '6040-%' 
    -- AND (ICR.item LIKE '9320-%' OR ICR.item LIKE '9311-%')
) AS PRINCIPAL

GROUP BY ITEM, COMPANY
ORDER BY ITEM;

-- ----------------------------
-- UPDATE item_cross_reference
-- SET X_REF_ITEM = CONCAT('0', X_REF_ITEM)
-- WHERE company <> 'AMD'
--     AND X_REF_ITEM LIKE '7%'
--     AND X_REF_ITEM NOT LIKE '07%';

