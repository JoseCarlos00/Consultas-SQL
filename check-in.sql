--------------- PIRMER PASO  ---------------
------  QUITAR DE IN TRANSIT DE REC
-- UPDATE LOCATION_INVENTORY
SET ON_HAND_QTY = 0, ALLOCATED_QTY = 0

-- SELECT COUNT(*) FROM LOCATION_INVENTORY
WHERE WAREHOUSE = 'Mariano' AND COMPANY = 'FM'
AND LOCATION = 'REC-01'
AND ITEM IN (SELECT ITEM FROM RECEIPT_DETAIL WHERE INTERNAL_RECEIPT_NUM = '328864')
AND LOGISTICS_UNIT IN (SELECT CONTAINER_ID FROM RECEIPT_CONTAINER WHERE INTERNAL_RECEIPT_NUM = '328864')


---------------  SEGUNDO Y TERCER PASO  ---------------
-- UPDATE LOCATION_INVENTORY
-- SET  IN_TRANSIT_QTY = 0
SET ON_HAND_QTY = IN_TRANSIT_QTY

-- SELECT COUNT(*) FROM LOCATION_INVENTORY
WHERE WAREHOUSE = 'Mariano' AND COMPANY = 'FM'
AND LOCATION = 'HOT-01'
AND ITEM IN (SELECT ITEM FROM RECEIPT_DETAIL WHERE INTERNAL_RECEIPT_NUM = '328864')
AND LOGISTICS_UNIT IN (SELECT CONTAINER_ID FROM RECEIPT_CONTAINER WHERE INTERNAL_RECEIPT_NUM = '328864')

-- AND INTERNAL_LOCATION_INV  NOT IN (
-- AND  LOGISTICS_UNIT  NOT IN ();



--------------- CUARTO PASO  ---------------
SELECT ITEM, ON_HAND_QTY, LOCATION, TO_LOC = 'ALMACENAJE', LOGISTICS_UNIT
-- SELECT COUNT(*) -- IN_TRANSIT_QTY, ,ALLOCATED_QTY
FROM 
    LOCATION_INVENTORY
WHERE 
    WAREHOUSE = 'Mariano' 
    AND COMPANY = 'FM'
    -- AND LOCATION IN ('HOT-01', 'REC-01')
    AND LOCATION = 'HOT-01'
    AND ITEM IN (SELECT ITEM FROM RECEIPT_DETAIL WHERE INTERNAL_RECEIPT_NUM = '328864')
    AND LOGISTICS_UNIT IN (SELECT CONTAINER_ID FROM RECEIPT_CONTAINER WHERE INTERNAL_RECEIPT_NUM = '328864')


-- QUINTO PASO
UPDATE
RECEIPT_CONTAINER
SET STATUS = 900
WHERE INTERNAL_RECEIPT_NUM = '328864'
-- AND INTERNAL_REC_CONT_NUM IN ( )


UPDATE
RECEIPT_HEADER      
SET TRAILING_STS = 900, LEADING_STS = 900
WHERE INTERNAL_RECEIPT_NUM = '328864'

