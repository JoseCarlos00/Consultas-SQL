SELECT 
  ITEM,COMPANY,SINCERO,CONCERO,COMP
  
FROM (
SELECT 
  ITEM, 
  COMPANY, 
  MAX(SINCERO) AS SINCERO, 
  CASE WHEN MAX(CONCERO) <> '' THEN CONCAT('CERO', MAX(CONCERO)) ELSE '' END AS CONCERO,
  CASE WHEN CONCAT('0', MAX(SINCERO)) = MAX(CONCERO) THEN 'IGUAL' 
      WHEN (MAX(SINCERO) <> '' AND MAX(CONCERO) <> '') THEN 'AMBOS'
  ELSE '' END AS COMP 

FROM (
  SELECT 
    ICR.item AS ITEM,
    CASE WHEN ICR.X_REF_ITEM LIKE '7%' THEN ICR.X_REF_ITEM ELSE '' END AS SINCERO,
    CASE WHEN ICR.X_REF_ITEM LIKE '07%' THEN ICR.X_REF_ITEM ELSE '' END AS CONCERO,
    ICR.X_REF_ITEM AS CODIGO,
    ICR.company AS COMPANY,
    ICR.internal_item_cross_num

  FROM item_cross_reference ICR
  INNER JOIN location_inventory LI ON ICR.item = LI.item
  INNER JOIN location L ON L.location = LI.location

  WHERE ICR.company <> 'AMD'
    AND LI.company <> 'AMD'
    AND L.warehouse = 'Mariano'
    AND L.location_class <> 'Shipping Dock' 
    AND (L.location_class = 'Inventory' OR L.location IN ('ELEVADOR', 'PRE-01', 'REC-01'))
    

    AND ( ICR.X_REF_ITEM LIKE '7%' OR ICR.X_REF_ITEM LIKE '07%')
    
    
) AS PRINCIPAL

GROUP BY ITEM, COMPANY
) AS SECONDARY

WHERE COMP = ''
AND COMPANY = 'FM' 

GROUP BY ITEM, COMPANY, SINCERO, CONCERO, COMP

ORDER BY ITEM, COMPANY

-- ITEM,COMPANY,SINCERO,CONCERO,COMP,
