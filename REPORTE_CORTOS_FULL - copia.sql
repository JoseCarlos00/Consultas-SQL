SELECT 
  INV_MAR.WORK_ZONE AS ZONA,
  INV_MAR.LOCATION AS UBICACION,
  DETAIL.ITEM,
  DETAIL.DESCRIPTION,
  CORTO_TIPO AS CORTO,
  CASE WHEN DETAIL.TOTAL_PEDIDO > 0 THEN CONCAT(CAST(DETAIL.TOTAL_PEDIDO AS INT), ' PZ - ', CAST((DETAIL.TOTAL_PEDIDO / HUELLA.CJ) AS DECIMAL(10, 2)), ' CJ') ELSE '' END AS TOTAL_SOLICITADO,
  CASE WHEN INV_MAR.PICKING > 0 THEN CONCAT(INV_MAR.PICKING, ' pz - ', CAST((INV_MAR.PICKING / HUELLA.CJ) AS DECIMAL(10, 2)), ' CJ') ELSE '' END AS PICKING_DISPONIBLE,
  -- CASE WHEN INV_MAR.PICKING - DETAIL.TOTAL_PEDIDO < 0 THEN INV_MAR.PICKING - DETAIL.TOTAL_PEDIDO ELSE 0 END AS POR_LLENAR,
  CASE WHEN INV_MAR.TOTAL_QTY_MAR > 0 THEN CONCAT(CAST(INV_MAR.TOTAL_QTY_MAR AS INT), ' PZ - ', CAST((INV_MAR.TOTAL_QTY_MAR / HUELLA.CJ) AS DECIMAL(10, 2)), ' CJ')  ELSE '' END AS TOTAL_QTY_MAR_CJ,
  -- CASE WHEN INV_TUL.TOTAL_QTY_TUL > 0 THEN CONCAT(CAST(INV_TUL.TOTAL_QTY_TUL AS INT), ' PZ - ', CAST((INV_TUL.TOTAL_QTY_TUL / HUELLA.CJ) AS DECIMAL(10, 2)), ' CJ')  ELSE '' END AS TOTAL_QTY_TUL_CJ,
  
  CASE
    WHEN  INV_MAR.WORK_ZONE IN 
      ('W-Mar Bodega 1', 'W-Mar Bodega 2', 'W-Mar Bodega 3', 'W-Mar Bodega 4', 'W-Mar Bodega 5', 'W-Mar Bodega 6', 'W-Mar Bodega 7', 'W-Mar Bodega 8', 'W-Mar Bodega 9', 'W-Mar Vinil', 'W-Mar Mayoreo')
    THEN '1ER PISO'

    WHEN  INV_MAR.WORK_ZONE IN 
      ('W-Mar Bodega 10', 'W-Mar Bodega 11', 'W-Mar Bodega 12', 'W-Mar Bodega 13', 'W-Mar Bodega 14', 'W-Mar Bodega 15', 'W-Mar Bodega 16', 'W-Mar Bodega 17', 'W-Mar No Banda')
    THEN '2DO PISO'
  ELSE '' 
  END AS PISO


FROM (
   SELECT 
      ITEM,
      DESCRIPTION,
      CONCAT_WS('-',
        NULLIF(TIENDA, ''),
        NULLIF(CLIENTE, ''),
        NULLIF(ML, ''),
        NULLIF(INTERNET, ''),
        NULLIF(MAYOREO, ''),
        NULLIF(AMZ, ''),
        NULLIF(TULTI, '')
      )  AS CORTO_TIPO,
      TOTAL_PEDIDO

  FROM (
    SELECT 
      ITEM,
      REPLACE(item_desc, ',', '.') AS DESCRIPTION,
      MAX(CASE WHEN SHIPMENT_ID LIKE '%-T-%' THEN 'T'     ELSE '' END) AS TIENDA,
      MAX(CASE WHEN SHIPMENT_ID LIKE '%-C-%' THEN 'C'     ELSE '' END) AS CLIENTE,
      MAX(CASE WHEN SHIPMENT_ID LIKE '%-ML-%' THEN 'ML'   ELSE '' END) AS ML,
      MAX(CASE WHEN SHIPMENT_ID LIKE '%-I-%' THEN 'I'     ELSE '' END) AS INTERNET,
      MAX(CASE WHEN SHIPMENT_ID LIKE '%-M-%' THEN 'M'     ELSE '' END) AS MAYOREO,
      MAX(CASE WHEN SHIPMENT_ID LIKE '%-AMZ-%' THEN 'AMZ' ELSE '' END) AS AMZ,
      MAX(CASE WHEN SHIPMENT_ID LIKE 'E-B%' THEN 'TUL'    ELSE '' END) AS TULTI,
      SUM(TOTAL_QTY) AS TOTAL_PEDIDO
      
      FROM shipment_detail

      WHERE status1 < 300
      AND status1 > 99
      AND company='FM'
      AND warehouse='Mariano'

    GROUP BY ITEM, item_desc
  ) AS TIPO_PEDIDOS 
) AS DETAIL


-- Inventario Mariano
LEFT OUTER JOIN (
    SELECT 
      INVENTARIO_MAR.ITEM,
      CAST(SUM(INVENTARIO_MAR.TOTAL_QTY_MAR) AS INT) AS TOTAL_QTY_MAR,
      CAST(SURTIDO.PICKING AS INT) AS PICKING,
      SURTIDO.LOCATION,
      SURTIDO.WORK_ZONE

     FROM (
      SELECT
      LI.item AS ITEM,
      ((LI.on_hand_qty + LI.allocated_qty + LI.in_transit_qty) - LI.suspense_qty) AS TOTAL_QTY_MAR,
      LI.internal_location_inv
      FROM
        LOCATION_INVENTORY LI
        LEFT OUTER JOIN location L on L.location = LI.LOCATION

      WHERE
        LI.warehouse = 'Mariano'
        AND L.warehouse = 'Mariano'
        AND L.location_CLASS = 'Inventory'
      GROUP BY
        LI.ITEM, LI.internal_location_inv, LI.on_hand_qty, LI.allocated_qty, LI.in_transit_qty, LI.suspense_qty
     ) AS INVENTARIO_MAR

    
    INNER JOIN (
      SELECT
      L.WORK_ZONE,
      L.LOCATION,
      ITEM,
      ((LI.on_hand_qty + LI.allocated_qty + LI.in_transit_qty) - LI.suspense_qty)  AS PICKING

      FROM LOCATION_INVENTORY LI
      INNER JOIN location L ON L.location=LI.location

      WHERE LI.warehouse = 'Mariano'
      AND L.warehouse = 'Mariano'
      AND location_type IN ('Generica Dinamico S', 'Generica Permanente S')
      AND WORK_ZONE LIKE 'W-Mar%'

      GROUP BY
        LI.ITEM, LI.internal_location_inv, LI.on_hand_qty, LI.in_transit_qty, LI.allocated_qty, LI.suspense_qty, L.LOCATION, L.WORK_ZONE
    ) AS SURTIDO ON INVENTARIO_MAR.ITEM = SURTIDO.ITEM

    GROUP BY INVENTARIO_MAR.ITEM, SURTIDO.PICKING, SURTIDO.LOCATION, SURTIDO.WORK_ZONE
  ) AS INV_MAR ON INV_MAR.ITEM = DETAIL.ITEM


-- Inventario Tultitlan
LEFT OUTER JOIN (
    SELECT 
      INVENTARIO_TUL.ITEM,
      CAST(SUM(INVENTARIO_TUL.TOTAL_QTY_MAR) AS INT) AS TOTAL_QTY_TUL

     FROM (
      SELECT
      LI.item AS ITEM,
      ((LI.on_hand_qty + LI.allocated_qty + LI.in_transit_qty) - LI.suspense_qty) AS TOTAL_QTY_TUL,
      LI.internal_location_inv
      FROM
        LOCATION_INVENTORY LI
        LEFT OUTER JOIN location L on L.location = LI.LOCATION

      WHERE
        LI.warehouse = 'Tultitlan'
        AND L.warehouse = 'Tultitlan'
        AND L.location_CLASS = 'Inventory'
        AND L.warehouse IN ('W-Tul Picos', 'W-Tul Producto Terminado', 'W-Tul Bodega Fiscal')
      GROUP BY
        LI.ITEM, LI.internal_location_inv, LI.on_hand_qty, LI.allocated_qty, LI.in_transit_qty, LI.suspense_qty
     ) AS INVENTARIO_TUL

      GROUP BY INVENTARIO_TUL.ITEM
    ) AS INV_TUL ON INV_TUL.ITEM = DETAIL.ITEM

-- Huella
LEFT OUTER JOIN (
  SELECT conversion_qty AS CJ, ITEM FROM Item_unit_of_measure WHERE sequence='2' AND company='FM'
) AS HUELLA ON HUELLA.ITEM = DETAIL.ITEM


ORDER BY INV_MAR.WORK_ZONE, INV_MAR.LOCATION

-- Cortos con inventario
-- ZONA, UBICACION, ARTICULO, DESCRIPCION, AV, OH, AL, IT, SU, RECHAZADA, ZONA, CORTO,

