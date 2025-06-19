SELECT 
  ZONAS.item,
  PRINCIPAL.ITEM,
  PRINCIPAL.DESCRIPTION,
  SUM(PRINCIPAL.CANTIDAD) AS PRINCIPAL.PIEZAS,
  (SUM(PRINCIPAL.CANTIDAD) / PRINCIPAL.HUELLA) AS CAJAS,
  PRINCIPAL.COMPANY,
  PRINCIPAL.TIPO_DE_RECIBO,
  CONVERT(varchar, DATEADD(hour, -6, PRINCIPAL.DATE_RECEIPT), 6) AS FECHA,
  PRINCIPAL.ZONA
  
FROM (
  SELECT
  WI.REFERENCE_ID AS ID_RECIBO,
  WI.ITEM AS ITEM,
  REPLACE(WI.ITEM_DESC, ',', '.') AS DESCRIPTION,
  (CAST(WI.FROM_QTY AS INT) + CAST(WI.TO_QTY AS INT)) AS CANTIDAD,
  CAST(UOM.conversion_qty AS INT) AS HUELLA,
  RH.receipt_date AS DATE_RECEIPT,
  WI.work_unit AS UNIDAD_DE_TRABAJO,
  WI.COMPANY AS COMPANY,
  CASE 
    WHEN WI.TO_WORK_ZONE LIKE '%Primer%' OR  WI.LOCATING_ZONE LIKE '%Primer%' THEN '1'
    WHEN WI.TO_WORK_ZONE LIKE '%Segundo%' OR  WI.LOCATING_ZONE LIKE '%Segundo%' THEN '2'
    ELSE  '-' END AS ZONA,
  CASE 
   WHEN RH.RECEIPT_ID_TYPE  = 'Importacion' THEN  RH.RECEIPT_ID_TYPE
   WHEN RH.RECEIPT_ID_TYPE = 'Nacional' AND RH.RECEIPT_ID LIKE '%PICOS%' THEN 'Picos'
   WHEN RH.RECEIPT_ID_TYPE = 'Nacional' AND RH.INTERFACE_RECORD_ID IS NOT NULL THEN 'Tulti'
   WHEN RH.RECEIPT_ID_TYPE = 'Nacional' THEN  RH.RECEIPT_ID_TYPE
   WHEN RH.RECEIPT_ID_TYPE = 'DEV-TDA-ME' THEN  'Devolucion'
   ELSE RH.RECEIPT_ID_TYPE END AS TIPO_DE_RECIBO


  FROM Work_instruction WI
  INNER JOIN receipt_header RH ON RH.RECEIPT_ID = WI.REFERENCE_ID
  INNER JOIN Item_unit_of_measure UOM ON WI.ITEM = UOM.item AND UOM.sequence='2'

  WHERE WI.WORK_TYPE LIKE 'Almacenaje%'
  AND WI.INSTRUCTION_TYPE = 'Detail'
  AND WI.FROM_WHS = 'Mariano'
  AND WI.CONDITION <> 'Closed'
  AND RH.WAREHOUSE = 'Mariano'

  GROUP BY 
  WI.REFERENCE_ID, WI.ITEM, WI.ITEM_DESC, WI.FROM_QTY, WI.TO_QTY, WI.INSTRUCTION_TYPE, 
  WI.TO_WORK_ZONE, WI.WORK_TYPE, WI.FROM_WHS, WI.internal_instruction_num, WI.LOCATING_ZONE,
  WI.work_unit, WI.COMPANY,
  RH.RECEIPT_ID, RH.WAREHOUSE, RH.receipt_date, RH.RECEIPT_ID_TYPE, RH.INTERFACE_RECORD_ID,
  UOM.conversion_qty
) AS PRINCIPAL

LEFT OUTER JOIN (	 
  SELECT 
  ITEM, WORK_ZONE, LOCATION, AV, OH, AL, IT, SU, NumFila
  FROM (
  SELECT
      CASE WHEN (l.work_zone LIKE 'W-Mar Bodega%' OR l.work_zone = 'W-Mar No Banda') AND l.work_zone <> 'W-Mar Bodega Fiscal' THEN l.work_zone ELSE '' END AS WORK_ZONE,
        li.item AS ITEM,
        CASE 
            WHEN l.location_type LIKE 'Generica%S' AND l.location NOT LIKE '0-%' THEN l.location 
            WHEN (li.item LIKE '4110-%' OR li.item LIKE '1310-%' OR li.item LIKE '1346-%') THEN l.location
            ELSE '' 
        END AS LOCATION,
        ROW_NUMBER() OVER (PARTITION BY li.item ORDER BY
            CASE
                WHEN li.permanent='Y' THEN 1
                WHEN (l.work_zone LIKE 'W-Mar Bodega%' OR l.work_zone = 'W-Mar No Banda') AND l.work_zone <> 'W-Mar Bodega Fiscal' THEN 2
                WHEN l.work_zone IS NOT NULL THEN 3
                ELSE 4
            END
        ) AS NumFila,
        
        ((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) AS AV,
        on_hand_qty AS OH, allocated_qty AS AL, in_transit_qty AS IT, suspense_qty AS SU

    FROM location_inventory li
    INNER JOIN location l ON l.location = li.location

    WHERE li.warehouse = 'Mariano'
    AND L.location_type LIKE 'Generica%S'

  ) AS FILAS

  WHERE NumFila=1

) AS ZONAS ON ZONAS.item = PRINCIPAL.ITEM

GROUP BY
 PRINCIPAL.ITEM,
 PRINCIPAL.DESCRIPTION,
 PRINCIPAL.DATE_RECEIPT,
 PRINCIPAL.TIPO_DE_RECIBO,
 PRINCIPAL.COMPANY,
 PRINCIPAL.ZONA,
 PRINCIPAL.HUELLA,
 ZONAS.item

-- ITEM,DESCRIPTION,PIEZAS,CAJAS,COMPANY,TIPO_DE_RECIBO,FECHA_DE_RECIBO,ZONA,

ORDER BY ZONAS.item ASC, PRINCIPAL.DATE_RECEIPT ASC
