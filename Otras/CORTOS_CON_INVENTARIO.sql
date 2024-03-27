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
  CAST(SUM(RECHAZADA) AS INT) AS RECHAZADA,

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

FROM (
SELECT DISTINCT
  L.work_zone AS WORK_ZONE,
  L.LOCATION AS LOCATION,
  SD.ITEM AS ARTICULO, 
  SUBSTRING(SD.item_desc, 1, 15) AS DESCRIPTION,
  (CASE 
          WHEN (LI.on_hand_qty - LI.allocated_qty) > 0 THEN ((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty))
          WHEN (LI.on_hand_qty - LI.suspense_qty) > 0 THEN ((LI.on_hand_qty + LI.in_transit_qty)- (LI.suspense_qty + LI.allocated_qty))
          WHEN LI.in_transit_qty > 0 THEN LI.in_transit_qty
          ELSE 0
      END) AS AV,

  LI.on_hand_qty AS OH,
  LI.allocated_qty AS AL,
  LI.in_transit_qty AS IT,
  LI.suspense_qty AS SU,
  CASE
    WHEN SD.status1 = 100 AND SD.ALLOCATION_REJECTED_QTY > 0 THEN 'Con Inventario'
    ELSE ' ' 
  END AS ESTATUS,
  SD.ALLOCATION_REJECTED_QTY AS RECHAZADA,
  SD.internal_shipment_line_num


  FROM  shipment_detail SD
  LEFT JOIN item_location_assignment ILA
  ON ILA.item=SD.item

  INNER JOIN location_inventory LI
  ON LI.item=SD.item

  INNER JOIN location L
  ON L.location=LI.location

  WHERE SD.status1=100
  AND SD.ALLOCATION_REJECTED_QTY > 0
  AND SD.company='FM'
  AND (L.location_type LIKE 'Gene%S')
  AND L.work_zone IS NOT NULL
  AND SD.warehouse='Mariano'

  -- Verificar si el item existe en el inventario
  AND SD.item IN (
    SELECT  
      item
      
      FROM location_inventory
      WHERE company<>'AMD'
      AND warehouse='Mariano'
      AND (((on_hand_qty + in_transit_qty) - (allocated_qty + suspense_qty)) > 0 )
      
      AND location IN (
        SELECT DISTINCT location FROM location 
        WHERE  (location_type<>'Muelle' OR location IN ('PRE-01', 'REC-01'))
        AND location_class<>'Shipping Dock'
        AND (location_type<>'Piso' OR location IN ('ELEVADOR', 'REC-01', 'HOT-01', 'HOT-02', 'LISTONES-00', 'LISTONES-01')))

    GROUP BY ITEM, ON_HAND_QTY, ALLOCATED_QTY, IN_TRANSIT_QTY, SUSPENSE_QTY, internal_location_inv
  )

  GROUP BY 
    L.work_zone,
    L.LOCATION,
    SD.ITEM,
    SD.item_desc,
    LI.on_hand_qty,
    LI.allocated_qty,
    LI.in_transit_qty,
    LI.suspense_qty,
    SD.status1,
    SD.ALLOCATION_REJECTED_QTY,
    SD.internal_shipment_line_num
) AS cosulta_principal

LEFT OUTER JOIN (
  SELECT DISTINCT
      ITEM,
      CONCAT_WS('-',
        NULLIF(TIENDA, ''),
        NULLIF(CLIENTE, ''),
        NULLIF(ML, ''),
        NULLIF(INTERNET, ''),
        NULLIF(MAYOREO, ''),
        NULLIF(AMZ, ''),
        NULLIF(TULTI, '')
      )  AS CORTO_TIPO

--TIPO DE PEDIDOS EN CORTO
  FROM (
    SELECT DISTINCT
    ITEM,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-T-%' THEN 'T'     ELSE '' END) AS TIENDA,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-C-%' THEN 'C'     ELSE '' END) AS CLIENTE,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-ML-%' THEN 'ML'   ELSE '' END) AS ML,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-I-%' THEN 'I'     ELSE '' END) AS INTERNET,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-M-%' THEN 'M'     ELSE '' END) AS MAYOREO,
    MAX(CASE WHEN SHIPMENT_ID LIKE '%-AMZ-%' THEN 'AMZ' ELSE '' END) AS AMZ,
    MAX(CASE WHEN SHIPMENT_ID LIKE 'E-B%' THEN 'TUL'    ELSE '' END) AS TULTI
    
    FROM shipment_detail SD

    WHERE SD.status1=100
    AND SD.ALLOCATION_REJECTED_QTY > 0
    AND SD.company='FM'
    AND SD.warehouse='Mariano'

    GROUP BY ITEM
  ) AS TIPO_PEDIDOS

) AS tipos_cortos ON tipos_cortos.ITEM = cosulta_principal.ARTICULO

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
  CORTO_TIPO

ORDER BY WORK_ZONE, LOCATION

-- Cortos con inventario
-- WORK_ZONE, LOCATION, ARTICULO, DESCRIPCION, AV, OH, AL, IT, SU, RECHAZADA, ZONA, CORTO,