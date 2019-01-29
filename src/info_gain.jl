"""
Information Gain.

The uncertainty of the starting node, minus the weighted impurity of
two child nodes.
"""
function info_gain(left, right, current_uncertainty::Float64)::Float64
    p = Float64(length(left)) / (length(left) + length(right))
    current_uncertainty - p * gini(left) - (1 - p) * gini(right)
end
