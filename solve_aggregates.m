%Subfunction solving for aggregate savings, hours, gov't revenue, etc.
%based on given tax rate, benefit, and population weight.
function [aggregates, profiles] = solve_aggregates(tax_rate, population_weights, benefit, params)
%#codegen
profiles = solve_lifetime_utility(tax_rate, benefit, params); %calls solve_lifetime utility to generate our corresponding profiles

%distributes profiles over population weights to generate aggregates for
%the given population
aggregates.savings            = sum( population_weights.*profiles.savings(1:end-1) ) ;
aggregates.hours              = sum( population_weights.*profiles.hours            ) ;
aggregates.government_revenue = sum( population_weights.*profiles.tax_bill         ) ;
aggregates.consumption        = sum( population_weights.*profiles.consumption      ) ;
aggregates.benefits           = sum( population_weights.*profiles.benefits         ) ;
aggregates.welfare            = sum( population_weights.*profiles.welfare          ) ;
 
end

% Profile generating function; takes in tax_rate and benefit, solves for
% the optimal savings and labor allocations, then interpolates over these
% values and calls solve_value once again at these optimized rates
function profiles = solve_lifetime_utility(tax_rate, benefit, params)

% Preallocate value and policy functions
value_function = zeros( params.num_assets, params.max_age+1);
savings        = zeros( params.num_assets, params.max_age  );
hours          = zeros( params.num_assets, params.max_age  );
tax_bill       = zeros( params.num_assets, params.max_age  );
consumption    = zeros( params.num_assets, params.max_age  );
benefits_total = zeros( params.num_assets, params.max_age  );

% Setting optimization parameters
optim_options = optimset('Display', 'off', 'TolFun', 10e-7, 'TolX', 1e-7,...
                            'MaxFunEvals',10e10,'MaxIter',10e10);

% Solving the agent problem
for age = params.max_age:-1:1
%     fprintf('Solving age %i.\n', age)
    for ia = 1:params.num_assets
        isoptimization = true;
%         initial_guess = [max(params.asset_grid(1),.5*params.asset_grid(ia)),0.9];
        initial_guess = [params.asset_grid(ia),0.5];
        [xopt,fopt] = fminsearch(@(choice_space) solve_value(choice_space, params.asset_grid(ia),...
                         value_function(:,age+1), age, tax_rate, benefit, params, isoptimization),initial_guess, optim_options);
        value_function(ia,age) = -fopt;
        savings       (ia,age) =  xopt(1);
        hours         (ia,age) =  xopt(2);
        %----------------------------------------
        isoptimization = false;
        output = solve_value(xopt, params.asset_grid(ia),...
                         value_function(:,age+1), age, tax_rate, benefit, params, isoptimization);
        tax_bill      (ia,age) = output(1);             
        consumption   (ia,age) = output(2);
        benefits_total(ia,age) = output(3);
    end    
end


% Generating profiles
savings_profile       = zeros(1,params.max_age+1);
hours_profile         = zeros(1,params.max_age  );
tax_bill_profile      = zeros(1,params.max_age  );
consumption_profile   = zeros(1,params.max_age  );
benefits_profile      = zeros(1,params.max_age  );
welfare_profile       = zeros(1,params.max_age  );

savings_profile(1) = params.asset_grid(1);
for age = 1:params.max_age
    savings_profile    (age+1) = interp1( params.asset_grid, savings(:,age), savings_profile        (age) );
    hours_profile      (age  ) = interp1( params.asset_grid, hours  (:,age), savings_profile        (age) );
    welfare_profile    (age  ) = interp1( params.asset_grid, value_function(:, age), savings_profile(age) );
    isoptimization             = false;
    choice_space               = [savings_profile(age+1),hours(age)];
    outputs                    = solve_value(choice_space, savings_profile(age), [], age, tax_rate, benefit, params, isoptimization);
    tax_bill_profile   (age  ) = outputs(1);
    consumption_profile(age  ) = outputs(2);
    benefits_profile    (age ) = outputs(3);
end

profiles.savings     = savings_profile     ;
profiles.hours       = hours_profile       ;
profiles.tax_bill    = tax_bill_profile    ;
profiles.consumption = consumption_profile ;
profiles.benefits    = benefits_profile    ;
profiles.welfare     = welfare_profile     ;

end

% our value and consumption functions: takes in savings choice for next
% period, assets at beginning of period, age, tax rate, benefits, and
% calculates the corresponding utility from these values when optimizing or
% the tax and benefit payments alongside consumption when not optimizing
% during the generation of profiles
function value = solve_value(choice_space, asset, continuation_values, age, tax_rate, benefits, params, isoptimization)

savings_choice = choice_space(1);
hours          = choice_space(2);

% T/F condition for worker or retiree - changes taxes paid, hours worked,
% and benefits received
if age >= params.retirement_age
    retirement_status = 1;
else
    retirement_status = 0;
end

labor_age    = min(age, length(params.productivity_profile))   ;
labor_income = (1 - retirement_status)* ( params.wage *...
                   params.productivity_profile(labor_age) * hours )     ;
tax_bill     = tax_rate * labor_income                         ;
benefits     = retirement_status * benefits                    ;
consumption  = labor_income + params.interest_rate * asset...
                   - savings_choice - tax_bill + benefits      ;

if ~isoptimization %when not optimizing, calculate profile functions for the given individual and parameters
    value = [tax_bill, consumption, benefits];
elseif isoptimization %when optimizing, calculate utility for given individual and parameters
    
    if consumption<=0 || savings_choice<params.asset_grid(1) || savings_choice>params.asset_grid(end) || hours<0 || hours>1
        value = inf;
        return
    end

    utility = (1/(1-params.crra))* ( ( consumption ^ params.cons_share ) * ( (1-hours)^(1-params.cons_share) ) ) ^ (1-params.crra);
    value = utility + params.surv_rates(age)*params.discount_factor*interp1(params.asset_grid,continuation_values,savings_choice);
    value = -1*value;
end

end
