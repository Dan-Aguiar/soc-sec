function [surv_change, pop_change] = generate_results(discount_factor, interest_rate, crra, cons_share)


%% Assigning parameters

% Assigning basic parameters
if ~exist('discount_factor','var')
    params.discount_factor    = 1.015                                 ;
else
    params.discount_factor    = discount_factor                       ;
end

if ~exist('interest_rate','var')
    params.interest_rate      = 1.02                                    ;
else
    params.interest_rate      = interest_rate                           ;
end
params.productivity_profile   = xlsread('productivity_profile.xls',...
                                                 'Sheet1','A1:A60')     ;
params.num_balanced_budgets   = 20                                      ;
params.num_tax_trials         = 10                                      ;
params.num_assets             = 20                                      ;
asset_lb                      = 0.001                                   ;
asset_ub                      = 1000                                    ;
params.asset_grid             = logspace( log(asset_lb)/log(10),...
                                log(asset_ub)/log(10), params.num_assets);
params.max_age                = 80                                       ;
params.wage                   = 1                                        ;

if ~exist('crra','var')
    params.crra      = 5                                                ;
else
    params.crra      = crra                                             ;
end

if ~exist('cons_share','var')
    params.cons_share = 0.40                                            ;
else
    params.cons_share = cons_share                                      ;
end
params.retirement_age       = 46                                        ;

% Importing survival probabilities
params.surv_rates = xlsread('survival_probabilities.xlsx')              ;

% Generating cohort choices
num_years     = 8                                                 ;
starting_year = 41                                                ; % Corresponds to 1940
ending_year   = 168                                               ; % Corresponds to 2067
increment     = floor((ending_year - starting_year)/(num_years-1)); % 4 year increments
years         = starting_year:increment:ending_year               ;
if num_years~=length(years)
    error('Number of years mismatched with year vector length.')
end

% Generating grid of population growth rates
num_pops         = 8                        ; 
pop_growth_rates = linspace(0,0.02,num_pops); % Document values

% Importing survival probabilities

save('params.mat','-struct','params')




%% Solving optimal benefits

% 2 for loops corresponding to sample cohorts and population growth
% rates
s = load('demographics.mat','dying_probs');

opt_benefit_grid      = zeros(1,num_years) ;
opt_tax_grid          = zeros(1,num_years) ;
opt_welfare_grid      = zeros(1,num_years) ;
average_labor_grid    = zeros(1,num_years) ;
budget_error_grid     = zeros(1,num_years) ;
replacement_rate_grid = zeros(1,num_years) ;

parfor iy = 1:num_years
    local_params                  = params                                                     ;
    year                          = years(iy)                                                  ; 
    local_params.surv_rates       = 1 - s.dying_probs(year,21:1:local_params.max_age + 21 - 1)'; %#ok<PFBNS>
    [opt_results, opt_aggregates] = solve_opt_benefit( 0.01, local_params )                    ;
    
    opt_benefit_grid     (iy) = opt_results.benefit                                         ;
    opt_tax_grid         (iy) = opt_results.tax                                             ;
    opt_welfare_grid     (iy) = opt_results.welfare                                         ;
    average_labor_grid   (iy) = opt_aggregates.average_hours                                ;
    budget_error_grid    (iy) = opt_aggregates.government_revenue - opt_aggregates.benefits ;
    replacement_rate_grid(iy) = opt_aggregates.replacement_rate                             ;
end

surv_change.opt_benefit_grid      = opt_benefit_grid     ;
surv_change.opt_tax_grid          = opt_tax_grid         ;
surv_change.opt_welfare_grid      = opt_welfare_grid     ;
surv_change.average_labor_grid    = average_labor_grid   ;
surv_change.budget_error_grid     = budget_error_grid    ;
surv_change.replacement_rate_grid = replacement_rate_grid;

opt_benefit_grid      = zeros(1,num_pops)  ;
opt_tax_grid          = zeros(1,num_pops)  ;
opt_welfare_grid      = zeros(1,num_pops)  ;
average_labor_grid    = zeros(1,num_pops)  ;
budget_error_grid     = zeros(1, num_pops) ;
replacement_rate_grid = zeros(1, num_pops) ;

parfor ip = 1:num_pops
    local_params = params;
    local_params.surv_rates = 1 - s.dying_probs(83,21:1:local_params.max_age + 21 - 1)'; %#ok<PFBNS>
    [opt_results, opt_aggregates] = solve_opt_benefit( pop_growth_rates(ip), local_params );
    opt_benefit_grid     (ip) = opt_results.benefit                                         ;
    opt_tax_grid         (ip) = opt_results.tax                                             ;
    opt_welfare_grid     (ip) = opt_results.welfare                                         ;
    average_labor_grid   (ip) = opt_aggregates.average_hours                                ;
    budget_error_grid    (ip) = opt_aggregates.government_revenue - opt_aggregates.benefits ;
    replacement_rate_grid(ip) = opt_aggregates.replacement_rate                             ;
end

pop_change.opt_benefit_grid      = opt_benefit_grid     ;
pop_change.opt_tax_grid          = opt_tax_grid         ;
pop_change.opt_welfare_grid      = opt_welfare_grid     ;
pop_change.average_labor_grid    = average_labor_grid   ;
pop_change.budget_error_grid     = budget_error_grid    ;
pop_change.replacement_rate_grid = replacement_rate_grid;


%% Saving results
save('results.mat','surv_change','pop_change')

%% Generating graphics





end