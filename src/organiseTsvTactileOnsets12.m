clear all
% add bids repo
bidsPath = '/Users/shahzad/GitHubCodes/CPP_BIDS';
addpath(genpath(fullfile(bidsPath,'src')));
addpath(genpath(fullfile(bidsPath,'lib')));



tsvFileName = 'sub-002_ses-001_task-tactileLocalizer2_run-002_events.tsv';
tsvFileFolder = '/Users/shahzad/Files/fMRI/visTacMotionDir/raw/sub-002/ses-001/func';

% Create output file name
outputTag = '_touched.tsv';

% create output file name
outputFileName = strrep(tsvFileName, '.tsv', outputTag);
          
% read the tsv file
output = bids.util.tsvread(fullfile(tsvFileFolder,tsvFileName));

for i=1:length(output.onset)
    
    if strcmp(output.trial_type(i),'response')==0 && mod(output.event(i),2)~=0 && ~isnan(output.event(i+1))%if odd &if next event is not NaN
        output.onset(i)=output.onset(i)+output.duration(i)+output.duration(i+1);
    elseif strcmp(output.trial_type(i),'response')==0 && mod(output.event(i),2)~=0 && isnan(output.event(i+1))%if odd & if next event is NaN
        output.onset(i)=output.onset(i)+output.duration(i)+output.duration(i+2);
    elseif strcmp(output.trial_type(i),'response')==0 && mod(output.event(i),2)==0 %if even
        output.onset(i)= output.onset(i)+output.duration(i)+1;
    end
    
    if strcmp(output.trial_type(i),'response')==0
        output.duration(i)=1.00;
    end
    
end

% Don't do the following modifications with IBI. The IBI we get with the above changes are correct: IBI'-IBI+0.5
% IBI = [6.64115128462964,6.07082142137597,5.25321985559689,6.09699425261356,5.31783353441364,...
%     6.97354113123756,5.71355871611769,6.43022250825241,6.35550551052564,5.13793917779026,...
%     6.34800416317818,6.43420027033546,6.14476216251430,6.82371356020611,6.40219187860096,...
%     6.44331536053155,6.54162278430294,5.25827008795920,6.11177432044627,5.48383606493868,...
%     5.17388745567759,5.23809327360416,5.48652527992660,0];
% 
% IBI=IBI'; 
% ind=0;
% indLastEvent=find(output.event==16);%if the last event is 16th
% for j=3:length(output.onset)
%     if output.event(j)==1 %if a new stim of a block
%         ind=ind+1;
%         output.onset(j)=output.onset(indLastEvent(ind))+1 + IBI(ind);   
%     end
%     if output.event(j)==2 %if 2nd stim of a block
%         output.onset(j)=output.onset(j)-0.5; %subtract 1 for tactileLocalizer1, 0.5 for tactileLocalizer2 these the are ISI
%     end
% end


% convert to tsv structure
output = convertStruct(output);

% save as tsv
bids.util.tsvwrite(fullfile(tsvFileFolder,outputFileName), output);



function structure = convertStruct(structure)
    % changes the structure
    %
    % from struct.field(i,1) to struct(i,1).field(1)

    fieldsList = fieldnames(structure);
    tmp = struct();

    for iField = 1:numel(fieldsList)
        for i = 1:numel(structure.(fieldsList{iField}))
            tmp(i, 1).(fieldsList{iField}) =  structure.(fieldsList{iField})(i, 1);
        end
    end

    structure = tmp;

end

 
 
