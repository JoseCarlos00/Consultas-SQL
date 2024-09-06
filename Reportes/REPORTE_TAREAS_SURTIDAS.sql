SELECT
  ZONA, TIPO,
  COUNT(DISTINCT WORK_UNIT) AS TAREAS_SURTIDAS,
  COUNT(*) AS LINEAS_SURTIDAS,
  FECHA

FROM (
    SELECT
        TH.WORK_UNIT,
        -- Definición de la zona (1ER PISO o 2DO PISO)
        CASE
            WHEN TH.WORK_ZONE IN 
                ('W-Mar Bodega 1', 'W-Mar Bodega 2', 'W-Mar Bodega 3', 'W-Mar Bodega 4', 'W-Mar Bodega 5', 'W-Mar Bodega 6', 'W-Mar Bodega 7', 'W-Mar Bodega 8', 'W-Mar Bodega 9', 'W-Mar Primer piso Reserva')
            THEN '1ER PISO'
            WHEN TH.WORK_ZONE IN 
                ('W-Mar Bodega 10', 'W-Mar Bodega 11', 'W-Mar Bodega 12', 'W-Mar Bodega 13', 'W-Mar Bodega 14', 'W-Mar Bodega 15', 'W-Mar Bodega 16', 'W-Mar Bodega 17', 'W-Mar No Banda', 'W-Mar Segundo Piso Reserv', 'W-Mar Segundo Piso')
            THEN '2DO PISO'
            ELSE '' 
        END AS ZONA,

        CASE 
         WHEN TH.reference_id LIKE '%-T-%' THEN 'TIENDA'
         WHEN TH.reference_id LIKE '%-C-%' THEN 'CLIENTES'
         WHEN TH.reference_id LIKE '%-I-%' THEN 'INTERNET'
         WHEN TH.reference_id LIKE '%-M-%' THEN 'MAYOREO'
         ELSE ''
        END AS TIPO,
        CONVERT(varchar, DATEADD(hour, -6, TH.date_time_stamp), 103) AS FECHA

    FROM
        Transaction_history TH
    INNER JOIN
        location L ON L.location = TH.location
    WHERE
        TH.warehouse = 'Mariano'
        AND TH.transaction_Type = '130'
        AND TH.direction='FROM'
  
        --- FECHA
        AND CONVERT(date, DATEADD(hour, -6, TH.date_time_stamp)) = CONVERT(date, GETDATE())
        ---  AND CONVERT(date, DATEADD(hour, -6, TH.date_time_stamp)) = 'AAAAMMDD'
  
        AND TH.WORK_ZONE IS NOT NULL
        AND L.location_type LIKE 'Generica%'
        AND TH.reference_id LIKE '%-T-%' 

    GROUP BY TH.INTERNAL_ID, TH.WORK_UNIT, TH.WORK_ZONE, TH.reference_id, TH.warehouse, TH.transaction_Type, TH.direction, TH.date_time_stamp, L.location_type

) AS subconsulta
GROUP BY ZONA, TIPO, FECHA
ORDER BY ZONA, TIPO


-- Lineas Suritidas Por Zona
-- ZONA,TIPO,TAREAS_SURTIDAS,LINEAS_SURTIDAS,
