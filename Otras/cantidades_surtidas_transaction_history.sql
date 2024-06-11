SELECT
   ITEM,
   COLOR,
   SUM(QTY) AS TOTAL

FROM (
    SELECT
        TH.item as ITEM,
        TH.quantity AS QTY,
        I.item_color AS COLOR

    FROM
        Transaction_history TH
    INNER JOIN
        location L ON L.location = TH.location

    INNER JOIN item I ON I.item = TH.item

    WHERE
        TH.warehouse = 'Mariano'
        AND TH.transaction_Type = '130'
        AND TH.direction='FROM'
        
        AND TH.date_time_stamp > '20240414'
        AND TH.WORK_ZONE IS NOT NULL
        AND L.location_type LIKE 'Generica%'
        AND TH.item LIKE '7475-5255-%'


        AND I.company = 'FM'

    GROUP BY TH.INTERNAL_ID, TH.warehouse, TH.transaction_Type, TH.direction, TH.date_time_stamp, L.location_type, TH.item, TH.quantity, I.company, I.item_color

) AS subconsulta


GROUP BY ITEM, COLOR

ORDER BY ITEM

-- Lineas Suritidas Por Zona
-- TIPO,TAREAS_SURTIDAS,LINEAS_SURTIDAS,