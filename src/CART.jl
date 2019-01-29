module CART

include("types.jl")
include("class_counts.jl")
include("match.jl")
include("is_numeric.jl")
include("partition.jl")
include("gini.jl")
include("info_gain.jl")
include("find_best_split.jl")
include("build_tree.jl")
include("print_tree.jl")

export gini, info_gain, partition, build_tree
export print_tree, show

end # module
