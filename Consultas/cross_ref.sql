SELECT 
    LEFT(ICR.item, CHARINDEX('-', ICR.item) - 1) AS CODIGO, 
    ICR.item AS ITEM,
    ICR.X_REF_ITEM AS CROSS_REF,
    I.ITEM_COLOR
FROM item_cross_reference ICR
INNER JOIN ITEM I ON ICR.item = I.item AND I.company = 'FM'

WHERE (ICR.X_REF_ITEM LIKE '7%' OR ICR.X_REF_ITEM LIKE '07%')
AND ICR.COMPANY = 'FM'
AND (
  -- (I.ITEM LIKE '11403-%' AND I.ITEM_COLOR LIKE '%Natural%' )
);

ORDER BY 1, I.ITEM_COLOR

-- excel: =+CONCATENAR("(I.ITEM LIKE '",ITEM,"-%' AND I.ITEM_COLOR LIKE '%",COLOR,"%' ) OR")
