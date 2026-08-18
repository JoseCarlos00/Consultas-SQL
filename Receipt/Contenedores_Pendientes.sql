SELECT DISTINCT
--Columnas Tabla Receipt_Header C
C.receipt_id AS recibo, C.company,
C.leading_sts,
CASE
        WHEN C.leading_sts = 100 THEN 'Check In Pending'
        WHEN C.leading_sts = 200 THEN 'Locate Pending'
        WHEN C.leading_sts = 300 THEN 'Putaway Pending'
        WHEN C.leading_sts = 301 THEN 'In Putaway'
        WHEN C.leading_sts = 900 THEN 'Closed'
        ELSE 'NULL' 
    END AS leading_sts, 
C.trailing_sts,
CASE
        WHEN C.trailing_sts = 100 THEN 'Check In Pending'
        WHEN C.trailing_sts = 200 THEN 'Locate Pending'
        WHEN C.trailing_sts = 300 THEN 'Putaway Pending'
        WHEN C.trailing_sts = 301 THEN 'In Putaway'
        WHEN C.trailing_sts = 900 THEN 'Closed'
        ELSE 'NULL' 
    END AS trailing_sts, 
-- end

-- Columnas Tabla Receipt_Container A
A.container_id, A.item, SUBSTRING(A.item_desc, 1, 20) AS description, A.quantity, A.status,
CASE
        WHEN A.status = 100 THEN 'Check In Pending'
        WHEN A.status = 200 THEN 'Locate Pending'
        WHEN A.status = 300 THEN 'Putaway Pending'
        WHEN A.status = 301 THEN 'In Putaway'
        WHEN A.status = 900 THEN 'Closed'
        ELSE 'NULL' 
    END AS status, 
A.receipt_date, DATEADD(HOUR, -6, A.receipt_date) AS new_receipt_date, FORMAT(DATEADD(HOUR, -6, A.receipt_date), 'dd/MM/yyyy') AS new_receipt_date1,
-- end

-- Columnas Tabla Work_instruction B
B.work_unit, B.instruction_type, B.condition, B.item, SUBSTRING( B.item_desc, 1, 20) AS description, B.quantity, 
B.date_time_stamp, DATEADD(HOUR, -6, B.date_time_stamp) AS new_time_stamp
-- end

--Tablas Consultadas
FROM Receipt_Container A
LEFT JOIN Work_instruction B
ON A.container_id=B.work_unit

INNER JOIN receipt_header C
ON C.receipt_id=A.receipt_id

WHERE A.receipt_id_type='Importacion'
AND A.parent=0
AND A.status<>900
AND (B.instruction_type='Header' OR B.instruction_type IS NULL)

AND (
    C.receipt_id LIKE '%12889%' OR 
    C.receipt_id LIKE '%12785%' OR 
    C.receipt_id LIKE '%12888%' 
)
 
ORDER BY 1

-- HEADERS --> Recibo, Company, leading_sts, leading_sts1, trailing_sts, trailing_sts1, conatiner_id, item, description, quantity, status, status1, receipt_date, new_receipt_date, new_receipt_date1, work_unit, instruction_type, condition, item1, description1, quantity1, date_time_stamp, new_time_stamp