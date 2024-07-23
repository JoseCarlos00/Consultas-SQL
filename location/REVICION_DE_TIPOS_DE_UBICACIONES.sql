SELECT 
    LOCATION,
    LOCATION_TYPE,
    ALLOCATION_ZONE,
    WORK_ZONE, 
    LOCATING_ZONE,
    MULTI_ITEM,
    TRACK_CONTAINERS,
    STATUS,
    PERMANENTE,
    DINAMICO,
    RESERVA

FROM (
    SELECT 
        LOCATION,
        LOCATION_TYPE,
        ALLOCATION_ZONE,
        WORK_ZONE, 
        LOCATING_ZONE,
        MULTI_ITEM,
        TRACK_CONTAINERS,
        location_sts AS STATUS,
        CASE
            WHEN LOCATION_TYPE = 'Generica Permanente S' AND (ALLOCATION_ZONE = 'A-Surtido Permanente' OR ALLOCATION_ZONE IS NULL) AND MULTI_ITEM = 'N' AND TRACK_CONTAINERS = 'N' THEN 'Correcto'
            WHEN LOCATION_TYPE = 'Generica Permanente S' AND (ALLOCATION_ZONE = 'A-Surtido Permanente' OR ALLOCATION_ZONE IS NULL) AND MULTI_ITEM = 'Y' AND TRACK_CONTAINERS = 'N' THEN 'Multi Item'
            WHEN LOCATION_TYPE = 'Generica Permanente S' AND (ALLOCATION_ZONE = 'A-Surtido Permanente' OR ALLOCATION_ZONE IS NULL) AND MULTI_ITEM = 'Y' AND TRACK_CONTAINERS = 'Y' THEN 'Multi Item - Track'
            WHEN LOCATION_TYPE = 'Generica Permanente S' AND (ALLOCATION_ZONE = 'A-Surtido Permanente' OR MULTI_ITEM = 'N') AND TRACK_CONTAINERS = 'Y' THEN 'Track Container'
            WHEN LOCATION_TYPE = 'Generica Permanente S' AND ALLOCATION_ZONE <> 'A-Surtido Permanente' AND MULTI_ITEM = 'Y' AND TRACK_CONTAINERS = 'N' THEN 'Allocation Zone - Item'
            WHEN LOCATION_TYPE = 'Generica Permanente S' AND ALLOCATION_ZONE <> 'A-Surtido Permanente' AND MULTI_ITEM = 'N' AND TRACK_CONTAINERS = 'Y' THEN 'Allocation Zone - Track'
            WHEN LOCATION_TYPE = 'Generica Permanente S' AND ALLOCATION_ZONE <> 'A-Surtido Permanente' THEN 'Allocation Zone'
            ELSE '' 
        END AS 'PERMANENTE',
        CASE 
            WHEN LOCATION_TYPE = 'Generica Dinamico S' AND (ALLOCATION_ZONE = 'A-Surtido Dinamico' OR ALLOCATION_ZONE IS NULL) AND MULTI_ITEM = 'Y' AND TRACK_CONTAINERS = 'N' THEN 'Correcto'
            WHEN LOCATION_TYPE = 'Generica Dinamico S' AND (ALLOCATION_ZONE = 'A-Surtido Dinamico' OR ALLOCATION_ZONE IS NULL) AND MULTI_ITEM = 'N' AND TRACK_CONTAINERS = 'N' THEN 'Multi Item'
            WHEN LOCATION_TYPE = 'Generica Dinamico S' AND (ALLOCATION_ZONE = 'A-Surtido Dinamico' OR ALLOCATION_ZONE IS NULL) AND MULTI_ITEM = 'N' AND TRACK_CONTAINERS = 'Y' THEN 'Multi Item - Track'
            WHEN LOCATION_TYPE = 'Generica Dinamico S' AND (ALLOCATION_ZONE = 'A-Surtido Dinamico' OR MULTI_ITEM = 'Y') AND TRACK_CONTAINERS = 'Y' THEN 'Track Container'
            WHEN LOCATION_TYPE = 'Generica Dinamico S' AND ALLOCATION_ZONE <> 'A-Surtido Dinamico' AND MULTI_ITEM = 'N' AND TRACK_CONTAINERS = 'N' THEN 'Allocation Zone - Item'
            WHEN LOCATION_TYPE = 'Generica Dinamico S' AND ALLOCATION_ZONE <> 'A-Surtido Dinamico' AND MULTI_ITEM = 'Y' AND TRACK_CONTAINERS = 'Y' THEN 'Allocation Zone - Track'
            WHEN LOCATION_TYPE = 'Generica Dinamico S' AND ALLOCATION_ZONE <> 'A-Surtido Dinamico' THEN 'Allocation Zone'
            ELSE '' 
        END AS 'DINAMICO',

        CASE 
            WHEN LOCATION_TYPE = 'Generica Dinamico R' AND (ALLOCATION_ZONE NOT IN ('A-Surtido Dinamico', 'A-Surtido Permanente') OR ALLOCATION_ZONE IS NULL) AND MULTI_ITEM = 'Y' AND TRACK_CONTAINERS = 'Y' THEN 'Correcto'
            WHEN LOCATION_TYPE = 'Generica Dinamico R' AND (ALLOCATION_ZONE NOT IN ('A-Surtido Dinamico', 'A-Surtido Permanente') OR ALLOCATION_ZONE IS NULL) AND MULTI_ITEM = 'N' AND TRACK_CONTAINERS = 'Y' THEN 'Multi Item'
            WHEN LOCATION_TYPE = 'Generica Dinamico R' AND (ALLOCATION_ZONE NOT IN ('A-Surtido Dinamico', 'A-Surtido Permanente') OR ALLOCATION_ZONE IS NULL) AND MULTI_ITEM = 'N' AND TRACK_CONTAINERS = 'N' THEN 'Multi Item - Track'
            WHEN LOCATION_TYPE = 'Generica Dinamico R' AND (ALLOCATION_ZONE NOT IN ('A-Surtido Dinamico', 'A-Surtido Permanente') OR MULTI_ITEM = 'Y') AND TRACK_CONTAINERS = 'N' THEN 'Track Container'
            WHEN LOCATION_TYPE = 'Generica Dinamico R' AND ALLOCATION_ZONE  IN ('A-Surtido Dinamico', 'A-Surtido Permanente') AND MULTI_ITEM = 'N' AND TRACK_CONTAINERS = 'Y' THEN 'Allocation Zone - Item'
            WHEN LOCATION_TYPE = 'Generica Dinamico R' AND ALLOCATION_ZONE  IN ('A-Surtido Dinamico', 'A-Surtido Permanente') AND MULTI_ITEM = 'Y' AND TRACK_CONTAINERS = 'N' THEN 'Allocation Zone- Track'
            WHEN LOCATION_TYPE = 'Generica Dinamico R' AND ALLOCATION_ZONE  IN ('A-Surtido Dinamico', 'A-Surtido Permanente')  THEN 'Allocation Zone'
            ELSE '' 
        END AS 'RESERVA'

    FROM location 

    WHERE warehouse = 'Mariano'
      AND LOCATION LIKE '_-__-__-__-__'
      AND LOCATION_TYPE LIKE 'Generica%'
) AS PRINCIPAL 

WHERE
  PERMANENTE <> 'Correcto' 
  AND DINAMICO <> 'Correcto'
  AND RESERVA <> 'Correcto'

ORDER BY LOCATION_TYPE, PERMANENTE, DINAMICO, RESERVA, LOCATION

-- LOCATION,LOCATION_TYPE,ALLOCATION_ZONE,WORK_ZONE, LOCATING_ZONE,MULTI_ITEM,TRACK_CONTAINERS,STATUS,PERMANENTE,DINAMICO,RESERVA,