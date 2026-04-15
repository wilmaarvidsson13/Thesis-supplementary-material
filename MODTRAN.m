clear;
clc; 
%% ------------------------- Load data ---------------------------------

file1 = readtable('subarctic_summer_1200m.csv'); 
file2 = readtable('subarctic_summer_3100m.csv');
file3 = readtable('subarctic_summer_23km.csv');
file4 = readtable('subarctic_winter_3100m.csv');
file5 = readtable('Tropical_3100m.csv');
file6 = readtable('subarctic_3100m_fog_5kmVIS.csv');
file7 = readtable('subarctic_3100m_fog_10kmVIS.csv');
file8 = readtable('subarctic_3100m_fog_15kmVIS.csv');
file9 = readtable('subarctic_1200m_fog_5kmVIS.csv');
file10 = readtable('subarctic_1200m_fog_10kmVIS.csv');
file11 = readtable('subarctic_1200m_fog_15kmVIS.csv');
file12 = readtable('subarctic_summer_3100m_rain2mm.csv');
file13 = readtable('subarctic_summer_1200m_rain2mm.csv');
file14 = readtable('Tropical_sol_0deg');
file15 = readtable('Tropical_sol_30deg');
file16 = readtable('subarctic_summer_sol_30deg');
file17 = readtable('subarctic_summer_sol_0deg');


%Store loaded tables in a cell array
files = {file1, file2, file3, file4, file5, file6, file7, file8, file9, file10, file11, file12, file13, file14, file15, file16, file17};

%Sore filenamn for labeling plots
filenames = {'Subarctic Summer 1200 m', 'Subarctic Summer 3100 m', 'Subarctic Summer 23 km', 'Subarctic Winter 3100m', 'Tropical 3100m', 'Subarctic Summer 3100m Fog (5km VIS)', 'Subarctic Summer 3100m Fog (10km VIS)', 'Subarctic Summer 3100m Fog (15km VIS)', 'Subarctic Summer 1200m Fog (5km VIS)', 'Subarctic Summer 1200m Fog (10km VIS)', 'Subarctic Summer 1200m Fog (15km VIS)', 'Subarctic Summer 3100m Rain (2mm)', 'Subarctic Summer 1200m Rain (2mm)', 'Tropical, from gorund to TOA at 0 degrees', 'Tropical, from ground to TOA at 30 degrees ', 'Subarctic Summer, from ground to TOA at 0 degrees', 'Subarctic Summer, from ground to TOA at 30 degrees'};

%TOA = 100km

%% -------------------------- Parameters ---------------------------------

%Moving averages
N7 = 7; %for 7 points
N31 = 31; %for 31 points
N71 = 71; %for 71 points

colors = {'r', 'b', 'g', 'k', 'c', 'y', 'm'};

%% --------------------------Selection-------------------------------------

%Select dataset
[selectedData, ok1] = listdlg('PromptString', 'Choose dataset(s):', 'ListString',filenames, 'SelectionMode', 'multiple', 'ListSize', [500, 300]);


if ~ok1 || isempty(selectedData)
    disp('No dataset selected')
    return;
end


% Averaging type selection
dialogOptions = {'Original Data', '7-point Average', '31 -point Average', '71-point Average'};
[choice, ok2] = listdlg('PromptString', 'Choose plot type:', 'ListString', dialogOptions, 'SelectionMode', 'single');

if ~ok2 || isempty(choice)
    disp('No slection made.')
    return;
end

PlotType = choice; 

%Transmittance type slection
transOptions = {'Total transmittance', 'H2O', 'Both'};
[selectedTrans, ok3] = listdlg('PromptString', 'Choose transmittance type:', 'ListString', transOptions, 'SelectionMode', 'single');

if ~ok3 || isempty(choice)
    disp('No slection made.')
    return;
end

TransType = selectedTrans;

%Filter wavelenght selection
filterOptions = {'Bandpass', 'Shortpass', 'RG630', 'RG665', 'RG695', 'RG715', 'RG780', 'RG830', 'RG850', 'RG1000', 'SWIRFilter'};
[selectedFilters, ok4] = listdlg('PromptString', 'Choose filter:', 'ListString', filterOptions, 'SelectionMode', 'multiple');

%% ------------------------ Extract Data ----------------------------------

%Make empty arrays for plotting

wavelength = cell(length(files), 1);
transmittance = cell(length(files), 1);
transH2O = cell(length(files), 1);

%Loop through each file to extract the data
for f = 1:length(files)
    data = files{f};
    
    wavenumber{f} = data{2:end, 2}; %[cm^-1]
    transmittance{f} = data{2:end, 3}; % Total transmittance
    transH2O{f} = data{2:end, 4};
    
    % Convert wavenumber into wavelength 
    wavelength{f} = (1 ./ wavenumber{f})*10^(7) ; %[nm]
    
end


%% ------------------------- Calculations ---------------------------------

trans_avg_7 = cell(length(files),1);
transH2O_avg_7 = cell(length(files),1);

trans_avg_31 = cell(length(files),1);
transH2O_avg_31 = cell(length(files),1);

trans_avg_71 = cell(length(files),1);
transH2O_avg_71 = cell(length(files),1);

for f = 1:length(files)
    trans_avg_7{f} = movmean(transmittance{f}, N7);
    transH2O_avg_7{f} = movmean(transH2O{f}, N7);
    
    trans_avg_31{f} = movmean(transmittance{f}, N31);
    transH2O_avg_31{f} = movmean(transH2O{f}, N31);
   
    trans_avg_71{f} = movmean(transmittance{f}, N71);
    transH2O_avg_71{f} = movmean(transH2O{f}, N71);
end

%% --------------------------- Filters -----------------------------------

filterRanges = struct();

filterRanges.Bandpass = [330, 520];          % Bandpass: 330-520 nm
filterRanges.Shortpass = [400, 700];         % Shortpass: 400-700 nm
filterRanges.RG630 = [630, 1100];             % Longpass: 630-1100 nm
filterRanges.RG665 = [665, 1100];             % Longpass: 665-1100 nm
filterRanges.RG695 = [695, 1100];             % Longpass: 695-1100 nm
filterRanges.RG715 = [715, 1100];             % Longpass: 715-1100 nm
filterRanges.RG780 = [780, 1100];             % Longpass: 780-1100 nm
filterRanges.RG830 = [830, 1100];             % Longpass: 830-1100 nm
filterRanges.RG850 = [850, 1100];             % Longpass: 850-1100 nm
filterRanges.RG1000 = [1000, 1100];           % Longpass: 1000-1100 nm
filterRanges.SWIRFilter = [1400, 1700];      % SWIR: 1400-1700 nm

%% ---------------------------- Plot --------------------------------------

%create plots based on selections

switch PlotType
    case 1 %Original data
        figure(1)
        hold on
        
        for i = 1:length(selectedData)
            f = selectedData(i);
            
            if TransType == 1 % Total Transmittance
                plot(wavelength{f}, transmittance{f}, colors{mod(i-1, length(colors)) + 1}, 'DisplayName', filenames{f});
            elseif TransType == 2 % H2O Transmittance
                plot(wavelength{f}, transH2O{f},'b', 'DisplayName', filenames{f});
            else % Both
                plot(wavelength{f}, transmittance{f}, colors{mod(i-1, length(colors)) + 1}, 'DisplayName', [filenames{f} ' - Total']);
                hold on
                plot(wavelength{f}, transH2O{f}, 'b', 'DisplayName', [filenames{f} ' - H2O']);
            end
        end

        % Add filter lines
        if ~isempty(selectedFilters)
            
            % Get current y-axis limits
            yLim = ylim;
            numFilters = length(selectedFilters);

        % Evenly spaced vertical positions
        yPositions = linspace( ...
            yLim(1) + 0.05*(yLim(2)-yLim(1)), ...
            yLim(2) - 0.05*(yLim(2)-yLim(1)), ...
            numFilters);

        for i = 1:numFilters
            filterName = filterOptions{selectedFilters(i)};

            if isfield(filterRanges, filterName)
                range = filterRanges.(filterName);

                % Draw horizontal line
                hLine = line([range(1), range(2)], ...
                             [yPositions(i), yPositions(i)], ...
                             'Color', 'k', ...
                             'LineStyle', '-', ...
                             'LineWidth', 1.5);

                % Remove from legend
                hLine.Annotation.LegendInformation.IconDisplayStyle = 'off';

                % Optional: endpoints
                h1 = plot(range(1), yPositions(i), 'ko', 'MarkerSize', 4);
                h2 = plot(range(2), yPositions(i), 'ko', 'MarkerSize', 4);

                h1.Annotation.LegendInformation.IconDisplayStyle = 'off';
                h2.Annotation.LegendInformation.IconDisplayStyle = 'off';

                % Optional: label next to line (much better than legend)
                text(range(2) + 10, yPositions(i), filterName, ...
                    'FontSize', 8, 'VerticalAlignment', 'middle');
            end
        end
    end

    % ---- Labels & legend ----
    xlabel('Wavelength (nm)')
    ylabel('Transmittance')
    title('Original Data')

    legend('show', 'Location', 'best')

    grid on
    hold off


    case 2 %N7
        figure(1)
        hold on
        for i = 1:length(selectedData)
            f = selectedData(i);
            
            if TransType == 1 % Total Transmittance
                plot(wavelength{f}, trans_avg_7{f}, colors{mod(i-1, length(colors)) + 1}, 'DisplayName', filenames{f});
            elseif TransType == 2 % H2O Transmittance
                plot(wavelength{f}, transH2O_avg_7{f}, 'b', 'DisplayName', filenames{f});
            else % Both
                plot(wavelength{f}, trans_avg_7{f}, colors{mod(i-1, length(colors)) + 1},'DisplayName', [filenames{f} ' - Total']);
                hold on
                plot(wavelength{f}, transH2O_avg_7{f},'b', 'DisplayName', [filenames{f} ' - H2O']);
            end
        end
      % Add filter lines
        if ~isempty(selectedFilters)
            
            % Get current y-axis limits
            yLim = ylim;
            numFilters = length(selectedFilters);

        % Evenly spaced vertical positions
        yPositions = linspace( ...
            yLim(1) + 0.05*(yLim(2)-yLim(1)), ...
            yLim(2) - 0.05*(yLim(2)-yLim(1)), ...
            numFilters);

        for i = 1:numFilters
            filterName = filterOptions{selectedFilters(i)};

            if isfield(filterRanges, filterName)
                range = filterRanges.(filterName);

                % Draw horizontal line
                hLine = line([range(1), range(2)], ...
                             [yPositions(i), yPositions(i)], ...
                             'Color', 'k', ...
                             'LineStyle', '-', ...
                             'LineWidth', 1.5);

                % Remove from legend
                hLine.Annotation.LegendInformation.IconDisplayStyle = 'off';

                % Optional: endpoints
                h1 = plot(range(1), yPositions(i), 'ko', 'MarkerSize', 4);
                h2 = plot(range(2), yPositions(i), 'ko', 'MarkerSize', 4);

                h1.Annotation.LegendInformation.IconDisplayStyle = 'off';
                h2.Annotation.LegendInformation.IconDisplayStyle = 'off';

                % Optional: label next to line (much better than legend)
                text(range(2) + 10, yPositions(i), filterName, ...
                    'FontSize', 8, 'VerticalAlignment', 'middle');
            end
        end
    end

    % ---- Labels & legend ----
    xlabel('Wavelength (nm)')
    ylabel('Transmittance')
    title('7-point Average')

    legend('show', 'Location', 'best')

    grid on
    hold off
        
   case 3 %N31
        figure(1)
        hold on
        for i = 1:length(selectedData)
            f = selectedData(i);
            
            if TransType == 1 % Total Transmittance
                plot(wavelength{f}, trans_avg_31{f}, colors{mod(i-1, length(colors)) + 1}, 'DisplayName', filenames{f});
            elseif TransType == 2 % H2O Transmittance
                plot(wavelength{f}, transH2O_avg_31{f}, 'b', 'DisplayName', filenames{f});
            else % Both
                plot(wavelength{f}, trans_avg_31{f}, colors{mod(i-1, length(colors)) + 1},'DisplayName', [filenames{f} ' - Total']);
                hold on
                plot(wavelength{f}, transH2O_avg_31{f}, 'b', 'DisplayName', [filenames{f} ' - H2O']);
            end
        end
        % Add filter lines
        if ~isempty(selectedFilters)
            
            % Get current y-axis limits
            yLim = ylim;
            numFilters = length(selectedFilters);

        % Evenly spaced vertical positions
        yPositions = linspace( ...
            yLim(1) + 0.05*(yLim(2)-yLim(1)), ...
            yLim(2) - 0.05*(yLim(2)-yLim(1)), ...
            numFilters);

        for i = 1:numFilters
            filterName = filterOptions{selectedFilters(i)};

            if isfield(filterRanges, filterName)
                range = filterRanges.(filterName);

                % Draw horizontal line
                hLine = line([range(1), range(2)], ...
                             [yPositions(i), yPositions(i)], ...
                             'Color', 'k', ...
                             'LineStyle', '-', ...
                             'LineWidth', 1.5);

                % Remove from legend
                hLine.Annotation.LegendInformation.IconDisplayStyle = 'off';

                % Optional: endpoints
                h1 = plot(range(1), yPositions(i), 'ko', 'MarkerSize', 4);
                h2 = plot(range(2), yPositions(i), 'ko', 'MarkerSize', 4);

                h1.Annotation.LegendInformation.IconDisplayStyle = 'off';
                h2.Annotation.LegendInformation.IconDisplayStyle = 'off';

                % Optional: label next to line (much better than legend)
                text(range(2) + 10, yPositions(i), filterName, ...
                    'FontSize', 8, 'VerticalAlignment', 'middle');
            end
        end
    end

    % ---- Labels & legend ----
    xlabel('Wavelength (nm)')
    ylabel('Transmittance')
    title('31-Point Average')

    legend('show', 'Location', 'best')

    grid on
    hold off


    case 4 %N71
        figure(1)
        hold on
        for i = 1:length(selectedData)
            f = selectedData(i);
            
            if TransType == 1 % Total Transmittance
                plot(wavelength{f}, trans_avg_71{f}, colors{mod(i-1, length(colors)) + 1},'DisplayName', filenames{f});
            elseif TransType == 2 % H2O Transmittance
                plot(wavelength{f}, transH2O_avg_71{f},'b', 'DisplayName', filenames{f});
            else % Both
                plot(wavelength{f}, trans_avg_71{f}, colors{mod(i-1, length(colors)) + 1}, 'DisplayName', [filenames{f} ' - Total']);
                hold on
                plot(wavelength{f}, transH2O_avg_71{f},'b', 'DisplayName', [filenames{f} ' - H2O']);
            end
        end
         % Add filter lines
        if ~isempty(selectedFilters)
            
            % Get current y-axis limits
            yLim = ylim;
            numFilters = length(selectedFilters);

        % Evenly spaced vertical positions
        yPositions = linspace( ...
            yLim(1) + 0.05*(yLim(2)-yLim(1)), ...
            yLim(2) - 0.05*(yLim(2)-yLim(1)), ...
            numFilters);

        for i = 1:numFilters
            filterName = filterOptions{selectedFilters(i)};

            if isfield(filterRanges, filterName)
                range = filterRanges.(filterName);

                % Draw horizontal line
                hLine = line([range(1), range(2)], ...
                             [yPositions(i), yPositions(i)], ...
                             'Color', 'k', ...
                             'LineStyle', '-', ...
                             'LineWidth', 1.5);

                % Remove from legend
                hLine.Annotation.LegendInformation.IconDisplayStyle = 'off';

                % Optional: endpoints
                h1 = plot(range(1), yPositions(i), 'ko', 'MarkerSize', 4);
                h2 = plot(range(2), yPositions(i), 'ko', 'MarkerSize', 4);

                h1.Annotation.LegendInformation.IconDisplayStyle = 'off';
                h2.Annotation.LegendInformation.IconDisplayStyle = 'off';

                % Optional: label next to line (much better than legend)
                text(range(2) + 10, yPositions(i), filterName, ...
                    'FontSize', 8, 'VerticalAlignment', 'middle');
            end
        end
    end

    % ---- Labels & legend ----
    xlabel('Wavelength (nm)')
    ylabel('Transmittance')
    title('71-point Average')

    legend('show', 'Location', 'best')

    grid on
    hold off



end


