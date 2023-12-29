SELECT 
 WORK_ZONE,
  LOCATION,
  ARTICULO,
  DESCRIPTION,
  CAST(AV AS INT) AS AV,
  CAST(OH AS INT) AS OH,
  CAST(AL AS INT)AS AL,
  CAST(IT AS INT) AS IT,
  CAST(SU AS INT) AS SU,
  CAST(RECHAZADA AS INT) AS RECHAZADA,

  CASE
    WHEN WORK_ZONE IN 
      ('W-Mar Bodega 1', 'W-Mar Bodega 2', 'W-Mar Bodega 3', 'W-Mar Bodega 4', 'W-Mar Bodega 5', 'W-Mar Bodega 6', 'W-Mar Bodega 7', 'W-Mar Bodega 8', 'W-Mar Bodega 9', 'W-Mar Vinil', 'W-Mar Mayoreo')
    THEN '1ER PISO'

    WHEN WORK_ZONE IN 
      ('W-Mar Bodega 10', 'W-Mar Bodega 11', 'W-Mar Bodega 12', 'W-Mar Bodega 13', 'W-Mar Bodega 14', 'W-Mar Bodega 15', 'W-Mar Bodega 16', 'W-Mar Bodega 17', 'W-Mar No Banda')
    THEN '2DO PISO'
  ELSE '' 
  END AS ZONA,
  CORTO_TIPO

FROM 
(
SELECT 
  SD.item AS ARTICULO, 
  SUBSTRING(SD.item_desc, 1, 15) AS DESCRIPTION,
  
  CASE
    WHEN SD.status1 = 100 AND SD.ALLOCATION_REJECTED_QTY > 0 THEN 'Con Inventario'
    ELSE ' ' 
  END AS ESTATUS,
  LI.warehouse

  FROM  shipment_detail SD

  INNER JOIN location_inventory LI
  ON LI.item=SD.item

  INNER JOIN location L
  ON L.location=LI.location

  WHERE SD.status1=100 
  AND SD.ALLOCATION_REJECTED_QTY > 0
  AND SD.company='FM'
  AND SD.warehouse='Mariano'
  
  AND LI.warehouse='Mariano'

  AND (L.location_type<>'Muelle' OR L.location IN ('PRE-01', 'REC-01'))
  AND L.location_class<>'Shipping Dock' 
  AND (L.location_type<>'Piso' OR L.location IN ('ELEVADOR', 'REC-01', 'HOT-01', 'HOT-02', 'LISTONES-00', 'LISTONES-01'))

  -- Verificar si el item existe en el inventario
  AND (((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) > 0 )

  GROUP BY 
    SD.item,
    SD.item_desc,
    LI.on_hand_qty,
    LI.allocated_qty,
    LI.in_transit_qty,
    LI.suspense_qty,
    SD.status1,
    SD.ALLOCATION_REJECTED_QTY,
    SD.internal_shipment_line_num,
    LI.internal_location_inv,
    LI.warehouse
) AS cosulta_principal

-- ZONAS
LEFT OUTER JOIN 
(	 
 SELECT 
  ITEM, WORK_ZONE, LOCATION, AV, OH, AL, IT, SU, NumFila
FROM (
  SELECT
        CASE WHEN (l.work_zone LIKE 'W-Mar Bodega%' OR l.work_zone = 'W-Mar No Banda') AND l.work_zone <> 'W-Mar Bodega Fiscal' THEN l.work_zone ELSE '' END AS WORK_ZONE,
        li.item AS ITEM,
        CASE 
            WHEN l.location_type LIKE 'Generica%S' THEN l.location 
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
      -- AND (((on_hand_qty + in_transit_qty) - (allocated_qty + suspense_qty)) > 0 )
      AND l.location_class <> 'Shipping Dock' 
      AND (l.location_type <> 'Muelle' OR l.location IN ('PRE-01', 'REC-01'))
      AND l.location_class <> 'Shipping Dock' 
      AND (l.location_type <> 'Piso' OR l.location IN ('ELEVADOR', 'REC-01', 'HOT-01', 'HOT-02', 'LISTONES-00', 'LISTONES-01'))
      -- ITEMS CON INVENTARIO
      AND li.item IN (
        SELECT 
        SD.item
        
        FROM  shipment_detail SD

        INNER JOIN location_inventory LI
        ON LI.item=SD.item

        INNER JOIN location L
        ON L.location=LI.location

        WHERE SD.status1=100 
        AND SD.ALLOCATION_REJECTED_QTY > 0
        AND SD.company='FM'
        AND SD.warehouse='Mariano'
        AND LI.warehouse='Mariano'
        AND (L.location_type<>'Muelle' OR L.location IN ('PRE-01', 'REC-01'))
        AND L.location_class<>'Shipping Dock' 
        AND (L.location_type<>'Piso' OR L.location IN ('ELEVADOR', 'REC-01', 'HOT-01', 'HOT-02', 'LISTONES-00', 'LISTONES-01'))

        -- Verificar si el item existe en el inventario disponible
        AND (((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) > 0 )
      )
 
  ) AS FILAS


  WHERE NumFila=1

) AS ZONAS ON ZONAS.item = cosulta_principal.ARTICULO

LEFT OUTER JOIN (
  SELECT 
      ITEM,
      CONCAT_WS('-',
        NULLIF(TIENDA, ''),
        NULLIF(CLIENTE, ''),
        NULLIF(ML, ''),
        NULLIF(INTERNET, ''),
        NULLIF(MAYOREO, ''),
        NULLIF(AMZ, ''),
        NULLIF(TULTI, '')
      )  AS CORTO_TIPO,
      RECHAZADA

--TIPO DE PEDIDOS EN CORTO
  FROM (
    SELECT 
    ITEM,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-T-%' THEN 'T'     ELSE '' END) AS TIENDA,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-C-%' THEN 'C'     ELSE '' END) AS CLIENTE,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-ML-%' THEN 'ML'   ELSE '' END) AS ML,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-I-%' THEN 'I'     ELSE '' END) AS INTERNET,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-M-%' THEN 'M'     ELSE '' END) AS MAYOREO,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-AMZ-%' THEN 'AMZ' ELSE '' END) AS AMZ,
    MAX(CASE WHEN SHIPMENT_ID LIKE 'E-B%' THEN 'TUL'    ELSE '' END) AS TULTI,
    SUM(ALLOCATION_REJECTED_QTY) AS RECHAZADA
    
    FROM shipment_detail SD

    WHERE SD.status1=100
    AND SD.ALLOCATION_REJECTED_QTY > 0
    AND SD.company='FM'
    AND SD.warehouse='Mariano'

    GROUP BY ITEM
  ) AS TIPO_PEDIDOS

) AS tipos_cortos ON tipos_cortos.item = cosulta_principal.ARTICULO

GROUP BY 
  WORK_ZONE,
  LOCATION,
  ARTICULO,
  DESCRIPTION,
  AV,
  OH,
  AL,
  IT,
  SU,
  CORTO_TIPO,
  RECHAZADA

ORDER BY WORK_ZONE, LOCATION

-- Cortos con inventario
-- WORK_ZONE, LOCATION, ARTICULO, DESCRIPCION, AV, OH, AL, IT, SU, RECHAZADA, ZONA, CORTO,