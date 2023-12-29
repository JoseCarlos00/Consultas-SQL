SELECT
    WORK_ZONE,
    LOCATION,
    ITEM,
    COLOR,
    STRING_AGG(CONCAT('[',SUBSTRING(CONVERT(VARCHAR, NEW_DATE, 120), 1, 6)  , ']'), ' - ') WITHIN GROUP (ORDER BY CONVERT(datetime, NEW_DATE, 103)) AS SUB_FECHA
    
  FROM 
  (
    SELECT
      CP.WORK_ZONE,
      CP.ITEM,
      I.ITEM_COLOR AS COLOR,
      CP.NEW_DATE,
      SUM(CP.CAJAS) AS SUM_CAJAS,
      CAST(SUM(CP.cantidad_total) AS INT) AS SUM_TOTAL_QTY,
      CP.LOCATION

     FROM 
     (
      SELECT DISTINCT
      TH.work_zone AS WORK_ZONE,
      TH.item,
      FORMAT(DATEADD(HOUR, -6, TH.activity_date_time), 'dd/MMM/yyyy') AS NEW_DATE,
      SUM(TH.quantity ) AS cantidad_total,
      TH.internal_id,
      CAST(UOM.conversion_qty AS INT) AS HUELLA,
      CAJAS = CAST((SUM(TH.quantity) / UOM.conversion_qty) AS INT),
      TH.location AS LOCATION

      FROM Transaction_history TH
      INNER JOIN Item_unit_of_measure UOM ON TH.item = UOM.item

      WHERE
        TH.direction='To'
        AND TH.warehouse='Mariano'
        AND TH.activity_date_time BETWEEN '20231101' AND CONVERT(VARCHAR, GETDATE(), 112) -- Utiliza la fecha actual
        AND TH.work_type='Reabasto Ola'
        AND TH.location NOT LIKE '-%'
        AND (TH.work_zone LIKE 'W-Mar Bodega%' OR TH.work_zone='W-Mar No Banda')
        AND TH.location IN (SELECT location FROM location WHERE location_type LIKE 'Generica%S')
        AND UOM.sequence='2'

      AND TH.work_zone='W-mar Bodega 1'
      GROUP BY TH.work_zone, TH.item, TH.activity_date_time, TH.internal_id, UOM.conversion_qty, TH.location
    ) AS CP

    INNER JOIN item I ON I.ITEM = CP.ITEM
    
    WHERE I.company = 'FM'

    GROUP BY CP.WORK_ZONE, CP.ITEM, CP.NEW_DATE, I.ITEM_COLOR, CP.LOCATION

  ) AS Consulta_secundaria

  GROUP BY WORK_ZONE, ITEM, COLOR, LOCATION
  -- ORDER BY WORK_ZONE, LOCATION;