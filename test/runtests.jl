using CART
using Test

tests = ["basic"] # the test file names are stored as strings... 

println("Running tests:")

for t in tests
    include("$(t).jl") # ... so that they can be evaluated in a loop 
end
