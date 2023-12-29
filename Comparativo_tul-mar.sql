SELECT DISTINCT
  AssociatedItems.item AS ITEM,
CASE
    WHEN (PERMANENTE IS NOT NULL OR ELEVADOR IS NOT NULL OR REC IS NOT NULL OR PRE IS NOT NULL OR RESERVA IS NOT NULL OR HOT IS NOT NULL OR TULTI IS NOT NULL) THEN
        CONCAT_WS('-',
            NULLIF(ZONA, ''), 
            NULLIF(PERMANENTE, ''),
            NULLIF(ELEVADOR, ''),
            NULLIF(REC, ''),
            NULLIF(PRE, ''),
            NULLIF(HOT, ''),
            NULLIF(RESERVA, ''),
            NULLIF(TULTI, '')
        )

    WHEN (PERMANENTE IS NULL AND ELEVADOR IS NULL AND REC IS NULL AND PRE IS NULL AND RESERVA IS NULL AND HOT IS NULL AND TULTI IS NULL) THEN
         CONCAT_WS('-',
            NULLIF(ZONA, ''), 
           'Sin_Inventario'
         )
    ELSE
        NULL
END AS LOCATION

-- Buesqueda de localizaciones en MAriano
FROM 
(
  SELECT
    li.item, 
    MAX(CASE WHEN li.permanent = 'Y' OR loc.location_type = 'Generica Dinamico S' THEN 'Piking' END) AS PERMANENTE,
    MAX(CASE WHEN li.location = 'ELEVADOR' THEN 'Elevador' END) AS ELEVADOR,
    MAX(CASE WHEN li.location LIKE 'REC%' THEN 'REC' END) AS REC,
    MAX(CASE WHEN li.location LIKE 'PRE%' THEN 'PRE' END) AS PRE,
    MAX(CASE WHEN li.location LIKE 'HOT%' THEN 'HOT' END) AS HOT,
    MAX(CASE WHEN li.permanent <> 'Y' AND li.location <> 'ELEVADOR' AND li.location NOT LIKE 'REC%' AND li.location NOT LIKE 'PRE%' AND loc.location_type <> 'Generica Dinamico S' AND li.location NOT LIKE 'HOT%'
    THEN 'Reserva' END) AS RESERVA

  FROM location_inventory li
  INNER JOIN location loc ON li.location = loc.location

  WHERE li.company <> 'AMD' AND li.on_hand_qty > 0 AND li.warehouse = 'Mariano'
  AND li.location IN ( SELECT DISTINCT location FROM location WHERE location_class <> 'Shipping Dock' AND (location_type <> 'Piso' OR location IN ('ELEVADOR', 'REC-01', 'HOT-01', 'HOT-02', 'LISTONES-00', 'LISTONES-01')) AND (location_type <> 'Muelle' OR location IN ('REC-01', 'PRE-01')) )
  
  GROUP BY  li.item ) AS CP

-- items a Consultar
 RIGHT OUTER JOIN 
 (
  SELECT DISTINCT item
  FROM item
  WHERE company='FM'
  AND  item IN (
    -- Artuiculos
  )
) AS AssociatedItems(item) ON CP.item = AssociatedItems.item

-- ZONAS
LEFT OUTER JOIN 
(	 
   SELECT  ITEM, CASE 
    WHEN location LIKE '1-%' THEN '1' 
    WHEN location LIKE '2-%' THEN '2' ELSE '' END AS ZONA
  FROM location_inventory
  WHERE warehouse='Mariano'
  AND location IN (SELECT DISTINCT location FROM LOCATION WHERE location_type LIKE 'Generica%S')

) AS ZONAS ON ZONAS.ITEM = AssociatedItems.item

-- consulta tulti Pendientes
LEFT OUTER JOIN
( 
	SELECT  
    SD.ITEM AS ARTICULO ,
    SUBSTRING(SD.item_desc,1,15) AS DESCRIPCION,
    MAX(SD.REQUESTED_QTY)AS TOTAL,
    CASE WHEN SD.item IS NOT NULL THEN 'Pendiente_Tulti' END AS TULTI

	FROM shipment_detail SD
	INNER JOIN shipment_header SH ON SH.Shipment_id = SD.Shipment_id

	WHERE SD.warehouse = 'Tultitlan' AND SH.order_type = 'TR-TUL-ME' AND SD.status1 <> 100 AND SD.status1 <> 999 AND SD.status1 <> 900
	AND SD.ERP_ORDER IN (SELECT DISTINCT SHIPMENT_ID FROM shipment_header WHERE order_type = 'TR-TUL-ME' AND NOT (trailing_sts = 900 AND leading_sts = 900 ))
  
	GROUP BY  SD.ITEM ,SD.item_desc ,SD.TOTAL_QTY ,SD.status1 ,SD.INTERNAL_SHIPMENT_LINE_NUM

) AS TULTI ON TULTI.ARTICULO = AssociatedItems.item

WHERE AssociatedItems.item IN (
   -- Artuiculos
)

ORDER BY AssociatedItems.item DESC
-- ITEM, LOCATION,