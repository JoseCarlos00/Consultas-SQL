SELECT
  LI.ITEM, CAST(LI.ON_HAND_QTY AS INT) AS OH, LI.LOCATION, TO_LOC = 'TULTITLAN'--, LI.LOGISTICS_UNIT
  FROM LOCATION_INVENTORY LI
  INNER JOIN ITEM I ON LI.ITEM = I.ITEM AND I.COMPANY = 'FM'

  WHERE LI.WAREHOUSE = 'Mariano' AND LI.LOCATION = 'DEVOLUCIONES'
  AND I.ITEM_CATEGORY4 LIKE '%NAV%MAD%'

-- Navidad Madera en Ubicacion de Devoluciones
