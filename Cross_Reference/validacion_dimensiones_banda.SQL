SELECT 
  ITEM,
  DESCRIPTION,
  DIMENSIONES_PZ,
  DIMENSIONES_CJ,
  LENGTH_PZ,
  WIDTH_PZ,
  HEIGHT_PZ,
  LENGTH_CJ,
  WIDTH_CJ,
  HEIGHT_CJ

FROM (
    
    SELECT  
      I.ITEM,
      REPLACE(I.DESCRIPTION, ',', '') AS DESCRIPTION,

    
      MAX(CASE 
          WHEN UOM.QUANTITY_UM = 'PZ' THEN
              CASE 
                  WHEN UOM.LENGTH <= 70 AND UOM.WIDTH <= 58 AND UOM.HEIGHT <= 69 
                  THEN 'OK'
                  ELSE 'FUERA DE LIMITES'
              END
          ELSE ''
      END) AS DIMENSIONES_PZ,
       MAX(CASE 
          WHEN UOM.QUANTITY_UM = 'CJ' THEN
              CASE 
                  WHEN UOM.LENGTH <= 70 AND UOM.WIDTH <= 58 AND UOM.HEIGHT <= 69
                  THEN 'OK'
                  ELSE 'FUERA DE LIMITES'
              END
          ELSE ''
      END) AS DIMENSIONES_CJ,

      -- PZ
      MAX(CASE 
          WHEN UOM.QUANTITY_UM = 'PZ' THEN
              CONCAT(
                  CAST(UOM.LENGTH AS DECIMAL(10,2)),
                  ' CM ',
                  CASE 
                      WHEN UOM.LENGTH <= 70 THEN 'OK'
                      ELSE 'X'
                  END
              )
          ELSE ''
      END) AS LENGTH_PZ,

      MAX(CASE 
          WHEN UOM.QUANTITY_UM = 'PZ' THEN
              CONCAT(
                  CAST(UOM.WIDTH AS DECIMAL(10,2)),
                  ' CM ',
                  CASE 
                      WHEN UOM.WIDTH <= 58 THEN 'OK'
                      ELSE 'X'
                  END
              )
          ELSE ''
      END) AS WIDTH_PZ,

      MAX(CASE 
          WHEN UOM.QUANTITY_UM = 'PZ' THEN
              CONCAT(
                  CAST(UOM.HEIGHT AS DECIMAL(10,2)),
                  ' CM ',
                  CASE 
                      WHEN UOM.HEIGHT <= 69 THEN 'OK'
                      ELSE 'X'
                  END
              )
          ELSE ''
      END) AS HEIGHT_PZ,

      -- CJ
      MAX(CASE 
          WHEN UOM.QUANTITY_UM = 'CJ' THEN
              CONCAT(
                  CAST(UOM.LENGTH AS DECIMAL(10,2)),
                  ' CM ',
                  CASE 
                      WHEN UOM.LENGTH <= 70 THEN 'OK'
                      ELSE 'X'
                  END
              )
          ELSE ''
      END) AS LENGTH_CJ,

      MAX(CASE 
          WHEN UOM.QUANTITY_UM = 'CJ' THEN
              CONCAT(
                  CAST(UOM.WIDTH AS DECIMAL(10,2)),
                  ' CM ',
                  CASE 
                      WHEN UOM.WIDTH <= 58 THEN 'OK'
                      ELSE 'X'
                  END
              )
          ELSE ''
      END) AS WIDTH_CJ,

      MAX(CASE 
          WHEN UOM.QUANTITY_UM = 'CJ' THEN
              CONCAT(
                  CAST(UOM.HEIGHT AS DECIMAL(10,2)),
                  ' CM ',
                  CASE 
                      WHEN UOM.HEIGHT <= 69 THEN 'OK'
                      ELSE 'X'
                  END
              )
          ELSE ''
      END) AS HEIGHT_CJ

    FROM ITEM I
    LEFT JOIN item_unit_of_measure UOM ON I.ITEM = UOM.ITEM AND I.COMPANY = 'FM' AND I.ITEM_CATEGORY1 <> 'Bulk'

  /* DISPONIBLE */
    INNER JOIN (

        SELECT
            LI.ITEM

        FROM location_inventory LI

        INNER JOIN location L
            ON L.LOCATION = LI.LOCATION

        WHERE LI.WAREHOUSE = 'Mariano'
          AND LI.COMPANY = 'FM'
          AND L.WAREHOUSE = 'Mariano'
          AND L.LOCATION_CLASS = 'Inventory'

        GROUP BY
            LI.ITEM

        HAVING
            SUM(
                (LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY)
                - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)
            ) > 0

    ) AS DISPONIBLE
        ON DISPONIBLE.ITEM = I.ITEM

  WHERE 
    I.ITEM_CATEGORY3 = 'BANDA'
    AND UOM.COMPANY = 'FM'
    AND UOM.sequence <> '3'

  GROUP BY
    I.ITEM,
    I.DESCRIPTION

) AS CP


WHERE NOT (DIMENSIONES_PZ = 'OK' AND DIMENSIONES_CJ = 'OK')
 --  AND ITEM LIKE '10034-%'

-- @headers: ITEM,DESCRIPTION,DIMENSIONES_PZ,DIMENSIONES_CJ,LENGTH_PZ,WIDTH_PZ,HEIGHT_PZ,LENGTH_CJ,WIDTH_CJ,HEIGHT_CJ,
