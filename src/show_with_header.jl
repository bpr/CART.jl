function show_with_header(io::IO, question::Question, header)
    condition = ifelse(is_numeric(question.value), ">=", "==")
    colname = header[question.column]
    print(io, "Is $colname $condition $(question.value)?")
end
