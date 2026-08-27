SELECT
    internal_instruction_num,
    from_loc,
    sequence AS sequence_actual,
    ROW_NUMBER() OVER (
      ORDER BY from_loc, internal_instruction_num
    ) - 1 AS sequence_nuevo

FROM work_instruction
WHERE from_whs = 'Mariano'
  AND instruction_type = 'Detail'
  AND work_unit = '51628752'

ORDER BY from_loc;
