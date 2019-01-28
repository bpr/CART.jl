module CART

# Toy dataset.
# Format: each row is an example.
# The last column is the label name, a string.
# The first two columns are features.
# Feel free to play with it by adding more features & examples.
# Interesting note: I've written this so the 2nd and 5th examples
# have the same features, but different labels - so we can see how the
# tree handles this case.

Feature = Union{Real, AbstractString}
Features = Array{Feature, 1}
FeatureValues = Union{Array{Real, 1}, Array{String, 1}}
Data = Array{Features, 1}

training_data = Data([
    ["Green", 3, "Apple"],
    ["Yellow", 3, "Apple"],
    ["Red", 1, "Grape"],
    ["Red", 1, "Grape"],
    ["Yellow", 3, "Lemon"],
])


"""
    Column labels.
    These are used only to print the tree.
"""
const header = ["color", "diameter", "label"]

"""
Find the unique values for a column in a dataset.
Could make the result Union{Set{Real}, Set{AbstractString}}???
"""
function unique_vals(rows::Data, col::Int)::Set{Feature}
    Set([row[col] for row in rows])
end

"""Counts the number of each type of example in a dataset."""
function class_counts(rows::Data)::Dict{AbstractString, Int64}
    counts = Dict()  # a dictionary of label -> count.
    for row in rows
        # in our dataset format, the label is always the last column
        label = row[end]
        if !(label in keys(counts)) # ! binds to the label not the result of in expr
            counts[label] = 0
        end
        counts[label] += 1
    end
    counts
end

"""Test if a value is numeric."""
is_numeric(value) = isa(value, Real)

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

"""Compare the feature value in an example to the feature value in this question."""
function match(question::Question, example::Features):Bool
    val = example[question.column]
    ifelse(is_numeric(val), val >= question.value, val == question.value)
end

function Base.show(io::IO, question::Question)
    condition = ifelse(is_numeric(question.value), ">=", "==")
    colname = header[question.column]
    print(io, "Is $colname $condition $(question.value)?")
end

"""
    Partitions a dataset.

    For each row in the dataset, check if it matches the question. If
    so, add it to 'true rows', otherwise, add it to 'false rows'.
"""
function partition(rows::Data, question::Question)::Tuple{Data, Data}
    true_rows, false_rows = Data(), Data()
    for row in rows
        if match(question, row)
            push!(true_rows, row)
        else
            push!(false_rows,row)
        end
    end
    true_rows, false_rows
end

"""
    Calculate the Gini Impurity for a list of rows.

    There are a few different ways to do this, I thought this one was
    the most concise. See:
    https://en.wikipedia.org/wiki/Decision_tree_learning#Gini_impurity
"""
function gini(rows::Data)::Float64
    counts = class_counts(rows)
    impurity::Float64 = 1.0
    for lbl in keys(counts)
        prob_of_lbl = counts[lbl] / Float64(length(rows))
        impurity -= prob_of_lbl ^ 2
    end
    impurity
end

#######
# Demo:
# Let"s look at some example to understand how Gini Impurity works.
#
# First, we"ll look at a dataset with no mixing.
no_mixing = Data([["Apple"], ["Apple"]])
# this will return 0
gini(no_mixing)
# Now, we"ll look at dataset with a 50:50 apples:oranges ratio
some_mixing = Data([["Apple"], ["Orange"]])
# this will return 0.5 - meaning, there"s a 50% chance of misclassifying
# a random example we draw from the dataset.
gini(some_mixing)

# Now, we'll look at a dataset with many different labels
lots_of_mixing = Data([["Apple"],
                       ["Orange"],
                       ["Grape"],
                       ["Grapefruit"],
                       ["Blueberry"]])
# This will return 0.8
gini(lots_of_mixing)
#######

"""
Information Gain.

The uncertainty of the starting node, minus the weighted impurity of
two child nodes.
"""
function info_gain(left, right, current_uncertainty::Float64)::Float64
    p = Float64(length(left)) / (length(left) + length(right))
    current_uncertainty - p * gini(left) - (1 - p) * gini(right)
end
#######
# Demo:
# Calculate the uncertainy of our training data.
current_uncertainty = gini(training_data)
# How much information do we gain by partioning on "Green"?
true_rows, false_rows = partition(training_data, Question(1, "Green"))
info_gain(true_rows, false_rows, current_uncertainty)
# What about if we partioned on "Red" instead?
true_rows, false_rows = partition(training_data, Question(1,"Red"))
info_gain(true_rows, false_rows, current_uncertainty)

"""
    Find the best question to ask by iterating over every feature / value
    and calculating the information gain.
"""
function find_best_split(rows)::Tuple{Float64, Union{Question, Nothing}}
    best_gain = 0.0  # keep track of the best information gain
    best_question::Union{Nothing, Question} = nothing  # keep track of the feature / value that produced it
    current_uncertainty = gini(rows)
    n_features = length(rows[1]) - 1  # number of columns

    for col in 1:n_features  # for each feature
        values::Set{Feature} = Set([row[col] for row in rows])  # unique values in the column
        for val in values  # for each value
            question = Question(col, val)

            # try splitting the dataset
            true_rows, false_rows = partition(rows, question)

            # Skip this split if it doesn't divide the dataset.
            if length(true_rows) == 0 || length(false_rows) == 0
                continue
            end
            # Calculate the information gain from this split
            gain = info_gain(true_rows, false_rows, current_uncertainty)

            # You actually can use ">" instead of ">=" here
            # but I wanted the tree to look a certain way for our
            # toy dataset.
            if gain >= best_gain
                best_gain, best_question = gain, question
            end # if
        end # for val in values
    end # for col in 1:n_features
    best_gain, best_question
end

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
struct Decision_Node <: Node
    question::Question
    true_branch::Node
    false_branch::Node
    function Decision_Node(question::Question,
                           true_branch::Node,
                           false_branch::Node)
        question = question
        true_branch = true_branch
        false_branch = false_branch
        new(question, true_branch, false_branch)
    end
end

"""
Builds the tree.

Rules of recursion: 1) Believe that it works. 2) Start by checking
for the base case (no further information gain). 3) Prepare for
giant stack traces.
"""
function build_tree(rows::Data)::Node
    # Try partitioning the dataset on each of the unique attribute,
    # calculate the information gain,
    # and return the question that produces the highest gain.
    gain, question = find_best_split(rows)

    # Base case: no further info gain
    # Since we can ask no further questions,
    # we'll return a leaf.
    if gain == 0.0
        return Leaf(rows)
    end
    # If we reach here, we have found a useful feature / value
    # to partition on.
    true_rows, false_rows = partition(rows, question)

    # Recursively build the true branch.
    true_branch = build_tree(true_rows)

    # Recursively build the false branch.
    false_branch = build_tree(false_rows)

    # Return a Question node.
    # This records the best feature / value to ask at this point,
    # as well as the branches to follow
    # depending on the answer.
    Decision_Node(question, true_branch, false_branch)
end

"""World's most elegant tree printing function."""
function print_tree(node::Leaf, spacing="")
    # Base case: we've reached a leaf
    println(spacing * "Predict" * node.predictions)
end

function print_tree(node::Decision_Node, spacing="")
    # Print the question at this node
    println(spacing * str(node.question))

    # Call this function recursively on the true branch
    println(spacing * "--> True:")
    print_tree(node.true_branch, spacing * "  ")

    # Call this function recursively on the false branch
    println(spacing * "--> False:")
    print_tree(node.false_branch, spacing * "  ")
end


end # module
