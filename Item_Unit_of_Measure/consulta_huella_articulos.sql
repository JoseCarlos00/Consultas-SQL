SELECT
    I.ITEM,
    I.DESCRIPTION,

    STRING_AGG(
        CONCAT(
            CAST(UOM.conversion_qty AS INT),
            ' ',
            UOM.QUANTITY_UM
        ),
        ' / '
    ) AS HUELLA,

    I.company AS COMPANY_ITEM,
    UOM.company AS COMPANY_HUELLA

FROM item I
INNER JOIN Item_unit_of_measure UOM
    ON I.ITEM = UOM.item

WHERE UOM.QUANTITY_UM IN ('PZ', 'CJ')
  AND I.company = 'FM'
  AND I.item_category1 <> 'Bulk'
  AND UOM.company = 'FM'
  
  AND I.ITEM LIKE '5157-%'
  
  /*
  AND (
    I.ITEM LIKE '5157-%' OR
  )
  */

GROUP BY
    I.ITEM,
    I.DESCRIPTION,
    I.company,
    UOM.company

ORDER BY I.item

-- @headers: ITEM, DESCRIPTION, HUELLA, COMPANY_ITEM, COMPANY_HUELLA,
