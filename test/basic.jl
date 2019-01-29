using Test
# Toy dataset.
# Format: each row is an example.
# The last column is the label name, a string.
# The first two columns are features.
# Feel free to play with it by adding more features & examples.
# Interesting note: I've written this so the 2nd and 5th examples
# have the same features, but different labels - so we can see how the
# tree handles this case.

"""
Find the unique values for a column in a dataset.
Could make the result Union{Set{Real}, Set{AbstractString}}???
"""
function unique_vals(rows::Data, col::Int)::Set{Feature}
    Set([row[col] for row in rows])
end


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
Base.show(io::IO, question::Question) = CART.show(io, question, header)
#######
# Demo:
# Let"s look at some example to understand how Gini Impurity works.
#
# First, we"ll look at a dataset with no mixing.
@testset "Gini" begin
    no_mixing = Data([["Apple"], ["Apple"]])
    # this will return 0
    @test gini(no_mixing) == 0.0
    # Now, we"ll look at dataset with a 50:50 apples:oranges ratio
    some_mixing = Data([["Apple"], ["Orange"]])
    # this will return 0.5 - meaning, there"s a 50% chance of misclassifying
    # a random example we draw from the dataset.
    @test gini(some_mixing) == 0.5

    # Now, we'll look at a dataset with many different labels
    lots_of_mixing = Data([["Apple"],
                           ["Orange"],
                           ["Grape"],
                           ["Grapefruit"],
                           ["Blueberry"]])
    # This will return 0.8
    @test gini(lots_of_mixing) ≈ 0.8
end
#######

#######
# Demo:
# Calculate the uncertainy of our training data.
@testset "Information gain" begin
    current_uncertainty = gini(training_data)
    @test current_uncertainty ≈ 0.6399999999999999

    # How much information do we gain by partioning on "Green"?
    true_rows, false_rows = partition(training_data, Question(1, "Green"))
    gain = info_gain(true_rows, false_rows, current_uncertainty)
    @test gain ≈ 0.1399999999999999

    # What about if we partioned on "Red" instead?
    true_rows, false_rows = partition(training_data, Question(1,"Red"))
    gain = info_gain(true_rows, false_rows, current_uncertainty)
    @test gain ≈ 0.37333333333333324
end

@testset "Best split" begin
end

@testset "Print tree" begin
    my_tree = build_tree(training_data)
    print_tree(my_tree)
end

