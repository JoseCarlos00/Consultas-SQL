select top 15  DATEADD(HOUR, 6, SYSDATETIME()), date_time_stamp, * 
from item_cross_reference

order by 3  desc

item_cross_reference



INSERT INTO item_cross_reference (ITEM, X_REF_ITEM, COMPANY, USER_STAMP, DATE_TIME_STAMP, QUANTITY_UM, GTIN_ENABLED)
VALUES 
-- ('ITEM', 'CODIGO_DE_BARRAS', 'FM', 'JoseCarlos', DATEADD(HOUR, 6, GETDATE()), 'PZ', 'N'),




DATEADD(HOUR, 6, GETDATE())

