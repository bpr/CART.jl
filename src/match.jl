"""Compare the feature value in an example to the feature value in this question."""
function match(question::Question, example::Features):Bool
    val = example[question.column]
    ifelse(is_numeric(val), val >= question.value, val == question.value)
end


