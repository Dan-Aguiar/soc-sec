function produce_cohort_results

params                = load('params.mat')                    ;
demographics          = load('demographics.mat','dying_probs');

pop_growth_rate_1935 = 0.0069                                 ;
pop_growth_rate_2019 = 0.0061                                 ;
pop_growth_rate_2084 = 0.0036                                 ;
years                = [2, 54, 120]                           ;
num_years            = length(years)                          ;

pop_growth_grid      = [pop_growth_rate_1935, pop_growth_rate_2019, pop_growth_rate_2084];

opt_cohort_results   = zeros(num_years, 4);

for iy = 1:num_years
    
   local_params              = params                                                                      ;
   local_params.surv_rates   = 1 - demographics.dying_probs(years(iy), 21:1:local_params.max_age + 21 - 1)';
   [opt_results, ~]          = solve_opt_benefit(pop_growth_grid(iy), local_params)                        ;
   opt_cohort_results(iy, 1) = years(iy) + 1899   ;
   opt_cohort_results(iy, 2) = pop_growth_grid(iy);
   opt_cohort_results(iy, 3) = opt_results.benefit;
   opt_cohort_results(iy, 4) = opt_results.tax    ;
   
end

save('opt_cohort_results.mat', 'opt_cohort_results')

end