
---
SELECT 
    CONVERT(VARCHAR, fecha, 101) AS fecha_convertida, -- Convierte la fecha a formato 'MM/DD/AAAA'

    CONCAT(
        SUBSTRING(CONVERT(VARCHAR, activity_date_time, 101), 3, 2), 
        SUBSTRING(CONVERT(VARCHAR, activity_date_time, 101), 1, 2), 
        SUBSTRING(CONVERT(VARCHAR, activity_date_time, 101), 5, 8)
    ) AS fecha_transformada
FROM mi_tabla;


--- FInal

SELECT
item, location, quantity , work_zone,
FORMAT(DATEADD(HOUR, -6, activity_date_time), 'dd/MM/yyyy') AS nueva_fecha,

FROM Transaction_history
WHERE direction='To'
AND warehouse='Mariano'
AND activity_date_time BETWEEN '20231009' AND '20231018'
AND work_type='Reabasto Ola'
AND location NOT LIKE '-%'
AND (work_zone LIKE 'W-Mar Bodega%' OR work_zone='W-Mar No Banda')
AND location IN (SELECT location FROM location WHERE location_type LIKE 'Generica%S')
ORDER BY 1


---------------------------------------------------

work_unit, instruction_type, condition, reference_id, company, item, description, quantity, fecha, date_time_stamp,

SELECT 
work_unit, instruction_type, condition, reference_id, company, item, 
        SUBSTRING( item_desc, 1, 20) AS description, quantity, 
FORMAT(DATEADD(HOUR, 6, date_time_stamp), 'dd/MM/yyyy') AS nueva_fecha,
date_time_stamp

FROM Work_instruction
WHERE condition!='Closed'
AND reference_id LIKE 'R%-FM'
AND work_type='Almacenaje Tar'
AND instruction_type='Header'
AND (
reference_id like '%12481%' OR
reference_id like '%12482%' OR
reference_id like '%12476%' OR
reference_id like '%12479%'
)

 CONVERT(VARCHAR, receipt_date, 101)
----
select  
receipt_id, company, container_id, item, SUBSTRING(item_desc, 1, 20), quantity, status, receipt_date
from Receipt_Container
where receipt_id_type='Importacion'
AND internal_receipt_line_num IS NOT  NULL
AND parent=0
AND status<>900
AND (
receipt_id  like '%12481%' OR
receipt_id  like '%12482%' OR
receipt_id  like '%12476%' OR
receipt_id  like '%12479%'
)


---- Columnas deceadas
A.receipt_id, A.company, A.container_id, A.item, SUBSTRING(A.item_desc, 1, 20), A.quantity, A.status,
CASE
        WHEN A.status = 100 THEN 'Check In Pending'
        WHEN A.status = 200 THEN 'Locate Pending'
        WHEN A.status = 300 THEN 'Putaway Pending'
        WHEN A.status = 301 THEN 'In Putaway'
        WHEN A.status = 900 THEN 'Closed'
        ELSE 'Valor por defecto' -- Puedes especificar un valor por defecto si ninguno de los valores coincide.
    END AS status, 
A.receipt_date,

B.work_unit, B.instruction_type, B.condition, B.reference_id, B.company, B.item, 
        SUBSTRING( B.item_desc, 1, 20) AS description, B.quantity, 
CONCAT(
        SUBSTRING(CONVERT(VARCHAR, B.date_time_stamp, 101), 4, 3), 
        SUBSTRING(CONVERT(VARCHAR, B.date_time_stamp, 101), 1, 2), 
        SUBSTRING(CONVERT(VARCHAR, B.date_time_stamp, 101), 6, 5)
    ) AS fecha,
B.date_time_stamp


---------

-----
SELECT
    *,
    CASE
        WHEN mi_columna = 'X' THEN 'A'
        ELSE 'B'
    END AS nueva_columna
FROM
    mi_tabla;
