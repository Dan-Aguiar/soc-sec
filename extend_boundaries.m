function extend_boundaries()

num_points                 = 8                                       ;
cons_share_grid            = linspace(0.2, 0.4, num_points)          ;

surv_change_matrix.opt_benefit_grid   = zeros(num_points, num_points);
surv_change_matrix.opt_tax_grid       = zeros(num_points, num_points);
surv_change_matrix.opt_welfare_grid   = zeros(num_points, num_points);
surv_change_matrix.average_labor_grid = zeros(num_points, num_points);
surv_change_matrix.budget_error_grid  = zeros(num_points, num_points);

pop_change_matrix.opt_benefit_grid    = zeros(num_points, num_points);
pop_change_matrix.opt_tax_grid        = zeros(num_points, num_points);
pop_change_matrix.opt_welfare_grid    = zeros(num_points, num_points);
pop_change_matrix.average_labor_grid  = zeros(num_points, num_points);
pop_change_matrix.budget_error_grid   = zeros(num_points, num_points);


for id = 1:num_points
    [surv_change, pop_change]                   = generate_results(1.015, 1.02, 5, cons_share_grid(id));
    surv_change_matrix.opt_benefit_grid  (id,:) = surv_change.opt_benefit_grid   ;
    surv_change_matrix.opt_tax_grid      (id,:) = surv_change.opt_tax_grid       ;
    surv_change_matrix.opt_welfare_grid  (id,:) = surv_change.opt_welfare_grid   ;
    surv_change_matrix.average_labor_grid(id,:) = surv_change.average_labor_grid ;
    surv_change_matrix.budget_error_grid (id,:) = surv_change.budget_error_grid  ;
    pop_change_matrix.opt_benefit_grid   (id,:) = pop_change.opt_benefit_grid    ;
    pop_change_matrix.opt_tax_grid       (id,:) = pop_change.opt_tax_grid        ;
    pop_change_matrix.opt_welfare_grid   (id,:) = pop_change.opt_welfare_grid    ;
    pop_change_matrix.average_labor_grid (id,:) = pop_change.average_labor_grid  ;
    pop_change_matrix.budget_error_grid  (id,:) = pop_change.budget_error_grid  ;
    
    fprintf('%0.0f%% of balanced budget iterations complete.\n', 100*id/num_points)

end

save  ('results.mat','surv_change_matrix','pop_change_matrix')

figure
plot  (1:num_points, surv_change_matrix.opt_benefit_grid(8, :)./surv_change_matrix.opt_benefit_grid(8, 1))
title ('Optimal Benefits for Increasing Survival Probabilities, 1935-2040 ')
xlabel('Survival Probabilities by Year')
ylabel('Optimal Benefit, % of Initial')

figure
plot  (1:num_points, surv_change_matrix.opt_tax_grid(8, :)./surv_change_matrix.opt_tax_grid(8,1))
title ('Optimal Taxes for Increasing Survival Probabilities, 1935-2040 ')
xlabel('Survival Probabilities by Year')
ylabel('Optimal Tax, % of Initial')

figure
plot  (1:num_points, pop_change_matrix.opt_benefit_grid(8, :)./pop_change_matrix.opt_benefit_grid(8, 1))
title ('Optimal Benefits for Increasing Population Growth Rate ')
xlabel('Population Growth Rate, 0-2%')
ylabel('Optimal Benefit, % of Initial')

figure
plot  (1:num_points, pop_change_matrix.opt_tax_grid(8, :)./pop_change_matrix.opt_tax_grid(8, 1))
title ('Optimal Taxes for Increasing Population Growth Rate ')
xlabel('Population Growth Rate, 0-2%')
ylabel('Optimal Tax, % of Initial')

end