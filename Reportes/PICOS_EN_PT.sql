SELECT  
  WAREHOUSE,
  WORK_ZONE,
  LOCATION,
  ITEM,
  ITEM_COLOR,
  COMPANY,
  CAST(SUM(AV) AS INT) AS AV,
  CAST(SUM(OH) AS INT) AS OH,
  CAST(SUM(AL) AS INT) AS AL,
  CAST(SUM(IT) AS INT) AS IT,
  CAST(SUM(SU) AS INT) AS SU,
  CAST(HUELLA AS INT) AS HUELLA,
  CAJAS,
  GRUPO

FROM (
	SELECT  
    LI.WAREHOUSE,
    L.WORK_ZONE,
    LI.LOCATION,
    LI.ITEM,
    LI.ITEM_COLOR,
    LI.COMPANY,
    ((LI.ON_HAND_QTY + LI.IN_TRANSIT_QTY) - (LI.ALLOCATED_QTY + LI.SUSPENSE_QTY)) AS AV,
    LI.ON_HAND_QTY                                                                AS OH,
    LI.ALLOCATED_QTY                                                              AS AL,
    LI.IN_TRANSIT_QTY                                                             AS IT,
    LI.SUSPENSE_QTY                                                               AS SU,
    UOM.conversion_qty                                                            AS HUELLA,
    CAST((LI.on_hand_qty / UOM.conversion_qty) AS DECIMAL(5,2))                   AS CAJAS,
    I.ITEM_CATEGORY4                                                              AS GRUPO,
    LI.internal_location_inv

	FROM location_inventory LI
	INNER JOIN location L ON L.location = LI.location
	INNER JOIN Item_unit_of_measure UOM ON LI.item = UOM.item
	INNER JOIN item I ON I.item = LI.item

	WHERE LI.warehouse = 'Tultitlan'
	AND UOM.sequence = '2' AND I.company = 'FM'

	AND L.WORK_ZONE = 'W-Tul Producto Terminado'
	-- AND L.WORK_ZONE = 'W-Tul Picos'
	-- AND (L.WORK_ZONE = 'W-Tul Producto Terminado' OR L.WORK_ZONE = 'W-Tul Picos') 
        -- AND (I.ITEM_CATEGORY4 LIKE '%NAV%' OR I.ITEM_CATEGORY4 LIKE '%MUERTOS%' )

	GROUP BY  
    LI.WAREHOUSE, LI.LOCATION, LI.ITEM, LI.ITEM_COLOR, LI.COMPANY, LI.ON_HAND_QTY, LI.ALLOCATED_QTY, LI.IN_TRANSIT_QTY, LI.SUSPENSE_QTY, LI.internal_location_inv, LI.logistics_Unit, UOM.sequence, UOM.conversion_qty, I.company, I.ITEM_CATEGORY4, L.WORK_ZONE
) AS PRINCIPAL

WHERE CAJAS <> ROUND(CAJAS, 0)
-- AND CAJAS < 1 

GROUP BY  WAREHOUSE, WORK_ZONE, LOCATION, ITEM, ITEM_COLOR, COMPANY, HUELLA, CAJAS, GRUPO
ORDER BY  WORK_ZONE, ITEM
-- WAREHOUSE, WORk_ZONE, LOCATION, ITEM, ITEM_COLOR, COMPANY, AV, OH, AL, IT, SU, HUELLA, CAJAS, GRUPO, 
