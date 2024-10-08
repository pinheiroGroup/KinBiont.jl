
using SpecialFunctions

struct NL_Model
    name::String
    func::Function
    guess::Function
    params::Vector{String}
end

# from "Statistical evaluation of mathematical models for microbial growth"
# non linear model 
# exponential


function heaviside(t)
    0.5 .* (sign.(t) .+ 1)
end
function heaviside_n(t)
    .- 0.5 .* (sign.(t) .- 1)
end

function NL_piecewise_linear_logistic(p, times)


    u =    (heaviside_n.( times .- p[1])) .* p[2]   .+  heaviside.( times .- p[1]) .* p[3] ./ (1.0 .+ ( (p[3]./p[2]) .-1.0 ) .* exp.( .- p[4] .* (times .- p[1] ) ) )

return u

end



function NL_piecewise_exp_logistic(p, times)


    u =    (heaviside_n.( times .- p[1])) .* p[2].* exp.(p[5] .* times)   .+  heaviside.( times .- p[1]) .* p[3] ./ (1.0 .+ ( (p[3]./(p[2].*exp.(p[5].*(p[1])))    ) .-1.0 ) .* exp.( .- p[4] .* (times .- p[1] ) ) )

return u

end
function NL_model_exp(p, times)

    u = p[1] .* exp.(p[2] .* times)

    return u

end

function guess_NL_model_exp(data)

    param_guess = [data[2,1] ,maximum(deriv_evaluation(data))[1] ]

    return       param_guess 


end


function NL_model_logistic(p, times)

    u = p[1] ./ (1 .+ ( (p[1]./p[2]) .-1 ) .* exp.( .- p[3] .* times ) )

    return u

end


function guess_NL_model_logistic(data)

    param_guess = [maximum(data[2,:])[1] ,
                  data[2,1],
                  maximum(deriv_evaluation(data))[1] ]

    return       param_guess 


end


function NL_model_Gompertz(p, times)

    u = p[1] .* exp.(-exp.(-p[2] .* (times .- p[3])))

    return u

end


function guess_NL_model_Gompertz(data)

    param_guess = [maximum(data[2,:])[1] ,
                 maximum(deriv_evaluation(data))[1] ,
                  0.8 * maximum(data[1,:])[1] ]

    return       param_guess 


end
function NL_model_Bertalanffy(p, times)

    u = p[1] .+ (p[2] .- p[1]) .* NaNMath.pow.(1 .- exp.(.-p[3] .* times), (1 ./ p[4]))

    return u

end


function guess_NL_model_Bertalanffy(data)

    param_guess = [data[2,1],
                    maximum(data[2,:])[1],
                 maximum(deriv_evaluation(data))[1] ,
                    1.0
                     ] 

    return       param_guess 


end
#Richards

function NL_model_Richards(p, times)

    u = p[1] ./ NaNMath.pow.((1 .+ p[2] .* exp.(.-p[3] .* (times .- p[4]))) , (1 ./ p[2]))

    return u

end

function guess_NL_model_Richards(data)

    param_guess = [maximum(data[2,:])[1],
                    1.0,
                 maximum(deriv_evaluation(data))[1] ,
                  max(1,0.8 * data[argmax(deriv_evaluation(data))])
                  
                  ]

    return       param_guess 


end
#Morgan


function NL_model_Morgan(p, times)

    u = (p[1] .* p[2] .^ p[3] .+ p[4] .* times .^ p[3]) ./ (p[2] .^ p[3] .+ times .^ p[3])


    return u

end

function  guess_NL_model_Morgan(data)

    param_guess = [maximum(data[2,:])[1],
                    1.0,
                 maximum(deriv_evaluation(data))[1] ,
                  max(1,0.8 * data[argmax(deriv_evaluation(data))])
                  
                  ]

    return       param_guess 


end

#Weibull


function NL_model_Weibull(p, times)

    u = p[1] .- (p[1] .- p[2]) .* exp.(-(p[3] .* times) .^ p[4])


    return u

end
function guess_NL_model_Weibull(data)

    param_guess = [maximum(data[2,:])[1],
                    data[2,1],
                 maximum(deriv_evaluation(data))[1] ,
                  1.0
                  
                  ]

    return       param_guess 


end



NL_models_list = [
    NL_Model(
        "NL_piecewise_lin_logistic",
        NL_piecewise_linear_logistic,
        guess_NL_model_exp,
        ["model", "well", "t_lag", "N_lag", "N_max","growth_rate","th_max_gr", "emp_max_gr", "loss"]
    ),
    NL_Model(
        "NL_piecewise_exp_logistic",
        NL_piecewise_exp_logistic,
        guess_NL_model_exp,
        ["model", "well", "t_lag", "N_lag", "N_max","growth_rate","linear_rate","th_max_gr", "emp_max_gr", "loss"]
    ),
    NL_Model(
        "NL_exponential",
        NL_model_exp,
        guess_NL_model_exp,
        ["model", "well", "N0", "growth_rate", "th_max_gr", "emp_max_gr", "loss"]
    ),
    NL_Model(
        "NL_logistic",
        NL_model_logistic,
        guess_NL_model_logistic,
        ["model", "well", "N_max", "growth_rate", "lag", "th_max_gr", "emp_max_gr", "loss"]
    ),
    NL_Model(
        "NL_Gompertz",
        NL_model_Gompertz,
        guess_NL_model_Gompertz,
        ["model", "well", "N_max", "growth_rate", "lag", "th_max_gr", "emp_max_gr", "loss"]
    ),
    NL_Model(
        "NL_Bertalanffy",
        NL_model_Bertalanffy,
        guess_NL_model_Bertalanffy,
        ["model", "well", "N_0", "N_max", "growth_rate", "shape", "th_max_gr", "emp_max_gr", "loss"]
    ),
    NL_Model(
        "NL_Richards",
        NL_model_Richards,
        guess_NL_model_Richards,
        ["model", "well", "N_max", "shape", "growth_rate", "lag", "th_max_gr", "emp_max_gr", "loss"]
    ),
    NL_Model(
        "NL_Morgan",
        NL_model_Morgan,
        guess_NL_model_Morgan,
        ["model", "well", "N_0", "K", "shape", "N_max", "th_max_gr", "emp_max_gr", "loss"]
    ),
    NL_Model(
        "NL_Weibull",
        NL_model_Weibull,
        guess_NL_model_Weibull,
        ["model", "well", "N_max", "N_0", "growth_rate", "shape", "th_max_gr", "emp_max_gr", "loss"]
    ),

]

NL_models = Dict(NL_model.name => NL_model for NL_model in Kinbiont.NL_models_list)

export NL_model_exp
export NL_model_logistic
export NL_model_Gompertz
export NL_model_Bertalanffy
export NL_model_Richards
export NL_model_Morgan
export NL_model_Weibull
export NL_piecewise_linear_logistic
export NL_piecewise_exp_logistic