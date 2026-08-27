
---
SELECT 
    CONVERT(VARCHAR, fecha, 101) AS fecha_convertida, -- Convierte la fecha a formato 'MM/DD/AAAA'

    CONCAT(
        SUBSTRING(CONVERT(VARCHAR, activity_date_time, 101), 3, 2), 
        SUBSTRING(CONVERT(VARCHAR, activity_date_time, 101), 1, 2), 
        SUBSTRING(CONVERT(VARCHAR, activity_date_time, 101), 5, 8)
    ) AS fecha_transformada
FROM mi_tabla;


FORMAT(DATEADD(HOUR, -6, activity_date_time), 'dd/MM/yyyy') AS nueva_fecha,


---------------------------------------------------

SUBSTRING( item_desc, 1, 20) AS description

X_REF_ITEM = STUFF(X_REF_ITEM, 1, 1, '') AS REMPLAZAR_CARACTER

LEFT(ICR.item, CHARINDEX('-', ICR.item) - 1) AS EXTRAER_CODIGO
