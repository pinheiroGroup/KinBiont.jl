# JMAKi

JMAKi, a versatile software tool that utilizes Ordinary Differential Equations (ODEs) to fit bacterial growth data from plate reader experiments. 
With JMAKi it is possible to simulate, fit, perform model selection, and conduct sensitivity analysis for multi-well plate reader experiments.
The parameter fitting in JMAKi is defined as a constrained optimization problem, which is solved using a differential evolution non-linear optimizer.

To address complex cases,  JMAKi preprocesses data by detecting change points in the differential operator within the time series. 
It then automatically assembles and fits a segmented ODE model, resulting in a fully interpretable representation of the time series.





# Installation & requirements
## Manual installation
Download the folder from Github. 
First, it is necessary to install the Julia from https://julialang.org/.   
Next, the user need to copy the project folder in the chosen working directory. 

1. Using REPL or the COMMAND LINE move to the working directory.  
2. If you use the COMMAND LINE, to start a Julia session run the command:

> julia

3. To enter in the Pkg REPL  type 

>]  

4. Type the command 
> activate .

5. To activate the JMAKi project, type
> instantiate

6. at the start of the code or notebook (where you are going to do analyses) you should write 

```
using DifferentialEquations, Optimization, Plots, Random, CSV,  DataFrames, Statistics, Optim, OptimizationBBO, NaNMath, CurveFit, StatsBase, Tables, Distributions,Interpolations,GaussianProcesses,Peaks,ChangePointDetection

include("your_path_to_JMAKi_main_folder/src/functions.jl")


```
this last step is Temporary before the official realese
## Package installation
## Requirements
### Dependencies

1. Julia (1.7,1.8,1.9)
2. DifferentialEquations.jl
3. Optimization.jl
4. Plots.jl
5. Random.jl
6. CSV.jl
7. DataFrames.jl
8. Statistics.jl
9. Optim.jl
10. OptimizationBBO.jl
11. NaNMath.jl
12. CurveFit.jl
13. StatsBase.jl
14. Tables.jl
15. Distributions.jl
16. Interpolations.jl
17. GaussianProcesses.jl 
18. Peaks.jl
19. ChangePointDetection.jl



# Data and annotation formatting
JMAKi can operate directly on data files or inside the julia notebook.
When are in a julia notebook the  format of single time series that want to be analyzed is a 2 x n_time_points Matrix of FLoat64, e.g.,


```
 0.0        2.0       4.0       6.0       8.0        10.0       10.0       12.0       14.0       16.0       18.0       20.0       22.0      24.0      26.0       28.0       30.0       32.0       34.0       36.0       …  
 0.0912154  0.107956  0.105468  0.101727  0.0931484   0.106318   0.103697   0.139821   0.173598   0.204888   0.251052   0.289018   0.31298   0.33752   0.359356   0.370861   0.376347   0.383732   0.398496   0.384511 …  

```
The first row should be time and the second the quantity to be fitted (e.g., Optical Density or CFU)

Instead, three APIs call direclty the files: the user must input  the paths to  a .csv data file and a .csv annotation to the functions of JMAKi.jl
; In these cases JMAKi expect for data a matrix where the first row are the names of the wells and the columns the numerical value of the measurements. Note that the first one will be used as time:

```
Time,  A1,     A2,      A3, 
0.0,   0.09,   0.09,    0.087,
1.0,   0.08,   0.011,   0.012,
2.0,   0.011,  0.18,    0.1,
3.0,   0.012,  0.32,    0.22,
4.0,   0.008,  0.41,    0.122,
```
JMAKi expect a "," as separator between columns

The annotation file instead should be a two columns .csv file where the number of rows correspond to the number of wells, note that the name of the well should be the same between the data.csv and annotation.csv:

```
A1, b
A2, X
A3, unique_ID

```
as unique_ID the user can insert anything but consider that if two wells has the same ID the will be considered replicates. 'b' indicates that the well should be cosidered a blank and 'X' that the well should be discarded from any analysis


See the folders  XXXXX for some examples. 


If a OD calibration curved is provided it should have the following format XXXXXXX


# The main functions of JMAKi




## Simulate ODE
```

   ODE_sim(model::String, 
    n_start::Vector{Float64}, 
    tstart::Float64, 
    tmax::Float64, 
    delta_t::Float64, 
    param_of_ode::Vector{Float64}; 
    integrator = KenCarp4() 
)
```
This function performs an ODE simulation of a model, considering the initial conditions, time range, and integration parameters.

- `model::String`: The model to simulate.
- `n_start::Vector{Float64}`: The starting conditions.
- `tstart::Float64`: The start time of the simulation.
- `tmax::Float64`: The final time of the simulation.
- `delta_t::Float64`: The time step of the output.
- `param_of_ode::Vector{Float64}`: The parameters of the ODE model.

  
The only Key arg. in this case is:
- `integrator=KenCarp4() `: The chosen solver from the SciML ecosystem for ODE integration, default KenCarp4 algorithm.



##  Stochastic simulation
```
    stochastic_sim(model::String,
         n_start::Int,
         n_mol_start::Float64,
        tstart::Float64,
        tmax::Float64,
        delta_t::Float64,
        k_1_val::Float64,
        k_2_val::Float64,
        alpha_val::Float64,
        lambda::Float64,
        n_mol_per_birth::Float64,
        volume::Float64)
```
This function performs a stochastic simulation of a model, considering cell growth and nutrient consumption over time.

- `model::String`: The model to simulate. PUT the options
- `n_start::Int`: The number of starting cells.
- `n_mol_start::Float64`: The starting concentration of the limiting nutrient.
- `tstart::Float64`: The start time of the simulation.
- `tmax::Float64`: The final time of the simulation.
- `delta_t::Float64`: The time step for the Poisson approximation.
- `k_1_val::Float64`: The value of parameter k1.
- `k_2_val::Float64`: The value of the Monod constant.
- `alpha_val::Float64`: The maximum possible growth rate.
- `lambda::Float64`: The lag time.
- `n_mol_per_birth::Float64`: The nutrient consumed per division (mass).
- `volume::Float64`: The volume.

## Plotting a dataset from file
```
plot_data( label_exp::String, #label of the experiment
    path_to_data::String, # path to the folder to analyze
    path_to_annotation::String;# path to the annotation of the wells
    path_to_plot="NA", # path where to save Plots
    display_plots=true ,# display plots in julia or not
    save_plot=false, # save the plot or not
    overlay_plots=true, # true a single plot for all dataset false one plot per well
    blank_subtraction="NO", # string on how to use blank (NO,avg_subctraction,time_avg)
    average_replicate=false, # if true the average between replicates 
    correct_negative="thr_correction", # if "thr_correction" it put a thr on the minimum value of the data with blank subracted, if "blank_correction" uses blank distrib to impute negative values
    thr_negative=0.01,  # used only if correct_negative == "thr_correction"
    )
    
```

This function plot all the data from .csv file 
- `path_to_data::String`: The path to the .csv of data
-  `path_to_annotation::String`: The path to the .csv of annotation 
- `name_well::String`: The name of the well.
- `label_exp::String`: The label of the experiment.

The Key arguments are :
- `path_to_plot= "NA"`: Path to save the plots.
-  `save_plot=false` : save the plot or not
- ` display_plots=true`: Whether or not diplay the plot in julia
-    `overlay_plots =true` : true on plot for all dataset false one plot per well
- `verbose=false`: Whether to enable verbose output.
- `pt_avg=7`: Number of points to use for smoothing average.
- ` blank_subtraction="NO"`: 
- ` average_replicate=false`
- `multiple_scattering_correction=false`: Whether or not correct the data qith a calibration curve.
- `calibration_OD_curve="NA"`: The path where the .csv calibration data are located, used only if `multiple_scattering_correction=true`.



## Specific growth rate evaluation
```
specific_gr_evaluation(data_smooted::Matrix{Float64},
     pt_smoothing_derivative::Int)
```
## Fitting growth rate with log-lin fitting for one well
``` fitting_one_well_Log_Lin(data::Matrix{Float64}, 
    name_well::String, 
    label_exp::String; 
    do_plot=false,
    path_to_plot="NA", 
    type_of_smoothing="rolling_avg",
    pt_avg=7, 
    pt_smoothing_derivative=7, 
    pt_min_size_of_win=7, 
    type_of_win="maximum", 
    threshold_of_exp=0.9, 
    multiple_scattering_correction=false,
    calibration_OD_curve ="NA" 
    )
```
This function fits a logarithmic-linear model to a single well's data and performs analysis such as plotting and error calculation.

- `data::Matrix{Float64}`: The dataset of OD/fluorescence values.
- `name_well::String`: The name of the well.
- `label_exp::String`: The label of the experiment.

The Key arguments are :
- `do_plot=true`: Whether to generate and save plots.
- `path_to_plot="NA"`: The path to save the plots, used only if `do_plot=true`.
- `pt_avg=7`: The number of points to do rolling average smoothing.
- `pt_smoothing_derivative=7`: The number of points of the window to evaluate specific growth rate.
- `pt_min_size_of_win=7`: The minimum size of the exponential windows in the number of smoothed points.
- `type_of_win="maximum"`: How the exponential phase window is selected ("maximum" or "global_thr").
- `threshold_of_exp=0.9`: The threshold of the growth rate in quantile to define the exponential windows.
- `multiple_scattering_correction=false`: Whether or not correct the data qith a calibration curve.
- `calibration_OD_curve="NA"`: The path where the .csv calibration data are located, used only if `multiple_scattering_correction=true`.

## Fitting growth rate with log-lin fitting for one file
```
    fit_one_file_Log_Lin(
    label_exp::String, 
    path_to_data::String,
    path_to_annotation::String;
    path_to_results = "NA",
    path_to_plot= "NA",
    do_plot=false, 
    verbose=false,
    write_res=false, 
    type_of_smoothing="rolling_avg", 
    pt_avg=7,
    pt_smoothing_derivative=7, 
    pt_min_size_of_win=7, 
    type_of_win="maximum", 
    threshold_of_exp=0.9, 
    blank_subtraction="avg_blank", 
    fit_replicate=false, 
    correct_negative="thr_correction",
    thr_negative=0.01, 
    multiple_scattering_correction=false, 
    calibration_OD_curve="NA" 
    )
```
This function fits a logarithmic-linear model to a single file's data. It performs model fitting, error analysis, and provides various options for customization.

- `label_exp::String`: Label of the experiment.
- `path_to_data::String`: Path to the folder containing the data.
- `path_to_annotation::String`: Path to the annotation of the wells.

The Key arguments are :


- `path_to_results= "NA"`: Path to save the results.
- `path_to_plot= "NA"`: Path to save the plots.
- `do_plot=false`: Whether to generate and visualize plots of the data.
- `verbose=false`: Whether to enable verbose output.
- `write_res= false`: Whether to write results.
- `pt_avg=7`: Number of points to use for smoothing average.
- `pt_smoothing_derivative=7`: The number of points of the window to evaluate specific growth rate.
- `pt_min_size_of_win=7`: Minimum size of the exponential windows in number of smoothed points.
- `type_of_win="maximum`: How the exponential phase window is selected ("maximum" or "global_thr").
- `threshold_of_exp=0.9`: Threshold of growth rate in quantile to define the exponential windows.
- `blank_subtraction="avg_blank"`: How to use blank data for subtraction (options: "NO", "avg_subtraction", "time_avg").
- `fit_replicate=false`: If `true`, fit the average between replicates; if `false`, fit all replicates independently.
- `correct_negative="thr_correction`: Method to correct negative values (options: "thr_correction", "blank_correction").
- `thr_negative=0.01`: Threshold value used only if `correct_negative == "thr_correction"`.
- `multiple_scattering_correction=false`: Whether or not correct the data qith a calibration curve.
- `calibration_OD_curve="NA"`: The path where the .csv calibration data are located, used only if `multiple_scattering_correction=true`.




## Fitting ODE function for one well
```
 fitting_one_well_ODE_constrained(data::Matrix{Float64},
    name_well::String, 
    label_exp::String,
    model::String,
    lb_param::Vector{Float64}, 
    ub_param::Vector{Float64}; 
    param= lb_param .+ (ub_param.-lb_param)./2,
    optmizator =   BBO_adaptive_de_rand_1_bin_radiuslimited(), 
    integrator =KenCarp4(autodiff=true), 
    do_plot=false, 
    path_to_plot="NA", 
    pt_avg=1, 
    pt_smooth_derivative=7,
    smoothing=false,
    type_of_loss="RE",
    blank_array=zeros(100),
    multiple_scattering_correction=false, 
    calibration_OD_curve="NA"  
    )
```
This function performs constrained parameter fitting on a single well's dataset using an ordinary differential equation (ODE) model. It estimates the model parameters within specified lower and upper bounds.

- `data::Matrix{Float64}`: Dataset 
-  `model::String`: ODE model to use
- `name_well::String`: Name of the well.
- `label_exp::String`: Label of the experiment.
- `lb_param::Vector{Float64}`: Lower bounds of the model parameters.
- `ub_param::Vector{Float64}`: Upper bounds of the model parameters.


The Key arguments are :

- `param= lb_param .+ (ub_param.-lb_param)./2`: Initial guess for the model parameters.
- `integrator =KenCarp4(autodiff=true)' sciML integrator
- `optmizator =   BBO_adaptive_de_rand_1_bin_radiuslimited()` optimizer from optimizationBBO
- `do_plot=true`: Whether to generate plots or not.
- `path_to_plot="NA"`: Path to save the plots.
- `pt_avg=7`: Number of points to generate the initial condition.
- `smoothing=false`: Whether to apply smoothing to the data or not.
- `type_of_loss:="RE" `: Type of loss function to be used. (options= "RE", "L2", "L2_derivative" and "blank_weighted_L2")
- `blank_array=zeros(100)`: Data of all blanks in single array.
- `verbose=false`: Whether to enable verbose output.
- `write_res=true`: Whether to write results.
- `multiple_scattering_correction=false`: Whether or not correct the data qith a calibration curve.
- `calibration_OD_curve="NA"`: The path where the .csv calibration data are located, used only if `multiple_scattering_correction=true`.



## Fitting ODE function for one file
```
   fit_file_ODE(
    label_exp::String,
    path_to_data::String,
    path_to_annotation::String,
    model::String, 
    lb_param::Vector{Float64},
    ub_param::Vector{Float64}; 
    optmizator =   BBO_adaptive_de_rand_1_bin_radiuslimited(),
    integrator = KenCarp4(autodiff=true), 
    path_to_results="NA",
    path_to_plot="NA", 
    loss_type="RE", 
    smoothing=false, 
    do_plot=false,
    verbose=false, 
    write_res=false, 
    pt_avg=1, 
    pt_smooth_derivative=7,
    blank_subtraction="avg_blank", 
    fit_replicate=false, 
    correct_negative="thr_correction",
    thr_negative=0.01, 
    multiple_scattering_correction=false, 
    calibration_OD_curve="NA"  
    )
```
This function fits an ordinary differential equation (ODE) model to a single file's data. It performs model fitting, error analysis, and provides various options for customization.


- `path_to_data::String`: path to the csv file of data
- `path_to_annotation::String` path to the annotation of the dataset
-  `model::String`: ODE model to use
- `label_exp::String`: Label of the experiment.
- `lb_param::Vector{Float64}`: Lower bounds of the model parameters.
- `ub_param::Vector{Float64}`: Upper bounds of the model parameters.


The Key arguments are :

- `param= lb_param .+ (ub_param.-lb_param)./2`: Initial guess for the model parameters.
- `integrator =KenCarp4(autodiff=true)' sciML integrator
- `optmizator =   BBO_adaptive_de_rand_1_bin_radiuslimited()` optimizer from optimizationBBO
- `do_plot=true`: Whether to generate plots or not.
- `path_to_plot="NA"`: Path to save the plots.
- `pt_avg=7`: Number of points to generate the initial condition.
- `smoothing=false`: Whether to apply smoothing to the data or not.
- `type_of_loss:="RE" `: Type of loss function to be used. (options= "RE", "L2", "L2_derivative" and "blank_weighted_L2")
- `blank_array=zeros(100)`: Data of all blanks in single array.
- `verbose=false`: Whether to enable verbose output.
- `write_res=true`: Whether to write results.
- `multiple_scattering_correction=false`: Whether or not correct the data qith a calibration curve.
- `calibration_OD_curve="NA"`: The path where the .csv calibration data are located, used only if `multiple_scattering_correction=true`.
- fit_replicate=false,  if true the average between replicates is fitted. 

## Fitting custom ODE function for one file
```
fitting_one_well_custom_ODE(data::Matrix{Float64},
    name_well::String, 
    label_exp::String,
    model::Any, 
    lb_param::Vector{Float64}, 
    ub_param::Vector{Float64},
    n_equation::Int; 
    param= lb_param .+ (ub_param.-lb_param)./2,
    optmizator =   BBO_adaptive_de_rand_1_bin_radiuslimited(), 
    integrator =KenCarp4(autodiff=true),
    do_plot=false, 
    path_to_plot="NA", 
    pt_avg=1, 
    pt_smooth_derivative=7,
    smoothing=false, 
    type_of_loss="RE", 
    blank_array=zeros(100), 
    multiple_scattering_correction=false,
    calibration_OD_curve="NA"  
    )
```
### `fitting_one_well_custom_ODE` Function

This function is designed for fitting an ordinary differential equation (ODE) model to a dataset representing the growth curve of a microorganism in a well. It utilizes a customizable ODE model, optimization methods, and integration techniques for parameter estimation.

 Arguments:

- `data::Matrix{Float64}`: The dataset with the growth curve, where the first row represents times, and the second row represents optical density (OD).
- `name_well::String`: The name of the well.
- `label_exp::String`: The label of the experiment.
- `model::Any`: The ODE model to use.
- `lb_param::Vector{Float64}`: Lower bounds for the parameters.
- `ub_param::Vector{Float64}`: Upper bounds for the parameters.
- `n_equation::Int`: The number of ODEs in the system.
  
Key   Arguments:

- `param= lb_param .+ (ub_param.-lb_param)./2`: Initial guess for the parameters.
- `optmizator=BBO_adaptive_de_rand_1_bin_radiuslimited()`: The optimization method to use.
- `integrator=KenCarp4(autodiff=true)`: The integrator for solving the ODE.
- `do_plot=false`: Whether to generate plots or not.
- `path_to_plot="NA"`: Path to save the generated plots.
- `pt_avg=1`: Number of points to generate the initial condition.
- `pt_smooth_derivative=7`: Number of points for smoothing the derivative.
- `smoothing=false`: Determines whether smoothing is applied to the data.
- `type_of_loss="RE"`: Type of loss used for optimization (options= "RE", "L2", "L2_derivative" and "blank_weighted_L2")
- `blank_array=zeros(100)`: Data representing blanks for correction.
- `multiple_scattering_correction=false`: If `true`, uses a given calibration curve to correct the data.
- `calibration_OD_curve="NA"`: The path to the calibration curve used for data correction.



## Sensitivity analysis
```
 one_well_morris_sensitivity(data::Matrix{Float64}, 
    name_well::String,
    label_exp::String, 
    model::String, 
    lb_param::Vector{Float64}, 
    ub_param::Vector{Float64}; 
    N_step_morris =7,
    optmizator =   BBO_adaptive_de_rand_1_bin_radiuslimited(), 
    integrator =KenCarp4(autodiff=true), 
    pt_avg=1, 
    pt_smooth_derivative=7,
    write_res=false,
    smoothing=false,
    type_of_loss="RE", 
    blank_array=zeros(100),
    multiple_scattering_correction=false, 
    calibration_OD_curve="NA"  
    )
```

This function is designed to perform Morris sensitivity analysis on a dataset representing the growth curve of a microorganism in a well. It assesses the sensitivity of the model to variations in input parameters.

Arguments:

- `data::Matrix{Float64}`: The dataset with the growth curve, where the first row represents times, and the second row represents optical density (OD).
- `name_well::String`: The name of the well.
- `label_exp::String`: The label of the experiment.
- `model::String`: The ODE model to use.
- `lb_param::Vector{Float64}`: Lower bounds for the parameters.
- `ub_param::Vector{Float64}`: Upper bounds for the parameters.


Key Arguments:

- `N_step_morris=7`: Number of steps for the Morris sensitivity analysis.
- `optmizator=BBO_adaptive_de_rand_1_bin_radiuslimited()`: The optimization method to use.
- `integrator=KenCarp4(autodiff=true)`: The integrator for solving the ODE.
- `pt_avg=1`: Number of points to generate the initial condition.
- `pt_smooth_derivative=7`: Number of points for smoothing the derivative.
- `write_res=false`: If `true`, writes the sensitivity analysis results to a file.
- `smoothing=false`: Determines whether smoothing is applied to the data.
- `type_of_loss="RE"`: Type of loss used for optimization (options= "RE", "L2", "L2_derivative" and "blank_weighted_L2")
- `blank_array=zeros(100)`: Data representing blanks for correction.
- `multiple_scattering_correction=false`: If `true`, uses a given calibration curve to correct the data.
- `calibration_OD_curve="NA"`: The path to the calibration curve used for data correction.



## Model selection
```
ODE_Model_selection(data::Matrix{Float64}, # dataset first row times second row OD
    name_well::String, # name of the well
    label_exp::String, #label of the experiment
    models_list::Vector{String}, # ode model to use 
    lb_param_array::Any, # lower bound param
    ub_param_array::Any; # upper bound param
    optmizator =   BBO_adaptive_de_rand_1_bin_radiuslimited(), # selection of optimization method 
    integrator = KenCarp4(autodiff=true), # selection of sciml integrator
    pt_avg = 1 , # number of the point to generate intial condition
    beta_penality = 2.0, # penality for AIC evaluation
    smoothing= false, # the smoothing is done or not?
    type_of_loss="L2", # type of used loss 
    blank_array=zeros(100), # data of all blanks
    plot_best_model=false, # one wants the results of the best fit to be plotted
    path_to_plot="NA",
    pt_smooth_derivative=7,
    multiple_scattering_correction=false, # if true uses the given calibration curve to fix the data
    calibration_OD_curve="NA", #  the path to calibration curve to fix the data
    verbose=false
)
```

This function performs model selection based on a dataset representing the growth curve of a microorganism in a well. It evaluates multiple ODE models and selects the best-fitting model using the Akaike Information Criterion (AIC).

Arguments:

- `data::Matrix{Float64}`: The dataset with the growth curve, where the first row represents times, and the second row represents optical density (OD).
- `name_well::String`: The name of the well.
- `label_exp::String`: The label of the experiment.
- `models_list::Vector{String}`: A vector of ODE models to evaluate.
- `lb_param_array::Any`: Lower bounds for the parameters (compatible with the models).
- `ub_param_array::Any`: Upper bounds for the parameters (compatible with the models).

Key Arguments:

- `optmizator=BBO_adaptive_de_rand_1_bin_radiuslimited()`: The optimization method to use.
- `integrator=KenCarp4(autodiff=true)`: The integrator for solving the ODE.
- `pt_avg=1`: Number of points to generate the initial condition.
- `beta_penality=2.0`: Penalty for AIC evaluation.
- `smoothing=false`: Determines whether smoothing is applied to the data.
- `type_of_loss="L2"`: Type of loss used for optimization (options= "RE", "L2", "L2_derivative" and "blank_weighted_L2")
- `blank_array=zeros(100)`: Data representing blanks for correction.
- `plot_best_model=false`: If `true`, the results of the best-fit model will be plotted.
- `path_to_plot="NA"`: Path to save the generated plots.
- `pt_smooth_derivative=7`: Number of points for smoothing the derivative.
- `multiple_scattering_correction=false`: If `true`, uses a given calibration curve to correct the data.
- `calibration_OD_curve="NA"`: The path to the calibration curve used for data correction.
- `verbose=false`: If `true`, enables verbose output.


## Change point detection
```
cpd_local_detection(data::Matrix{Float64},
    n_max_cp::Int;
    type_of_detection="lsdd",
    type_of_curve="original", 
    pt_derivative = 0,
    size_win =2)

```
This function performs change point detection on a dataset, identifying local changes in the growth curve. It uses various algorithms based on user-defined parameters.

Arguments:

- `data::Matrix{Float64}`: The dataset with the growth curve, where the first row represents times, and the second row represents optical density (OD).
- `n_max_cp::Int`: The maximum number of change points to detect.

Key Arguments:

- `type_of_detection="lsdd"`: Type of change point detection algorithm. Options are "lsdd" or piecewise linear fitting 
- `type_of_curve="deriv"`: Type of curve used for the change point detection. Options are "deriv" for the  derivative/specific gr or "orinal" for growth curve.
- `pt_derivative=0`: Number of points to evaluate the derivative or specific growth rate. If 0, numerical derivative is used; if >1, specific growth rate is calculated with the given window size.
- `size_win=2`: Size of the sliding window used in all detection methods.

## Fitting segmented ODE with fixed change-point number
```
selection_ODE_fixed_change_points(data_testing::Matrix{Float64}, 
    name_well::String,
    label_exp::String,
    list_of_models::Vector{String}, 
    list_lb_param::Any,
    list_ub_param::Any, 
    n_change_points::Int;
    type_of_loss="L2", 
    optmizator =   BBO_adaptive_de_rand_1_bin_radiuslimited(), 
    integrator = KenCarp4(autodiff=true), 
    type_of_detection =  "lsdd",
    type_of_curve = "original", 
    smoothing=false,
    pt_avg=1,
    do_plot=false, 
    path_to_plot="NA", 
    win_size=2, 
    pt_smooth_derivative=0,
    multiple_scattering_correction=false, 
    calibration_OD_curve="NA",
    beta_smoothing_ms = 2.0 
    )
```

This function performs model selection for ordinary differential equation (ODE) models while considering fixed change points in a growth curve dataset. It allows for the evaluation of multiple ODE models and considers a specified number of change points.

Arguments:

- `data_testing::Matrix{Float64}`: The dataset with the growth curve, where the first row represents times, and the second row represents optical density (OD).
- `name_well::String`: The name of the well.
- `label_exp::String`: The label of the experiment.
- `list_of_models::Vector{String}`: A vector of ODE models to evaluate.
- `list_lb_param::Any`: Lower bounds for the parameters (compatible with the models).
- `list_ub_param::Any`: Upper bounds for the parameters (compatible with the models).

 Key Arguments:

- `n_change_points::Int`: The number of fixed change points to consider.
- `type_of_loss="L2"`: Type of loss used for optimization(options= "RE", "L2", "L2_derivative" and "blank_weighted_L2").
- `optmizator=BBO_adaptive_de_rand_1_bin_radiuslimited()`: The optimization method to use.
- `integrator=KenCarp4(autodiff=true)`: The integrator for solving the ODE.
- `type_of_detection="lsdd"`: Type of change point detection algorithm. Options are "lsdd" or piecewise linear fitting 
- `type_of_curve="original"`: Type of curve used for the change point detection. Options are "deriv" for the  derivative/specific gr or "orinal" for growth curve.
- `smoothing=false`: Determines whether smoothing is applied to the data.
- `pt_avg=1`: Number of points to generate the initial condition.
- `do_plot=false`: Whether to generate plots or not.
- `path_to_plot="NA"`: Path to save the generated plots.
- `win_size=2`: Number of points for the change point detection algorithm
- `pt_smooth_derivative=0`: Number of points for smoothing the derivative.
- `multiple_scattering_correction=false`: If `true`, uses a given calibration curve to correct the data.
- `calibration_OD_curve="NA"`: The path to the calibration curve used for data correction.
- `beta_smoothing_ms=2.0`: Parameter of the Akaike Information Criterion (AIC) penalty for multiple scattering correction.


## Fitting segmented ODE with direct search for a maximum number of change-points 
```
ODE_selection_NMAX_change_points(data_testing::Matrix{Float64}, 
    name_well::String, 
    label_exp::String, 
    list_lb_param::Any, 
    list_ub_param::Any, 
    list_of_models::Vector{String}, 
    n_max_change_points::Int; 
    optmizator =   BBO_adaptive_de_rand_1_bin_radiuslimited(),  
    integrator = KenCarp4(autodiff=true),
    type_of_loss="L2", # type of used loss 
    type_of_detection =  "lsdd",
    type_of_curve = "deriv", 
    pt_avg = pt_avg , 
    smoothing= true, 
    do_plot=false, 
    path_to_plot="NA", 
    path_to_results="NA",
    win_size=2, 
    pt_smooth_derivative=7,
    penality_parameter=2.0,
    multiple_scattering_correction="false", 
    calibration_OD_curve="NA",  
   save_all_model=false )
```
This function fits segmented ordinary differential equation (ODE) models to a growth curve dataset using direct search for a maximum number of change-points. It allows for the evaluation of multiple ODE models with a varying number of change-points.

Arguments:

- `data_testing::Matrix{Float64}`: The dataset with the growth curve, where the first row represents times, and the second row represents optical density (OD) or fluorescence.
- `name_well::String`: The name of the well.
- `label_exp::String`: The label of the experiment.
- `list_lb_param::Any`: Lower bounds for the parameters (compatible with the models).
- `list_ub_param::Any`: Upper bounds for the parameters (compatible with the models).
- `list_of_models::Vector{String}`: A vector of ODE models to evaluate.
- `n_max_change_points::Int`: The maximum number of change-points to consider.

Key Arguments:

  
- `optmizator=BBO_adaptive_de_rand_1_bin_radiuslimited()`: The optimization method to use.
- `integrator=KenCarp4(autodiff=true)`: The integrator for solving the ODE.
- `type_of_loss="L2"`: Type of loss used for optimization (options: "L2" for squared loss).
- `type_of_detection="lsdd"`: Type of change point detection algorithm. Options are "lsdd" for piecewise linear fitting on the specific growth rate.
- `type_of_curve="deriv"`: Type of curve used for change point detection. Options are "deriv" for the numerical derivative or "specific_gr" for specific growth rate.
- `pt_avg=pt_avg`: Number of points to generate the initial condition.
- `smoothing=true`: Determines whether smoothing is applied to the data.
- `do_plot=false`: Whether to generate plots or not.
- `path_to_plot="NA"`: Path to save the generated plots.
- `path_to_results="NA"`: Path to save the fitting results.
- `win_size=2`: Number of points for generating the initial condition.
- `pt_smooth_derivative=7`: Number of points for smoothing the derivative.
- `penality_parameter=2.0`: Parameter for penalizing the change in the number of parameters.
- `multiple_scattering_correction=false`: If `true`, uses a given calibration curve to correct the data.
- `calibration_OD_curve="NA"`: The path to the calibration curve used for data correction.
- `save_all_model=false`: If `true`, saves fitting results for all evaluated models.



# The mathematical models
## ODEs for bacterial growth
The models and their parameters are sumarrized in the following table

| Model              | Parameters                     |
|--------------------|-------------------------------|
| "hyper_gompertz"     | gr, N_max, shape              |
| "hyper_logistic"     |  gr, N_max, shape  TO REDO |
| "gbsm_piecewise     | gr, a_1, b_1, c, a_2, b_2     |
| "bertalanffy_richards | gr, N_max, shape              |
| "logistic"           | gr, N_max                     |
| "gompertz"           | gr, N_max                     |
| "baranyi_richards"   | gr, N_max, lag_time, shape    |
| "baranyi_roberts"    | gr, N_max, lag_time, shape_1, shape_2 |
| "huang"              | gr, N_max, lag                |
| "piecewise_damped_logistic" | gr, N_max, lag, shape, linear_const |
| "triple_piecewise_damped_logistic" | gr, N_max, lag, shape, linear_const, t_stationary, linear_lag |
| "triple_piecewise"   | gr, gr_2, gr_3, lag, t_stationary |
| "four_piecewise"     | gr, gr_2, gr_3, gr_4, lag, t_decay_gr, t_stationary |
| "Diauxic_replicator_1" | gr, N_max, lag, arbitrary_const, linear_const TO REDO|
| "Diauxic_replicator_2" | gr, N_max, lag, arbitrary_const, linear_const, growth_stationary TO REDO |
| "Diauxic_piecewise_damped_logistic" | gr, N_max, lag, shape, linear_const, t_stationary, growth_stationary TO REDO|

## Stochastic models for bacterial growth

Monod,Haldane,Blackman,Tesseir,Moser,Aiba-Edwards,Verhulst

## Type of loss functions

`type_of_loss = "L2"`: Minimize the L2 norm of the difference between the numerical solution of an ODE and the given data.

`type_of_loss = "L2_derivative"`: Minimize the L2 norm of the difference between the derivatives of the numerical solution of an ODE and the corresponding derivatives of the data.

`type_of_loss ="RE" `: Minimize the relative error between the solution and data 

`type_of_loss = "blank_weighted_L2"` : Minimize a weighted version of the L2 norm, where the difference between the solution and data is weighted based on a distribution obtained from empirical blank data. 

##  Numerical integration and optimization options

# Examples and benchmark functions
## Simulation example
### ODE simulation
```
model= "hyper_gompertz";
ic=  [0.01];
tstart = 0.0;
tend = 100.0;
delta_t = 0.5;
param =   [0.02 ,  2  , 1]  ;

sim = ODE_sim( model, 
        ic ,
        tstart,
        tend, 
        delta_t,
        Tsit5(),
        param  
  )
  
  ```
  The output is the same of a SciML outputs
  ```
  plot(sim)
  ```
  It is useful to use stiff integrator for piecewise and the more complicated models
  
  ```
model= "triple_piecewise_damped_logistic";
ic=  [0.02];
tstart = 0.0;
tend = 1000.0;
delta_t = 0.5;
param =   [0.013 ,  1.1  ,100.0 , 1.5, 0.01, 800.0, 00.0001]  ;

sim = ODE_sim( model, 
        ic ,
        tstart,
        tend, 
        delta_t,
        KenCarp4(),
        param  
  )


plot(sim)
```
### Stochastic simulation
Call the function `stochastic_sim`
```
sim = stochastic_sim("Monod", #string of the model
    2000, # number of starting cells
    0.900, # starting concentration of the limiting nutrients
    0.0, # start time of the sim
    3000.0, # final time of the sim
    1.0, # delta t for poisson approx
    0.2,
    21.3, # monod constant
    0.02, # massimum possible growth rate
    342.0, # lag time
    0.001,# nutrient consumed per division (conc)
    100.0
)
```
I the dimension 3 of the output you will find the times 

In the dimension 2 of the output you will find the concentration of the limiting nutrients

In the dimension 1 of the output you will find the number of cells  


```
plot(sim[3],sim[2],xlabel="Time", ylabel="# of cells Arb. Units")
plot(sim[3],sim[1],xlabel="Time", ylabel="[conc of nutrient]Arb. Units")
```

## Fitting one file
### Fitting ODE

Download the folder data
Choose the ODE model 
```
model= "piecewise_damped_logistic"
```
Set the lower bound of parameter given the choosen model
```
ub_piece_wise_log =[ 0.03 , 200000.0 , 1200.0 , 30.0 ,  0.01    ]
lb_piece_wise_log =[ 0.0001 , 100.1, 50.00, 0.0 , -0.01   ]
```
Set the paths of data, results, and plots
```
path_to_data = "your_path_to_main_JMAKi_folder/data/" ;
path_to_plot ="your_path_to_plots/";
path_to_results ="your_path_to_results/";
path_to_annotation ="your_path_to_main_JMAKi_folder/data/annotation_S8R_green.csv"
```
Call the function to fit ODE
```
results_green  = fit_one_file_ODE(  "Green_S8R" , # label of the exp
  "exp_S8R_Green.csv",# name of the file to analyze
  path_to_data, # path to the folder to analyze
  path_to_annotation,# path to the annotation of the wells
  path_to_results, # path where save results
  path_to_plot, # path where to save Plots
  model, # string of the used model to do analysis 
  "RE", # type of the loss, relative error
  false, # do smoothing of data with rolling average
  true, #  do and visulaze the plots of data
  true, # verbose
  true , #  write the results
  7, # number of points to do smoothing average
  lb_piece_wise_log,# array of the array of the lower bound of the parameters
  ub_piece_wise_log ,# array of the array of the upper bound of the parameters
  "avg_blank", # type of blank subtraction
  false, # avg of replicate
  false, # error analysis 
  "blank_correction" , # if "thr_correction" it put a thr on the minimum value of the data with blank subracted, if "blank_correction" uses blank distrib to impute negative values
  100.0 # ignored in this case
) 
```
### Fitting Log Lin

Download the folder data

Set the paths of data, results, and plots
```
path_to_data = "your_path_to_main_JMAKi_folder/data/" ;
path_to_plot ="your_path_to_plots/";
path_to_results ="your_path_to_results/";
path_to_annotation ="your_path_to_main_JMAKi_folder/data/annotation_S8R_green.csv"
```
Call the function to Log Lin model
```

path_to_annotation ="G:/JMAKi.jl-main/data/annotation_S8R_red.csv"

results = fit_one_file_Log_Lin(
    "test" , # label of the exp
    "exp_S8R_Red.csv",# name of the file to analyze
    path_to_data, # path to the folder to analyze
    path_to_annotation,# path to the annotation of the wells
    path_to_results, # path where save results
    path_to_plot, # path where to save Plots
    true, # 1 do and visulaze the plots of data
    true, # 1 true verbose
    true, # write results
    7, # number of points to do smoothing average
    9, # number of poits to smooth the derivative
    4, # minimum size of the exp windows in number of smooted points
    "maximum" ,  # how the exp. phase win is selected, "maximum" of "global_thr"
    0.9,# threshold of growth rate in quantile to define the exp windows
    "avg_blank", # string on how to use blank (NO,avg_blank,time_blank)
    false, # if true the average between replicates is fitted. If false all replicate are fitted indipendelitly
    "thr_correction", # if "thr_correction" it put a thr on the minimum value of the data with blank subracted, if "blank_correction" uses blank distrib to impute negative values
    200.0,  # used only if correct_negative == "thr_correction"
    true #  distribution of goodness of fit in the interval of growth rate fitted
)  

```

## Fitting one Data
### ODE
### Log Lin
## Sensitivity analysis
## PINN Usage
