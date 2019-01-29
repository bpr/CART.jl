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
