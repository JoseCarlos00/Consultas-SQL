SELECT 
  WORK_ZONE AS BODEGA,
  ARTICULO,
  DESCRIPTION AS DESCRIPTION,
  CAST(RECHAZADA AS INT) AS RECHAZADA,
  CAST(DISP AS INT) AS DISP,
  CAST(IT AS INT) AS IT,

  CASE
    WHEN WORK_ZONE IN 
      ('W-Mar Bodega 1', 'W-Mar Bodega 2', 'W-Mar Bodega 3', 'W-Mar Bodega 4', 'W-Mar Bodega 5', 'W-Mar Bodega 6', 'W-Mar Bodega 7', 'W-Mar Bodega 8', 'W-Mar Bodega 9','W-Mar Bodega 20', 'W-Mar Vinil', 'W-Mar Mayoreo', 'W-Mar Primer piso Reserva')
    THEN '1ER PISO'

    WHEN WORK_ZONE IN 
      ('W-Mar Bodega 10', 'W-Mar Bodega 11', 'W-Mar Bodega 12', 'W-Mar Bodega 13', 'W-Mar Bodega 14', 'W-Mar Bodega 15', 'W-Mar Bodega 16', 'W-Mar Bodega 17', 'W-Mar No Banda', 'W-Mar Bodega 21', 'W-Mar Segundo Piso Reserv')
    THEN '2DO PISO'
  ELSE '' 
  END AS PISO

-- consulta_principal
FROM 
(
  SELECT 
    SD.item AS ARTICULO, 
    REPLACE(SD.item_desc, ',', '.') AS DESCRIPTION,
  
    CASE
      WHEN SD.status1 = 100 AND SD.ALLOCATION_REJECTED_QTY > 0 THEN 'Con Inventario'
      ELSE ' ' 
    END AS ESTATUS,
    LI.warehouse,
    SD.internal_shipment_line_num,
    LI.internal_location_inv

  FROM  shipment_detail SD

  INNER JOIN location_inventory LI
  ON LI.item=SD.item

  INNER JOIN location L
  ON L.location=LI.location

  WHERE SD.status1=100 
  AND SD.ALLOCATION_REJECTED_QTY > 0
  AND SD.company='FM'
  AND SD.warehouse='Mariano'
  AND L.warehouse='Mariano'
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
) AS consulta_principal

-- ZONAS
LEFT OUTER JOIN 
(	 
  SELECT DISTINCT
    localizaciones.ARTICULO AS ITEM,
    locationInventory.WORK_ZONE AS WORK_ZONE,
    locationInventory.NumFila,
    localizaciones.DISP AS DISP,
    locationInventory.IT AS IT, locationInventory.location

  FROM (
    SELECT 
      INTERNAL_QUERY.ARTICULO AS ARTICULO,
      SUM(INVENTORY.AV) AS DISP

    FROM (
      SELECT
      DISTINCT SD.item AS ARTICULO

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
    ) AS INTERNAL_QUERY

    INNER JOIN (
      SELECT
      LI.item AS ARTICULO,
      ((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) -  (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS AV,
      LI.internal_location_inv


      FROM location_inventory LI
      INNER JOIN location L ON L.location = LI.location

      WHERE L.warehouse = 'Mariano'
      AND LI.warehouse = 'Mariano'
      AND LI.company = 'FM'
      AND L.location_class <> 'Shipping Dock' 
      AND (L.location_class = 'Inventory' OR L.location IN ('ELEVADOR', 'REC-01') )
      AND (((LI.on_hand_qty + LI.in_transit_qty) - (LI.allocated_qty + LI.suspense_qty)) > 0 )

      GROUP BY
        LI.COMPANY,
        LI.ON_HAND_QTY,
        LI.ALLOCATED_QTY,
        LI.IN_TRANSIT_QTY,
        LI.SUSPENSE_QTY,
        LI.internal_location_inv,
        LI.warehouse,
        LI.item
    ) AS INVENTORY ON INVENTORY.ARTICULO = INTERNAL_QUERY.ARTICULO

    -- WHERE INTERNAL_QUERY.ARTICULO = '406-4198-4014'
    GROUP BY INTERNAL_QUERY.ARTICULO
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
      AND L.location_class <> 'Shipping Dock' 
      AND L.warehouse = 'Mariano'
      AND LI.company = 'FM'
      AND (L.location_class = 'Inventory' OR L.location IN ('ELEVADOR', 'REC-01'))
  ) AS locationInventory ON locationInventory.ITEM = localizaciones.ARTICULO

  WHERE locationInventory.NumFila=1
  -- AND localizaciones.ARTICULO = '406-4198-4014'

) AS ZONAS ON ZONAS.ITEM = consulta_principal.ARTICULO

--TIPO DE PEDIDOS EN CORTO
LEFT OUTER JOIN (
  SELECT 
      ITEM,
      RECHAZADA

  FROM (
    SELECT 
    ITEM,
    SUM(ALLOCATION_REJECTED_QTY) AS RECHAZADA
    
    FROM shipment_detail SD

    WHERE SD.status1=100
    AND SD.ALLOCATION_REJECTED_QTY > 0
    AND SD.company='FM'
    AND SD.warehouse='Mariano'

    GROUP BY ITEM
  ) AS TIPO_PEDIDOS
) AS tipos_cortos ON tipos_cortos.item = consulta_principal.ARTICULO

-- WHERE ARTICULO = '406-4198-4014'

GROUP BY 
  WORK_ZONE,
  ARTICULO,
  DESCRIPTION,
  RECHAZADA,
  DISP,
  IT

ORDER BY
  PISO,
  WORK_ZONE,
  ARTICULO
-- Cortos con inventario
-- BODEGA,ARTICULO,DESCRICCION,RECHAZADA,DISP,IT,PISO,
