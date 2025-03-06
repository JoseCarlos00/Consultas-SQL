SELECT 
  INV_MAR.WORK_ZONE AS ZONA,
	DETAIL.SHIPMENT_ID,
  DETAIL.ITEM,
  DETAIL.DESCRIPTION,
	DETAIL.RECHAZADA,
	DETAIL.TOTAL_RECHAZADO,
  INV_MAR.LOCATION AS UBICACION,
  CASE WHEN INV_MAR.PICKING > 0 THEN CONCAT(INV_MAR.PICKING, ' pz - ', CAST((INV_MAR.PICKING / HUELLA.CJ) AS DECIMAL(10, 2)), ' CJ') ELSE '' END AS PICKING_DISPONIBLE,
  CASE WHEN INV_MAR.PICKING - DETAIL.TOTAL_RECHAZADO < 0 THEN INV_MAR.PICKING - DETAIL.TOTAL_RECHAZADO ELSE 0 END AS POR_LLENAR,
  CASE WHEN INV_MAR.TOTAL_QTY_MAR > 0 THEN CONCAT(CAST(INV_MAR.TOTAL_QTY_MAR AS INT), ' PZ - ', CAST((INV_MAR.TOTAL_QTY_MAR / HUELLA.CJ) AS DECIMAL(10, 2)), ' CJ')  ELSE '' END AS TOTAL_QTY_MAR
	--, DETAIL.SHIP_TO,
  -- CASE
  --   WHEN  INV_MAR.WORK_ZONE IN 
  --     ('W-Mar Bodega 1', 'W-Mar Bodega 2', 'W-Mar Bodega 3', 'W-Mar Bodega 4', 'W-Mar Bodega 5', 'W-Mar Bodega 6', 'W-Mar Bodega 7', 'W-Mar Bodega 8', 'W-Mar Bodega 9', 'W-Mar Vinil', 'W-Mar Mayoreo')
  --   THEN '1ER PISO'

  --   WHEN  INV_MAR.WORK_ZONE IN 
  --     ('W-Mar Bodega 10', 'W-Mar Bodega 11', 'W-Mar Bodega 12', 'W-Mar Bodega 13', 'W-Mar Bodega 14', 'W-Mar Bodega 15', 'W-Mar Bodega 16', 'W-Mar Bodega 17', 'W-Mar No Banda')
  --   THEN '2DO PISO'
  -- ELSE '' 
  -- END AS PISO


FROM (
   SELECT 
  	CORTOS_DETAIL.ITEM,
  	CORTOS_DETAIL.DESCRIPTION,
		CAST(CORTOS_DETAIL.TOTAL_QTY AS INT) AS RECHAZADA,
		CAST(SUM(TOTAL_PEDIDO) AS  INT) AS TOTAL_RECHAZADO,
		CORTOS_DETAIL.SHIPMENT_ID,
		CORTOS_DETAIL.SHIP_TO	

  FROM (
    SELECT 
      ITEM,
      REPLACE(item_desc, ',', '.') AS DESCRIPTION,
      TOTAL_QTY,
			SHIPMENT_ID,
			SHIP_TO,
			internal_shipment_line_num
      
      FROM shipment_detail

      WHERE status1 = 100
			AND ALLOCATION_REJECTED_QTY > 0
      AND company='FM'
      AND warehouse='Mariano'
  ) AS CORTOS_DETAIL

	INNER JOIN (
		SELECT 
			ITEM,
			SUM(TOTAL_QTY) AS TOTAL_PEDIDO,
			internal_shipment_line_num
      
      FROM shipment_detail

      WHERE status1 = 100
			AND ALLOCATION_REJECTED_QTY > 0
      AND company='FM'
      AND warehouse='Mariano'
			GROUP BY ITEM, internal_shipment_line_num
	) AS TOTAL_CORTO ON CORTOS_DETAIL.ITEM = TOTAL_CORTO.ITEM
	
	GROUP BY CORTOS_DETAIL.ITEM, CORTOS_DETAIL.DESCRIPTION, CORTOS_DETAIL.TOTAL_QTY, CORTOS_DETAIL.SHIPMENT_ID, CORTOS_DETAIL.SHIP_TO
) AS DETAIL


-- Inventario Mariano
INNER JOIN (
    SELECT 
      INVENTARIO_MAR.ITEM,
      CAST(SUM(INVENTARIO_MAR.TOTAL_QTY_MAR) AS INT) AS TOTAL_QTY_MAR,
      CAST(SURTIDO.PICKING AS INT) AS PICKING,
      SURTIDO.LOCATION,
      SURTIDO.WORK_ZONE

     FROM (
      SELECT
      LI.item AS ITEM,
      ((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) AS TOTAL_QTY_MAR,
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
      ((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty))  AS PICKING

      FROM LOCATION_INVENTORY LI
      INNER JOIN location L ON L.location=LI.location

      WHERE LI.warehouse = 'Mariano'
      AND L.warehouse = 'Mariano'
      AND location_type IN ('Generica Dinamico S', 'Generica Permanente S')
			AND L.LOCATION NOT IN ('MAYOREO', 'CLIENTES', 'INTERNET-01', 'LISTON-01', 'BORRA-01', 'JOSELUIS')
      AND WORK_ZONE LIKE 'W-Mar%'
      -- AND LI.ITEM = '9658-11525-11724'

      GROUP BY
        LI.ITEM, LI.internal_location_inv, LI.on_hand_qty, LI.in_transit_qty, LI.allocated_qty, LI.suspense_qty, L.LOCATION, L.WORK_ZONE
    ) AS SURTIDO ON INVENTARIO_MAR.ITEM = SURTIDO.ITEM

    GROUP BY INVENTARIO_MAR.ITEM, SURTIDO.PICKING, SURTIDO.LOCATION, SURTIDO.WORK_ZONE
  ) AS INV_MAR ON INV_MAR.ITEM = DETAIL.ITEM


-- Huella
LEFT OUTER JOIN (
  SELECT conversion_qty AS CJ, ITEM FROM Item_unit_of_measure WHERE sequence='2' AND company='FM'
) AS HUELLA ON HUELLA.ITEM = DETAIL.ITEM

WHERE INV_MAR.TOTAL_QTY_MAR > 0
AND INV_MAR.WORK_ZONE = 'W-Mar Bodega 10'
AND INV_MAR.PICKING - DETAIL.TOTAL_RECHAZADO < 0

ORDER BY INV_MAR.WORK_ZONE, DETAIL.SHIPMENT_ID, DETAIL.ITEM

-- Cortos con inventario
-- ZONA,SHIPMENT_ID,ITEM,DESCRIPTION,RECHAZADA,T_RECHAZADO,UBICACION,PICKING_DISP,POR_LLENAR,TOTAL_QTY_MAR,


