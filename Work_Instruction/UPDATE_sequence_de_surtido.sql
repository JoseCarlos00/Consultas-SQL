UPDATE WI
  SET sequence = TEMP.sequence_nuevo

FROM work_instruction WI
INNER JOIN (

    SELECT
      internal_instruction_num,
      ROW_NUMBER() OVER (
        ORDER BY from_loc, internal_instruction_num
      ) - 1 AS sequence_nuevo

    FROM work_instruction
    WHERE from_whs = 'Mariano'
      AND instruction_type = 'Detail'
      AND work_unit = '51628752'
) TEMP
    ON WI.internal_instruction_num = TEMP.internal_instruction_num

WHERE WI.from_whs = 'Mariano'
  AND WI.instruction_type = 'Detail'
  AND WI.work_unit = '51628752';
