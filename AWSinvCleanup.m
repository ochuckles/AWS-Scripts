%% AWS Inventory Cleanup
% 
% Used to import, remove any quotations within th inventory, remove any
% replicated key data, and then export as a CSV with the necessary
% information. Some of this is necessary after curating a dataset inventory
% on AWS Athena.
%
% This will not work if you use "versioning" on AWS. A new variable will need
% to be included in the import section and be passed on to the export
% table.
%
% Made by Charles Ian O'Leary, 20220914

function [outputCSV] = AWSinvCleanup(inputCSV)
%% Import the inventory CSV
% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNamesLine = 1;
opts.VariableTypes = ["char", "char", "char"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
inputT = readtable(inputCSV, opts, 'ReadVariableNames', true);

%% Convert to output type
inputC = table2cell(inputT);
numIdx = cellfun(@(x) ~isnan(str2double(x)), inputC);
inputC(numIdx) = cellfun(@(x) {str2double(x)}, inputC(numIdx));


%% Clear temporary variables
 clear opts
 clear numIdx
%% Remove potential extra "
% AWS Athena like to do this when working with strings
if iscellstr(inputC)
    cleanedInv = strrep(inputC(:,:), '"','');
else
    cleanedInv = inputC;
end

%% Remove any duplicate "key" values. 
% This can be a result of loading multiple inventories into AWS Athena on accident
[~,idx]=unique(  strcat(cleanedInv(:,1),cleanedInv(:,2),cleanedInv(:,3)) , 'rows');
if length(idx) > 1
    cleanedInvWD=cleanedInv(idx,:);
end
%% Create a Table with useful Information
% AWS only wants bucket and key values. 
cleanedInvT = cell2table(cleanedInvWD(:,1:2), 'VariableNames',{'bucket' 'key'});
% Write the final CSV with 'cleaned' before input name
outputCSV = strcat('cleaned', inputCSV);
writetable(cleanedInvT,outputCSV, 'WriteVariableNames',false);