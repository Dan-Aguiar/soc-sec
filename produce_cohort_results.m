function produce_cohort_results

params                = load('params.mat')                    ;
demographics          = load('demographics.mat','dying_probs');

pop_growth_rate_1935 = 0.0069                                 ;
pop_growth_rate_2019 = 0.0061                                 ;
pop_growth_rate_2084 = 0.0036                                 ;
years                = [2, 54, 120]                           ;
num_years            = length(years)                          ;

pop_growth_grid      = [pop_growth_rate_1935, pop_growth_rate_2019, pop_growth_rate_2084];

opt_cohort_results.benefits = zeros(num_years, 1);
opt_cohort_results.taxes    = zeros(num_years, 1);

for iy = 1:num_years
    
   local_params                    = params                                                                      ;
   local_params.surv_rates         = 1 - demographics.dying_probs(years(iy), 21:1:local_params.max_age + 21 - 1)';
   [opt_results, ~]                = solve_opt_benefit(pop_growth_grid(iy), local_params)                        ;
   opt_cohort_results.benefits(iy) = opt_results.benefit                                                         ;
   opt_cohort_results.taxes(iy)    = opt_results.tax                                                             ;
   
end

save('opt_cohort_results.mat', '-struct', 'opt_cohort_results')

end