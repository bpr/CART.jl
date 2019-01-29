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
