SELECT 
*

FROM (
SELECT
    TH.ITEM,
    DATEADD(HOUR, -6, TH.date_time_stamp), *
   
     

  FROM Transaction_history TH

  WHERE TH.warehouse='Mariano'
     AND TH.activity_date_time BETWEEN '20231127' AND '20231204'
    AND TH.work_type='Reabasto Ola'


  GROUP BY TH.ITEM, TH.date_time_stamp

) AS Consulta_principal