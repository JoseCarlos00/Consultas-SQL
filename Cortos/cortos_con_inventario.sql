SELECT 
  ZONAS.WORK_ZONE AS ZONA,
  ZONAS.LOCATION AS UBICACION,
  PRINCIPAL.ARTICULO,
  PRINCIPAL.DESCRIPTION AS DESCRIPCION,
  CAST(ZONAS.AV AS INT) AS AV,
  CAST(ZONAS.OH AS INT) AS OH,
  CAST(ZONAS.AL AS INT)AS AL,
  CAST(ZONAS.IT AS INT) AS IT,
  CAST(ZONAS.SU AS INT) AS SU,
  CAST(RECHAZADA AS INT) AS RECHAZADA,

  CASE
    WHEN WORK_ZONE IN 
      ('W-Mar Bodega 1', 'W-Mar Bodega 2', 'W-Mar Bodega 3', 'W-Mar Bodega 4', 'W-Mar Bodega 5', 'W-Mar Bodega 6', 'W-Mar Bodega 7', 'W-Mar Bodega 8', 'W-Mar Bodega 9', 'W-Mar Vinil', 'W-Mar Mayoreo', 'W-Mar Primer piso Reserva')
    THEN '1ER PISO'

    WHEN WORK_ZONE IN 
      ('W-Mar Bodega 10', 'W-Mar Bodega 11', 'W-Mar Bodega 12', 'W-Mar Bodega 13', 'W-Mar Bodega 14', 'W-Mar Bodega 15', 'W-Mar Bodega 16', 'W-Mar Bodega 17', 'W-Mar Bodega 20', 'W-Mar Bodega 21', 'W-Mar No Banda', 'W-Mar Segundo Piso Reserv')
    THEN '2DO PISO'
  ELSE ''
  END AS ZONA,
  CORTO_TIPO AS CORTO

-- PRINCIPAL
FROM 
(
  SELECT 
    SD.item AS ARTICULO, 
    REPLACE(SD.item_desc, ',', '.') AS DESCRIPTION,
    
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
    AND L.warehouse = 'Mariano'
    AND LI.company='FM'

    AND L.location_class = 'Inventory'
    AND L.location_type = 'Piso'
    AND L.location NOT IN ('MERMA-00', 'MERMA-01', 'MERMA-02', 'MERMA-03', 'INTERNET-01', 'INTERNET-02')

    -- Verificar si el item existe en el inventario
    AND (((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) > 0 )

  GROUP BY SD.item, SD.item_desc, LI.on_hand_qty, LI.allocated_qty, LI.in_transit_qty, LI.suspense_qty, SD.status1, SD.ALLOCATION_REJECTED_QTY, SD.internal_shipment_line_num, LI.internal_location_inv, LI.warehouse, LI.company
) AS PRINCIPAL

-- ZONAS
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

  ) AS ZONAS ON ZONAS.item = PRINCIPAL.ARTICULO

--TIPO DE PEDIDOS EN CORTO
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

) AS tipo_cortos ON tipo_cortos.item = PRINCIPAL.ARTICULO

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
-- @headers: ZONA, UBICACION, ARTICULO, DESCRIPCION, AV, OH, AL, IT, SU, RECHAZADA, ZONA, CORTO,
