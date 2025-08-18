% Microbial Growth Curve Analysis for Antibiotic Synergy
% Analyzes simultaneous (A+B) and sequential (A-B, B-A) antibiotic dosing
% Uses Loewe Additivity Model to calculate Combination Index (CI) with a 4PL model

clear all; close all; clc;

% diary('analysis_log.txt');

%% Load and Validate Input Data
g_file = 'growth_data.csv'; % Growth File
if ~isfile(g_file)
    error('Cannot find %s in the working directory.', g_file);
end

% Load growth data
g_data = readtable(g_file);

% Clean Dosing_Type column
g_data.Dosing_Type = strtrim(g_data.Dosing_Type); % dosing type
g_data = g_data(~ismissing(g_data.Dosing_Type), :);

% Check columns
columns = {'Time', 'Dose_A', 'Dose_B', 'Growth', 'Dosing_Type'};
if ~all(ismember(columns, g_data.Properties.VariableNames))
    error('Missing required columns in %s: %s', g_file, strjoin(columns, ', '));
end

% Verify dosing types
d_types = {'A+B', 'A-B', 'B-A'};
types = unique(g_data.Dosing_Type);
if ~all(ismember(types, d_types))
    fprintf('Unique Dosing_Type values found:\n');
    disp(types);
    error('Invalid Dosing_Type found. Must be: %s', strjoin(d_types, ', '));
end

%% Load 4PL Parameters
c_file = 'curve_fitting.csv'; % curve_file
curve_file = isfile(c_file);

% Default 4PL parameters
def_para = [0, 1, 1, 2]; % [E_min, E_max, EC50, hill_slope]
lower_bounds = [0, 0.5, 0, 0.1];
upper_bounds = [1, 1, 10, 10];

if curve_file
    c_para = readtable(c_file);
    c_columns = {'Antibiotic', 'E_min', 'E_max', 'm', 'h', ...
                 'E_min_low', 'E_max_low', 'm_low', 'h_low', ...
                 'E_min_up', 'E_max_up', 'm_up', 'h_up'};
    if ~all(ismember(c_columns, c_para.Properties.VariableNames))
        warning('Missing columns in %s. Using default 4PL parameters.', c_file);
        curve_file = false;
    end
end

%% Process Each Dosing Type
Results = table();

for i = 1:length(types)
    c_dosing = types{i};
    fprintf('Analyzing dosing type: %s\n', c_dosing);
    
    % Filter data for this dosing type
    c_data = g_data(strcmp(g_data.Dosing_Type, c_dosing), :);
    
    % Get unique doses and time points
    dos_A = unique(c_data.Dose_A);
    dos_B = unique(c_data.Dose_B);
    t_points = unique(c_data.Time);
    
    % Select time window
    if strcmp(c_dosing, 'A+B')
        v_t = t_points(t_points <= 6); % valid time
    else
        v_t = t_points(t_points > 3 & t_points <= 9);
        % Warn if expected time points are missing
        if ~any(abs(t_points - 3) < 1e-6)
            warning('No data at Time=3 for %s. Data starts at Time=%.2f.', ...
                    c_dosing, min(t_points));
        end
    end
    
    if isempty(v_t)
        warning('No valid time points for %s. Skipping.', c_dosing);
        continue;
    end
    
    % Create dose combinations
    [dose_A_grid, dose_B_grid] = meshgrid(dos_A, dos_B);
    d_comb = [dose_A_grid(:), dose_B_grid(:)];
    num_comb = size(d_comb, 1);
    
    % Dynamic tolerance based on dose range
    tol = 1e-3 * max([max(dos_A), max(dos_B)]);
    
    % Organize growth data with variability
    g_matrix = zeros(length(v_t), num_comb);
    std_matrix = zeros(length(v_t), num_comb);
    for j = 1:num_comb
        dose_A = d_comb(j, 1);
        dose_B = d_comb(j, 2);
        mat = abs(c_data.Dose_A - dose_A) < tol & ...
              abs(c_data.Dose_B - dose_B) < tol & ...
              ismember(c_data.Time, v_t);
        mat_data = c_data(mat, :);
        
        if ~isempty(mat_data)
            mat_data = sortrows(mat_data, 'Time');
            [uni_times, ~, idx] = unique(mat_data.Time);
            if length(uni_times) == length(v_t) && all(abs(uni_times - v_t) < tol)
                mean_g = accumarray(idx, mat_data.Growth, [], @mean);
                std_g = accumarray(idx, mat_data.Growth, [], @std);
                g_matrix(:, j) = mean_g;
                std_matrix(:, j) = std_g;
            else
                warning('Incomplete time points for %s, Dose_A=%.2f, Dose_B=%.2f. Found times: %s', ...
                        c_dosing, dose_A, dose_B, num2str(uni_times'));
                g_matrix(:, j) = NaN;
                std_matrix(:, j) = NaN;
            end
        else
            warning('No data for %s, Dose_A=%.2f, Dose_B=%.2f.', ...
                    c_dosing, dose_A, dose_B);
            g_matrix(:, j) = NaN;
            std_matrix(:, j) = NaN;
        end
    end
    
    %% Fit 4PL Model to Individual Antibiotics
    four_pl = @(p, x) p(1) + (p(2) - p(1)) ./ (1 + (x/p(3)).^(-p(4)));
    
    % Adjust E_max dynamically
    max_g_A = max(c_data.Growth(c_data.Dose_B < tol));
    max_g_B = max(c_data.Growth(c_data.Dose_A < tol));
    
    % Antibiotic A
    if curve_file && any(strcmp(c_para.Antibiotic, 'A'))
        p_A = c_para(strcmp(c_para.Antibiotic, 'A'), :);
        i_A = [p_A.E_min, p_A.E_max, p_A.m, p_A.h];
        lo_A = [p_A.E_min_low, max(p_A.E_max_low, max_g_A), p_A.m_low, p_A.h_low];
        up_A = [p_A.E_min_up, max(p_A.E_max_up, max_g_A), p_A.m_up, p_A.h_up];
    else
        i_A = def_para;
        lo_A = lower_bounds;
        up_A = [upper_bounds(1), max(upper_bounds(2), max_g_A), upper_bounds(3:4)];
    end
    
    idx_A = abs(d_comb(:, 2)) < tol;
    u_d_A = unique(d_comb(idx_A, 1));
    g_A = mean(g_matrix(:, idx_A), 1, 'omitnan')';
    if isempty(g_A) || all(isnan(g_A))
        warning('No valid data for Antibiotic A alone in %s. Skipping.', c_dosing);
        continue;
    end
    [fit_A, resnorm_A] = lsqcurvefit(four_pl, i_A, u_d_A, g_A, lo_A, up_A);
    E_a_min = fit_A(1); E_a_max = fit_A(2); EC50_a = fit_A(3); hill_a = fit_A(4);
    R_squ_A = 1 - resnorm_A / sum((g_A - mean(g_A)).^2);
    
    % Antibiotic B
    if curve_file && any(strcmp(c_para.Antibiotic, 'B'))
        para_B = c_para(strcmp(c_para.Antibiotic, 'B'), :);
        i_B = [para_B.E_min, para_B.E_max, para_B.m, para_B.h];
        lo_B = [para_B.E_min_low, max(para_B.E_max_low, max_g_B), para_B.m_low, para_B.h_low];
        up_B = [para_B.E_min_up, max(para_B.E_max_up, max_g_B), para_B.m_up, para_B.h_up];
    else
        i_B = def_para;
        lo_B = lower_bounds;
        up_B = [upper_bounds(1), max(upper_bounds(2), max_g_B), upper_bounds(3:4)];
    end
    
    idx_B = abs(d_comb(:, 1)) < tol;
    u_d_B = unique(d_comb(idx_B, 2));
    g_B = mean(g_matrix(:, idx_B), 1, 'omitnan')';
    if isempty(g_B) || all(isnan(g_B))
        warning('No valid data for Antibiotic B alone in %s. Skipping.', c_dosing);
        continue;
    end
    [fit_B, resnorm_B] = lsqcurvefit(four_pl, i_B, u_d_B, g_B, lo_B, up_B);
    E_b_min = fit_B(1); E_b_max = fit_B(2); EC50_b = fit_B(3); hill_b = fit_B(4);
    R_squ_B = 1 - resnorm_B / sum((g_B - mean(g_B)).^2);
    
    %% Calculate Combination Index (CI)
    CI = zeros(num_comb, 1);
    CI_normalized = zeros(num_comb, 1);
    mean_g = zeros(num_comb, 1);
    std_g = zeros(num_comb, 1);
    k = 2;
    
    for j = 1:num_comb
        dose_A = d_comb(j, 1);
        dose_B = d_comb(j, 2);
        mean_g(j) = mean(g_matrix(:, j), 'omitnan');
        std_g(j) = mean(std_matrix(:, j), 'omitnan');
        
        ob_growth = mean_g(j);
        if ~isfinite(ob_growth)
            CI(j) = NaN;
            CI_normalized(j) = NaN;
            continue;
        end
        
        % Cap equivalent doses
        max_dose_A = max(dos_A) * 10;
        max_dose_B = max(dos_B) * 10;
        
        if ob_growth > E_a_min && ob_growth < E_a_max
            eq_dose_A = min(EC50_a * ((ob_growth - E_a_min) / (E_a_max - ob_growth))^(1/hill_a), max_dose_A);
        else
            eq_dose_A = max_dose_A;
        end
        
        if ob_growth > E_b_min && ob_growth < E_b_max
            eq_dose_B = min(EC50_b * ((ob_growth - E_b_min) / (E_b_max - ob_growth))^(1/hill_b), max_dose_B);
        else
            eq_dose_B = max_dose_B;
        end
        
        CI(j) = (dose_A / eq_dose_A) + (dose_B / eq_dose_B);
        CI_normalized(j) = min(max(1 / (1 + exp(k * (1 - CI(j)))), 0), 1);
    end
    
    % %% Plot Heatmap
    % [X, Y] = meshgrid(dos_A, dos_B);
    % Z = reshape(CI_normalized, length(dos_B), length(dos_A));
    % 
    % figure('Name', sprintf('Synergy Heatmap: %s', c_dosing));
    % imagesc(dos_A, dos_B, Z, [0, 1]);
    % colormap([linspace(1,0,50)', linspace(0,0,50)', linspace(0,1,50)';
    %           linspace(0,1,50)', linspace(0,1,50)', linspace(1,0,50)']);
    % hold on;
    % contour(X, Y, Z, [0.5, 1], 'k--', 'LineWidth', 1);
    % colorbar;
    % xlabel('Antibiotic A Dose (\mug/mL)');
    % ylabel('Antibiotic B Dose (\mug/mL)');
    % title(sprintf('Combination Index: %s (Red = Synergy, White = Additivity, Blue = Antagonism)', c_dosing));
    % set(gca, 'YDir', 'normal');
    % grid on;
    % hold off;
    % 
    %% Store Results
    d_results = table(d_comb(:, 1), d_comb(:, 2), CI, CI_normalized, ...
                      mean_g, std_g, ...
                      repmat(c_dosing, num_comb, 1), ...
                      repmat(R_squ_A, num_comb, 1), ...
                      repmat(R_squ_B, num_comb, 1), ...
                      'VariableNames', {'Dose_A', 'Dose_B', 'CI', 'CI_normalized', ...
                                        'Mean_Growth', 'Std_Growth', 'Dosing_Type', ...
                                        'R_squared_A', 'R_squared_B'});
    Results = [Results; d_results];
end

%% Save Results
writetable(Results, 'synergy_results.csv');
fprintf('Results saved to synergy_results.csv\n');
% diary off;