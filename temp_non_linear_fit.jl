



function fit_NL_model(data::Matrix{Float64}, # dataset first row times second row OD
    name_well::String, # name of the well
    label_exp::String, #label of the experiment
    model_function::Any, # ode model to use
    lb_param::Vector{Float64}, # lower bound param
    ub_param::Vector{Float64}; # upper bound param
    u0=lb_param .+ (ub_param .- lb_param) ./ 2,# initial guess param
    optmizator=BBO_adaptive_de_rand_1_bin_radiuslimited(),
    display_plots=true, # display plots in julia or not
    save_plot=false,
    path_to_plot="NA", # where save plots
    pt_avg=1, # numebr of the point to generate intial condition
    pt_smooth_derivative=7,
    smoothing=false, # the smoothing is done or not?
    type_of_smoothing="rolling_avg",
    type_of_loss="RE", # type of used loss
    blank_array=zeros(100), # data of all blanks
    multiple_scattering_correction=false, # if true uses the given calibration curve to fix the data
    method_multiple_scattering_correction="interpolation",
    calibration_OD_curve="NA",  #  the path to calibration curve to fix the data
    PopulationSize=300,
    maxiters=2000000,
    abstol=0.00001,
    thr_lowess=0.05,
)


    if multiple_scattering_correction == true

        data = correction_OD_multiple_scattering(data, calibration_OD_curve; method=method_multiple_scattering_correction)

    end

    if smoothing == true
        data = smoothing_data(
            data;
            method=type_of_smoothing,
            pt_avg=pt_avg,
            thr_lowess=thr_lowess
        )
    end
    # setting initial conditions
    # TO DO GIVE THE OPTION TO FIX THEM AT LEAST IN KNOWN MODELS
    # TO DO MODEL SELECTOR
    if typeof(model_function) == String

        model_function = NL_model_selector(model_function)
        model_string = model_function

    else

        model_string = "custom"


    end
    # Define the optimization problem LOSS
    function objective(u, p)

        model = model_function(u, data[1, :])
        n_data = length(data[1, :])
        residuals = (model .- data[2, :]) ./ n_data
        return log(sum(residuals .^ 2))
    end

    prob = OptimizationProblem(objective, u0, data, lb=lb_param, ub=ub_param)

    # Solve the optimization problem
    sol = solve(prob, optmizator, PopulationSize=PopulationSize, maxiters=maxiters, abstol=abstol)
    # evaluate the fitted  model
    fitted_model = model_function(sol, data[1, :])

    if display_plots
        if_display = display
    else
        if_display = identity
    end

    if save_plot
        mkpath(path_to_plot)
    end


    # plotting if required
    if_display(
        Plots.scatter(
            data[1, :],
            data[2, :],
            xlabel="Time",
            ylabel="Arb. Units",
            label=["Data " nothing],
            markersize=2,
            color=:black,
            title=string(label_exp, " ", name_well),
        ),)

    if_display(
        Plots.plot!(
            data[1, :],
            fitted_model,
            xlabel="Time",
            ylabel="Arb. Units",
            label=[string("Fitting ", model_string) nothing],
            c=:red,
        ),
    )
    if save_plot
        png(string(path_to_plot, label_exp, "_", model, "_", name_well, ".png"))
    end

    sol_fin, index_not_zero = remove_negative_value(fitted_model)

    data_th = transpose(hcat(data[1, index_not_zero], sol_fin))


    max_th_gr = maximum(specific_gr_evaluation(Matrix(data_th), pt_smooth_derivative))

    # max empirical gr
    max_em_gr = maximum(specific_gr_evaluation(data, pt_smooth_derivative))
    loss_value = sol.objective


    res_param = [[name_well, model_string], [sol[1:end]], [max_th_gr, max_em_gr, loss_value]]

    res_param = reduce(vcat, res_param)



    return res_param, fitted_model
end






function fit_NL_model_with_sensitivity(data::Matrix{Float64}, # dataset first row times second row OD
    name_well::String, # name of the well
    label_exp::String, #label of the experiment
    model_function::Any, # ode model to use
    lb_param::Vector{Float64}, # lower bound param
    ub_param::Vector{Float64}; # upper bound param
    nrep=100,
    optmizator=BBO_adaptive_de_rand_1_bin_radiuslimited(),
    display_plots=true, # display plots in julia or not
    save_plot=false,
    path_to_plot="NA", # where save plots
    pt_avg=1, # numebr of the point to generate intial condition
    pt_smooth_derivative=7,
    smoothing=false, # the smoothing is done or not?
    type_of_smoothing="rolling_avg",
    type_of_loss="RE", # type of used loss
    blank_array=zeros(100), # data of all blanks
    multiple_scattering_correction=false, # if true uses the given calibration curve to fix the data
    method_multiple_scattering_correction="interpolation",
    calibration_OD_curve="NA",  #  the path to calibration curve to fix the data
    PopulationSize=300,
    maxiters=2000000,
    abstol=0.00001,
    thr_lowess=0.05,
    write_res = false
)


    if multiple_scattering_correction == true

        data = correction_OD_multiple_scattering(data, calibration_OD_curve; method=method_multiple_scattering_correction)

    end

    if smoothing == true
        data = smoothing_data(
            data;
            method=type_of_smoothing,
            pt_avg=pt_avg,
            thr_lowess=thr_lowess
        )
    end
    # setting initial conditions
    # TO DO GIVE THE OPTION TO FIX THEM AT LEAST IN KNOWN MODELS
    # TO DO MODEL SELECTOR
    if typeof(model_function) == String

        model_function = NL_model_selector(model_function)
        model_string = model_function

    else

        model_string = "custom"


    end
    # Define the optimization problem LOSS
    function objective(u, p)

        model = model_function(u, data[1, :])
        n_data = length(data[1, :])
        residuals = (model .- data[2, :]) ./ n_data
        return log(sum(residuals .^ 2))
    end

    max_em_gr = maximum(specific_gr_evaluation(data, pt_smooth_derivative))

    fin_param = initialize_df_results_ode_custom(lb_param)
    param_combination =
        generation_of_combination_of_IC_morris(lb_param, ub_param, nrep)

    for i = 1:size(param_combination)[2]
        u0 = param_combination[:, i]



        prob = OptimizationProblem(objective, u0, data, lb=lb_param, ub=ub_param)

        # Solve the optimization problem
        sol = solve(prob, optmizator, PopulationSize=PopulationSize, maxiters=maxiters, abstol=abstol)
        # evaluate the fitted  model
        fitted_model = model_function(sol, data[1, :])
        sol_fin, index_not_zero = remove_negative_value(fitted_model)

        data_th = transpose(hcat(data[1, index_not_zero], sol_fin))


        max_th_gr = maximum(specific_gr_evaluation(Matrix(data_th), pt_smooth_derivative))

        # max empirical gr
        loss_value = sol.objective


        res_param = [[name_well, model_string], [sol[1:end]], [max_th_gr, max_em_gr, loss_value]]
        res_param = reduce(vcat,reduce(vcat, res_param))

   

            fin_param = hcat(fin_param, res_param)
        

    end
    

    index_best = findmin(fin_param[end,2:end])[2]

    best_res_param = fin_param[:,index_best]
    println(best_res_param[3:(end-3)] )

    best_fitted_model = model_function(best_res_param[3:(end-3)] , data[1, :])

    if display_plots
        if_display = display
    else
        if_display = identity
    end

    if save_plot
        mkpath(path_to_plot)
    end


    # plotting if required
    if_display(
        Plots.scatter(
            data[1, :],
            data[2, :],
            xlabel="Time",
            ylabel="Arb. Units",
            label=["Data " nothing],
            markersize=2,
            color=:black,
            title=string(label_exp, " ", name_well),
        ),)

    if_display(
        Plots.plot!(
            data[1, :],
            best_fitted_model,
            xlabel="Time",
            ylabel="Arb. Units",
            label=[string("Fitting ", model_string) nothing],
            c=:red,
        ),
    )
    if save_plot
        png(string(path_to_plot, label_exp, "_", model, "_", name_well, ".png"))
    end


    if write_res == true
        mkpath(path_to_results)
        CSV.write(
            string(path_to_results, label_exp, "_results_sensitivity.csv"),
            Tables.table(Matrix(fin_param)),
        )
        CSV.write(
            string(path_to_results, label_exp, "_configurations_tested.csv"),
            Tables.table(Matrix(param_combination)),
        )
    end


    return best_res_param, best_fitted_model,fin_param
end







function fit_NL_model_bootstrap(data::Matrix{Float64}, # dataset first row times second row OD
    name_well::String, # name of the well
    label_exp::String, #label of the experiment
    model_function::Any, # ode model to use
    lb_param::Vector{Float64}, # lower bound param
    ub_param::Vector{Float64}; # upper bound param
    nrep=100,
    u0=lb_param .+ (ub_param .- lb_param) ./ 2,# initial guess param
    optmizator=BBO_adaptive_de_rand_1_bin_radiuslimited(),
    display_plots=true, # display plots in julia or not
    save_plot=false,
    size_bootstrap = 0.7,
    path_to_plot="NA", # where save plots
    pt_avg=1, # numebr of the point to generate intial condition
    pt_smooth_derivative=7,
    smoothing=false, # the smoothing is done or not?
    type_of_smoothing="rolling_avg",
    type_of_loss="RE", # type of used loss
    blank_array=zeros(100), # data of all blanks
    multiple_scattering_correction=false, # if true uses the given calibration curve to fix the data
    method_multiple_scattering_correction="interpolation",
    calibration_OD_curve="NA",  #  the path to calibration curve to fix the data
    PopulationSize=300,
    maxiters=2000000,
    abstol=0.00001,
    thr_lowess=0.05,
    write_res = false
)


    if multiple_scattering_correction == true

        data = correction_OD_multiple_scattering(data, calibration_OD_curve; method=method_multiple_scattering_correction)

    end

    if smoothing == true
        data = smoothing_data(
            data;
            method=type_of_smoothing,
            pt_avg=pt_avg,
            thr_lowess=thr_lowess
        )
    end
    # setting initial conditions
    # TO DO GIVE THE OPTION TO FIX THEM AT LEAST IN KNOWN MODELS
    # TO DO MODEL SELECTOR
    if typeof(model_function) == String

        model_function = NL_model_selector(model_function)
        model_string = model_function

    else

        model_string = "custom"


    end
    # Define the optimization problem LOSS
    function objective(u, p)

        model = model_function(u, data[1, :])
        n_data = length(data[1, :])
        residuals = (model .- data[2, :]) ./ n_data
        return log(sum(residuals .^ 2))
    end

    max_em_gr = maximum(specific_gr_evaluation(data, pt_smooth_derivative))

    fin_param = initialize_df_results_ode_custom(lb_param)
    

    for i = 1:nrep
        idxs = rand(1:1:size(data[2,:], 1),convert.(Int,floor(length(data[2,:])*size_bootstrap)))
        times_boot = data[1,idxs]
        data_boot  =  data[2,idxs]

        idxs_2 = sortperm(times_boot)
        
        times_boot =  times_boot[idxs_2]
        data_boot  =  data_boot[idxs_2]

        data_to_fit =  Matrix(transpose(hcat(times_boot,data_boot)))


        prob = OptimizationProblem(objective, u0, data_to_fit, lb=lb_param, ub=ub_param)

        # Solve the optimization problem
        sol = solve(prob, optmizator, PopulationSize=PopulationSize, maxiters=maxiters, abstol=abstol)
        # evaluate the fitted  model
        fitted_model = model_function(sol, data_to_fit[1, :])
        sol_fin, index_not_zero = remove_negative_value(fitted_model)

        data_th = transpose(hcat(data_to_fit[1, index_not_zero], sol_fin))

  
        max_th_gr = maximum(specific_gr_evaluation(Matrix(data_th), pt_smooth_derivative))

        # max empirical gr
        loss_value = sol.objective


        res_param = [[name_well, model_string], [sol[1:end]], [max_th_gr, max_em_gr, loss_value]]
        res_param = reduce(vcat,reduce(vcat, res_param))

   

            fin_param = hcat(fin_param, res_param)
        

    end
    

    index_best = findmin(fin_param[end,2:end])[2]

    best_res_param = fin_param[:,index_best]

    best_fitted_model = model_function(best_res_param[3:(end-3)] , data[1, :])

    if display_plots
        if_display = display
    else
        if_display = identity
    end

    if save_plot
        mkpath(path_to_plot)
    end


    # plotting if required
    if_display(
        Plots.scatter(
            data[1, :],
            data[2, :],
            xlabel="Time",
            ylabel="Arb. Units",
            label=["Data " nothing],
            markersize=2,
            color=:black,
            title=string(label_exp, " ", name_well),
        ),)

    if_display(
        Plots.plot!(
            data[1, :],
            best_fitted_model,
            xlabel="Time",
            ylabel="Arb. Units",
            label=[string("Fitting ", model_string) nothing],
            c=:red,
        ),
    )
    if save_plot
        png(string(path_to_plot, label_exp, "_", model, "_", name_well, ".png"))
    end


    if write_res == true
        mkpath(path_to_results)
        CSV.write(
            string(path_to_results, label_exp, "_results_bootstrap.csv"),
            Tables.table(Matrix(fin_param)),
        )

    end
    mean_param = [mean(fin_param[i,2:end]) i in 3:size(fin_param,1)]
     sd_param = [std(fin_param[i,2:end]) i in 3:size(fin_param,1)]
     mean_param
     sd_param =hcat()
    return best_res_param, best_fitted_model,fin_param,mean_param,sd_param
end

  