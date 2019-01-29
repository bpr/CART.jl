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

