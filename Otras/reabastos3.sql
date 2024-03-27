SELECT 
  WORK_ZONE,
  ITEM,
  DESCRIPTION,
  STRING_AGG(nueva_fecha, ', ') WITHIN GROUP (ORDER BY nueva_fecha) AS dias_coincidentes

FROM (
  SELECT
    TH.WORK_ZONE,
    TH.ITEM,
    SUBSTRING(I.DESCRIPTION, 1, 15) AS DESCRIPTION,
    FORMAT(DATEADD(HOUR, -6, TH.date_time_stamp), 'yyyyMMdd') AS nueva_fecha,
    SUM(quantity) AS cantidad_total
     

  FROM Transaction_history TH
  INNER JOIN item I ON I.item=TH.item

  WHERE
    TH.direction='To'
    AND TH.warehouse='Mariano'
    AND TH.activity_date_time BETWEEN '20231127' AND '20231204'
    AND TH.work_type='Reabasto Ola'
    AND location NOT LIKE '-%'
    AND (TH.work_zone LIKE 'W-Mar Bodega%' OR TH.work_zone='W-Mar No Banda')
    AND location IN (SELECT location FROM location WHERE location_type LIKE 'Generica%S')

    AND I.company='FM'

  GROUP BY WORK_ZONE, TH.WORK_ZONE, TH.ITEM, FORMAT(DATEADD(HOUR, -6, TH.date_time_stamp), 'yyyyMMdd'), I.DESCRIPTION

) AS Consulta_principal

GROUP BY WORK_ZONE, ITEM, DESCRIPTION
ORDER BY WORK_ZONE, ITEM;
