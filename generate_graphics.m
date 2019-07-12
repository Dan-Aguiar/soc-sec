function generate_graphics

num_points = 16                 ;
data       = load('results_double.mat', 'surv_change', 'pop_change');


num_years     = 16                                                ;
starting_year = 41                                                ; % Corresponds to 1935
ending_year   = 168                                               ; % Corresponds to 2040
increment     = floor((ending_year - starting_year)/(num_years-1)); % 4 year increments
years         = starting_year:increment:ending_year               ;

%%
%Survival Probabilities
data.surv_change_matrix = data.surv_change;
data.pop_change_matrix  = data.pop_change ;

figure
plot  (years+1900, data.surv_change_matrix.opt_benefit_grid(end, :)./data.surv_change_matrix.opt_benefit_grid(end, 1))
title ('Optimal Benefits for Increasing Survival Probabilities, 1940-2045 ')
xlabel('Survival Probabilities by Year')
ylabel('Optimal Benefit, % of Initial')

figure
plot  (years+1900, data.surv_change_matrix.opt_tax_grid(end, :)./data.surv_change_matrix.opt_tax_grid(end,1))
title ('Optimal Taxes for Increasing Survival Probabilities, 1940-2045 ')
xlabel('Survival Probabilities by Year')
ylabel('Optimal Tax, % of Initial')

figure
plot  (years+1900, data.surv_change_matrix.replacement_rate_grid(end, :))
title ('Replacement Rates for Increasing Survival Probabilities, 1940-2045 ')
xlabel('Survival Probabilities by Year')
ylabel('Replacement Rate, %')


%%
%Population Growth 

pop_growth_grid = linspace(0, 0.02, num_points);

figure
plot  (pop_growth_grid, data.pop_change_matrix.opt_benefit_grid(end, :)./data.pop_change_matrix.opt_benefit_grid(end, 1))
title ('Optimal Benefits for Increasing Population Growth Rate ')
xlabel('Population Growth Rate, 0-2%')
ylabel('Optimal Benefit, % of Initial')

figure
plot  (pop_growth_grid, data.pop_change_matrix.opt_tax_grid(end, :)./data.pop_change_matrix.opt_tax_grid(end, 1))
title ('Optimal Taxes for Increasing Population Growth Rate ')
xlabel('Population Growth Rate, 0-2%')
ylabel('Optimal Tax, % of Initial')

figure
plot  (pop_growth_grid, data.pop_change_matrix.replacement_rate_grid(end, :))
title ('Replacement Rates for Increasing Population Growth Rate')
xlabel('Population Growth Rate, 0-2%')
ylabel('Replacement Rate, %')



end