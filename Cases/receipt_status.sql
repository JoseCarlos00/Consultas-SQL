CASE
    WHEN A.status = 100 THEN 'Check In Pending'
    WHEN A.status = 200 THEN 'Locate Pending'
    WHEN A.status = 300 THEN 'Putaway Pending'
    WHEN A.status = 301 THEN 'In Putaway'
    WHEN A.status = 900 THEN 'Closed'
    ELSE A.status
END AS status, 
