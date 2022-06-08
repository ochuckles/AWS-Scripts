%% -----AWS Inventory import and extraction script. Used to find specific keywords-----
% within the standard aws inventory output from an S3 bucket.

%first, import the CSV of your inventory. Use the standard "Data Import"
%GUI interface in matlab, name this awsInv, import as a cell array as a
%cell of string vectors

%Limit the inventory to just the cell array that contains file name and
%locations, then convert that cell into a cellstring
awsInv = readtable('awsInventory.csv','NumberHeaderLines',1);
%awsInv = cellstr(fullInv);  %for the full inventory
%awsInv = tall(cellstr(fullInv)); %for a tall Array of the full inventory
%awsInv = fullInv(:,2); %for the inventory with just the objects
awsInv = tall(awsInv(:,2)); % for a tall array of just objects

%% -----Create the list of items from the full Inventory-----

%index based off of the string contents you are interested in. Eg:
%indA = find(contains(awsInv, 'Events')); 
%will create the index indexA which will find every instance in which 'Events'
%occurs. This is an inclusive inventory that has all occurances of each
%item
indexA = find(contains(awsInv, '2018-07-20_11-06-10'));
indexB = find(contains(awsInv, '2018-07-24_09-58-14'));
indexC = find(contains(awsInv, '2018-07-26_10-30-07'));

%alternatively create a list and title it datalist, that you can loop
%through to create the index
%  for i = 1:length(list1)
%      indexL = find(contains(awsInv, list1(i,1)));
%      index = [index; indexL];
%  end

%Create an "exclusive" list that only includes an index if it contains all
%of the keywords. Eg: the inventory only has Sam event data, not every
%occurance of Sam or Event

indexZ = find(contains(awsInv, 'Events') & contains(awsInv, 'Sam'));

%This section will find a specific date range of interest
% minDate = datenum(datetime(2020, 09, 10));
% maxDate = datenum(datetime(2020, 09, 21));
% dateVector = minDate:maxDate;
% dateFormat = 'yyyy-mm-dd';
% dateRange = cellstr(datestr(dateVector,dateFormat));

%find way to search cell of strings for specific string per cell
% for i = 1:length(dateRange)
%     dateIndex = strfind(awsInv,dateRange(1));
% end
%bool if str in awsinv


%loop through previous exclusive index to create new partial inventory
%(partInv) that you will then create a new index from
% partInv = cell(length(indexZ),1);
% for i = 1:length(indexZ)
%    a = indexZ(i,1);
%    loc = awsInv{a,1};
%    partInv{i} = loc;
% end
% 
% for i =1:length(partInv)
%     indexP = find(contains(partInv, datetimeRange));
% end

%Create a complete index from your various smaller indices if necessary. 

index = [indexA];%;indexB;indexC]; %add other indices here



%% -----Put the list above into the proper format-----

%preset length of our output cell we will be writing to
fullInv = cell(length(index),1);

%Option 1: loop through the index and use it to extract relevant information from
%inventory
% for i = 1:length(index)
%    a = index(i,1);
%    loc = awsInv{a,1};
%    k = i;
%    fullInv{i,1} = loc;
% end

%Option 2: loop through the index and use it to extract relevant information from
%inventory and have the bucket name as the first column
bucketname = 'buffalobackuptransfer';

for i = 1:length(index)
   a = index(i,1);
   loc = awsInv{a,1};
   %k = i;
   fullInv{i,1} = bucketname;
   fullInv{i,2} = loc;
end

%% -----Create the File to upload to AWS-----
%set filename you wish to write your output to. Be sure to use the proper
%extension
filename = 'awsInvAllEventEye.csv';
%write the cell array to a table for export
fullInvTable = cell2table(fullInv);
writetable(fullInvTable,filename,'Delimiter',',')

%be sure to check the csv that matlab creates, it tends to include the
%title of the table
