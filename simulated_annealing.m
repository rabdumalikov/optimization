%  Copyright (c) 2017-present Rustam Abdumalikov
%
%  "FunctionOptimizer" application
%
% Distributed under the Boost Software License, Version 1.0. (See
% accompanying file LICENSE_1_0.txt or copy at
% http://www.boost.org/LICENSE_1_0.txt)

function traces = simulated_annealing( objective_func, start_point, maxiter, tol, step_size, activate_logs )
%% constants
Tinit = 100; % initial temperature
alpha = 0.8;
max_consec_rejections = 10;
max_success = 10;

% counters etc
iteration_counter = 0;
amount_successes = 0;
consec = 0;
T = Tinit;
start_point_value = objective_func(start_point);
total_amount_of_iterations = 0;
finished = false;

traces = [ start_point, start_point_value ];

while ~finished
    
    next_point = generate_new_point(start_point, step_size);
    next_point_value = objective_func(next_point);
    
    delta_f = next_point_value - start_point_value;
    
    %% new solution is better, so accept it.
    if delta_f < 0
        start_point = next_point;
        start_point_value = next_point_value;
        amount_successes = amount_successes + 1;
        
        % save current point
        traces = [ traces; [ start_point, start_point_value ] ];

        consec = 0;
    else
        %% accept new solution, even bad one, based on probability. delta_f ~= 0 &&
        if( rand < accept_solution( delta_f, T ) ) 
            start_point = next_point;
            start_point_value = next_point_value;
            amount_successes = amount_successes + 1;
            
            % save current point
            traces = [ traces; [ start_point, start_point_value ] ];

        else
            consec = consec+1;
        end
    end
     
    %% Algorithm Termination criteria
    if iteration_counter >= maxiter || amount_successes >= max_success
        
        total_amount_of_iterations = total_amount_of_iterations + iteration_counter;
        
        if T < tol || consec >= max_consec_rejections
            finished = true;
        else
            % decrease T according to cooling schedule
            T = lower_temperature( T, alpha ); 

            iteration_counter = 1;  
            amount_successes = 1;
        end
    end
    
    iteration_counter = iteration_counter + 1; % just an iteration counter
    
end

fval = start_point_value;

if activate_logs
    fprintf(1, '\n  Initial temperature:   \t%g\n', Tinit);
    fprintf(1, '  Final temperature:       \t%g\n', T);
    fprintf(1, '  Consecutive rejections:  \t%i\n', consec);
    fprintf(1, '  Number of function calls:\t%i\n', total_amount_of_iterations);
    fprintf(1, '  Total final loss:        \t%g\n', fval);
end

function result = lower_temperature( T, alpha )
    result = alpha * T;
    
function point = generate_new_point( current_point, step_size )
    offset = -step_size + (step_size+step_size)*rand(1,2)
    %offset = ( randperm(length(current_point)) == length(current_point) ) * randn / ( rand * step_size )    
    point = current_point + offset;  

function result = accept_solution( delta_f, current_temperature )
        k = 1;%1.380649*10^(-23);    
        result = exp( -delta_f/(k*current_temperature));