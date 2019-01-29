"""
    show

    Specialize Base.show(io::IO, question::Question) on this by passing a fixed header
"""
function show(io::IO, question::Question, header::Array{String,1})
    condition = ifelse(is_numeric(question.value), ">=", "==")
    colname = header[question.column]
    print(io, "Is $colname $condition $(question.value)?")
end

"""World's most elegant tree printing function."""
function print_tree(node::Leaf, spacing="")
    # Base case: we've reached a leaf
    println(spacing * "Predict" * repr(node.predictions))
end

function print_tree(node::Decision, spacing="")
    # Print the question at this node
    println(spacing * repr(node.question))

    # Call this function recursively on the true branch
    println(spacing * "--> True:")
    print_tree(node.true_branch, spacing * "  ")

    # Call this function recursively on the false branch
    println(spacing * "--> False:")
    print_tree(node.false_branch, spacing * "  ")
end
