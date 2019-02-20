Feature = Union{Real, AbstractString}
Features = Array{Feature, 1}
Data = Array{Features, 1}

export Feature, Features, Data

"""
    A Question is used to partition a dataset.

    This class just records a 'column number' (e.g., 0 for Color) and a
    'column value' (e.g., Green). The 'match' method is used to compare
    the feature value in an example to the feature value stored in the
    question. See the demo below.
"""
struct Question
    column::Int
    value::Feature
    function Question(column, value)
        new(column, value)
    end
end

export Question

abstract type Node end
"""
A Leaf node classifies data.

This holds a dictionary of class (e.g., "Apple") -> number of times
it appears in the rows from the training data that reach this leaf.
"""
struct Leaf <: Node
    predictions::Dict{AbstractString, Int64}
    function Leaf(rows::Data)
        predictions = class_counts(rows)
        new(predictions)
    end
end

"""
A Decision Node asks a question.

This holds a reference to the question, and to the two child nodes.
"""
struct Decision <: Node
    question::Question
    true_branch::Node
    false_branch::Node
    function Decision(question::Question,
                      true_branch::Node,
                      false_branch::Node)
        new(question, true_branch, false_branch)
    end
end

export Node, Leaf, Decision
