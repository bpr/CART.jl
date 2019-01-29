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
