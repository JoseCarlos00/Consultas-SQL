SELECT 
 WORK_ZONE AS ZONA,
  LOCATION AS UBICACION,
  ARTICULO,
  DESCRIPTION AS DESCRIPCION,
  CAST(AV AS INT) AS AV,
  CAST(OH AS INT) AS OH,
  CAST(AL AS INT)AS AL,
  CAST(IT AS INT) AS IT,
  CAST(SU AS INT) AS SU,
  CAST(RECHAZADA AS INT) AS RECHAZADA,

  CASE
    WHEN WORK_ZONE IN 
      ('W-Mar Bodega 1', 'W-Mar Bodega 2', 'W-Mar Bodega 3', 'W-Mar Bodega 4', 'W-Mar Bodega 5', 'W-Mar Bodega 6', 'W-Mar Bodega 7', 'W-Mar Bodega 8', 'W-Mar Bodega 9','W-Mar Bodega 20', 'W-Mar Vinil', 'W-Mar Mayoreo', 'W-Mar Primer piso Reserva')
    THEN '1ER PISO'

    WHEN WORK_ZONE IN 
      ('W-Mar Bodega 10', 'W-Mar Bodega 11', 'W-Mar Bodega 12', 'W-Mar Bodega 13', 'W-Mar Bodega 14', 'W-Mar Bodega 15', 'W-Mar Bodega 16', 'W-Mar Bodega 17', 'W-Mar No Banda', 'W-Mar Bodega 21', 'W-Mar Segundo Piso Reserv')
    THEN '2DO PISO'
  ELSE '' 
  END AS ZONA,
  CORTO_TIPO AS CORTO

-- cosulta_principal
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
  AND LI.company='FM'

  AND L.location_class<>'Shipping Dock' 
  AND (L.location_class = 'Inventory' OR L.location IN ('ELEVADOR', 'REC-01') )
  AND L.location NOT IN ('MERMA-00', 'MERMA-01', 'MERMA-02', 'MERMA-03')

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
    LI.warehouse,
    LI.company
) AS cosulta_principal

-- ZONAS
LEFT OUTER JOIN 
(	 
SELECT DISTINCT
    localizaciones.ARTICULO AS ITEM,
    locationInventory.WORK_ZONE AS WORK_ZONE,
    locationInventory.LOCATION AS LOCATION,
    locationInventory.AV AS AV,
    locationInventory.OH AS OH,
    locationInventory.OH AS AL,
    locationInventory.IT AS IT,
    locationInventory.SU AS SU,
    locationInventory.NumFila
  FROM (
      SELECT DISTINCT SD.item AS ARTICULO
      FROM shipment_detail SD
      INNER JOIN location_inventory LI ON LI.item = SD.item
      INNER JOIN location L ON L.location = LI.location
      WHERE SD.status1 = 100 
      AND SD.ALLOCATION_REJECTED_QTY > 0
      AND SD.company = 'FM'
      AND SD.warehouse = 'Mariano'
      AND LI.warehouse = 'Mariano'
      AND LI.company = 'FM'
      AND L.location_class <> 'Shipping Dock' 
      AND (L.location_class = 'Inventory' OR L.location IN ('ELEVADOR', 'REC-01') )
      AND (((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) > 0 )
  ) AS localizaciones

  INNER JOIN location_inventory AS LI ON LI.item = localizaciones.ARTICULO
  INNER JOIN location AS L ON L.location = LI.location
  LEFT JOIN (
      SELECT
          LI.ITEM,
          L.WORK_ZONE AS WORK_ZONE,
          L.LOCATION AS LOCATION,
          ((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) AS AV,
          on_hand_qty AS OH,
          allocated_qty AS AL,
          in_transit_qty AS IT,
          suspense_qty AS SU,
        ROW_NUMBER() OVER 
        (
          PARTITION BY LI.item ORDER BY
            CASE
                WHEN LI.permanent='Y' THEN 1
                WHEN (L.WORK_ZONE LIKE 'W-Mar Bodega%' OR L.WORK_ZONE = 'W-Mar No Banda') AND L.WORK_ZONE <> 'W-Mar Bodega Fiscal' THEN 2
                WHEN L.WORK_ZONE IS NOT NULL THEN 3
                ELSE 4
            END
        ) AS NumFila

      FROM location_inventory LI
      INNER JOIN location L ON L.location = LI.location

      WHERE LI.warehouse = 'Mariano'
      AND L.warehouse = 'Mariano'
      AND LI.company = 'FM'
      AND L.location_class <> 'Shipping Dock' 
      AND (L.location_class = 'Inventory' OR L.location IN ('ELEVADOR', 'REC-01'))
  ) AS locationInventory ON locationInventory.ITEM = localizaciones.ARTICULO

  WHERE locationInventory.NumFila=1

) AS ZONAS ON ZONAS.ITEM = cosulta_principal.ARTICULO

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
-- ZONA, UBICACION, ARTICULO, DESCRIPCION, AV, OH, AL, IT, SU, RECHAZADA, ZONA, CORTO,
