clear
% r is used to rotate a segment to an arbitrary degree. This is handy for when
% the segment is almost perpendicular and crosses the y-axis flipping segments
% erroneously 
r=180;

% This next piece of code will count the number of of CSV and txt files in the
% current folder and open them in a sequential manner. 
d = dir('*.txt');
e = dir('*.csv');
numFiles=length(d);
numCSV=length(e);


folderPath = strsplit(pwd,'/');
folderName = folderPath{end};


% This creates a cell on which all AMB information is stored after being
% processed by the MTA function
MT = cell(1,numFiles);
for fileNum = 1:(numFiles)
    fileName = sprintf('T%02d.txt',fileNum);
    MT{fileNum} = dlmread(fileName);
end

AMB = cell(1,numFiles);

for fileNum = 1:(numFiles)
  [AMB{fileNum}(:,1),AMB{fileNum}(:,2),AMB{fileNum}(:,3),finalAMB(:,fileNum)] = MTA(MT{fileNum});
end

% This creates a cell on which all PM  information is stored after being
% processed by the ROIA function

ROI = cell(1,numCSV);
for fileNum = 1:(numCSV)
    fileName = sprintf('T%02d.csv',fileNum);
    ROI{fileNum} = csvread(fileName,2);
end

Wall = cell(1,numCSV);
for fileNum = 1:(numCSV)
    [Wall{fileNum}(:,1),Wall{fileNum}(:,2)]=ROIA(ROI{fileNum},r);
end

% This turns the lobe height to actual space by multiplying the result of ROIA
% by the resolution of the imaging system.
for i=1:numCSV
    finalWall(:,i)=Wall{i}(:,2)*.212;
end

% This identifies peaks in the segment that have a prominence of at least
% 0.286nm height. Additionally, it inverts the segment horizontally and
%   identifies peaks in the segment for the adjacent cell. These values are
%   saved on peaksWall and peaksWallInv respectively. 
for i=1:numCSV
    [pks,locs,w,~]=findpeaks(finalWall(:,i),500,'MinPeakProminence',0.286,'WidthReference','halfprom');
    peaksWall{i}(:,1)=locs;
    peaksWall{i}(:,2)=pks;
    peaksWall{i}(:,3)=w;
    [pks,locs,w,~]=findpeaks(-finalWall(:,i),500,'MinPeakProminence',0.268,'WidthReference','halfprom');
    peaksWallInv{i}(:,1)=locs;
    peaksWallInv{i}(:,2)=pks;
    peaksWallInv{i}(:,3)=w;
end

% This identifies peaks in the AMB signal that have a prominence of at least
% 0.250 or 1/4 height. These values are saved on the peaksAMB variable. 
for i=1:numFiles
    [pks,locs,~,~]=findpeaks(finalAMB(:,i),500,'MinPeakHeight',.250,'MinPeakProminence',0.25,'WidthReference','halfprom');
    peaksAMB{i}(:,1)=locs;
    peaksAMB{i}(:,2)=pks;
end

%Plot limits calulated
axis=0:(1/499):1;
yliml=min(finalWall(:));
ylimu=max(finalWall(:));

% This calculates intensity of AMBs at the 3-way junctions and at the center of
% the segment saving those values on AMBIntLoc
for fileNum = 1:(numFiles)
  [AMBIntLoc(fileNum,1), AMBIntLoc(fileNum,2)] = AMBLoc(AMB{fileNum});
end

% Creation of figures which are saved as svg files
for i=1:numFiles
    h=figure;
    left_color = [1 0 1];
    right_color = [0 1 0];
    set(h,'defaultAxesColorOrder',[left_color; right_color]);
    yyaxis left;
    plot(axis,finalWall(:,i),'m','linew',3)
    ylim([yliml ylimu])
    xlim([0 1])
    ylabel('Lobe height (µm)','FontSize',12)
    xlabel('Normalized segment length','FontSize',12)
    yyaxis right;
    plot(axis,finalAMB(:,i),'g','linew',3)
    ylim([0 1.1])
    ylabel('Norm. AMB signal','FontSize',12)
    hold on;
    yyaxis left;
%     
    for j=1:size(peaksWall{i},1)
        plot(peaksWall{i}(j,1),peaksWall{i}(j,2),'mv','MarkerFaceColor','m','MarkerEdgeColor','k')
        halfmin=peaksWall{i}(j,1)-(peaksWall{i}(j,3)/2);
        halfpls=peaksWall{i}(j,1)+(peaksWall{i}(j,3)/2);
        apexmin=peaksWall{i}(j,1)-(peaksWall{i}(j,3)/4);
        apexpls=peaksWall{i}(j,1)+(peaksWall{i}(j,3)/4);
        plot([halfmin halfmin],[yliml ylimu],'b:')
        plot([halfpls halfpls],[yliml ylimu],'b:')
        plot([apexmin apexmin],[yliml ylimu],'r:')
        plot([apexpls apexpls],[yliml ylimu],'r:') 
    end
    if isempty(peaksWallInv{i}) ~= 1
        for k=1:size(peaksWallInv{i},1)
            plot(peaksWallInv{i}(k,1),-peaksWallInv{i}(k,2),'m^','MarkerFaceColor','m','MarkerEdgeColor','k')
            InvHalfmin=peaksWallInv{i}(k,1)-(peaksWallInv{i}(k,3)/2);
            InvHalfpls=peaksWallInv{i}(k,1)+(peaksWallInv{i}(k,3)/2);
            InvApexmin=peaksWallInv{i}(k,1)-(peaksWallInv{i}(k,3)/4);
            InvApexpls=peaksWallInv{i}(k,1)+(peaksWallInv{i}(k,3)/4);
            plot([InvHalfmin InvHalfmin],[yliml ylimu],'b:')
            plot([InvHalfpls InvHalfpls],[yliml ylimu],'b:')
            plot([InvApexmin InvApexmin],[yliml ylimu],'r:')
            plot([InvApexpls InvApexpls],[yliml ylimu],'r:')
        end
    end
    yyaxis right;
    for j=1:size(peaksAMB{i},1)
        plot(peaksAMB{i}(j,1),peaksAMB{i}(j,2),'gv','MarkerFaceColor','g','MarkerEdgeColor','k')
    end
    
    saveas(h,sprintf('Timepoint%02d.svg',i));
    close(h);
end

% PCC as a function of time analysis
RHO_Time=diag(corr(finalAMB,abs(finalWall)));
pearson1=figure;
stem(RHO_Time)
xlim([0 (numFiles+1)])
saveas(pearson1,'PearsonTimepoint.svg')
close(pearson1)

% PCC as a funtion of location 
RHO_Position=diag(corr(transpose(finalAMB),transpose(abs(finalWall))));
pearson2=figure;
stem(RHO_Position)
saveas(pearson2,'PearsonLocation.svg')
close(pearson2)

% Persistence plots
PersistAMB = sum(transpose(finalAMB));
PersShapePCC = corr(transpose(PersistAMB),abs(finalWall(:,end)));
pearson3 = figure;
yyaxis left;
plot(finalWall(:,end))
ylabel('Lobe height (µm)','FontSize',12);
xlabel('Normalized segment length','FontSize',12);
yyaxis right;
plot(PersistAMB);
ylabel('Norm. AMB signal','FontSize',12)
title([folderName ', PPC = ' num2str(PersShapePCC)],'FontSize',12);
saveas(pearson3,'PearsonShapeAMBPersistance.svg')
close(pearson3)

% Saves AMB intensity from AMBIntLoc
csvFile=strcat(folderName,'LocBasedAMBInt.dat');
csvwrite(csvFile,AMBIntLoc);

% Clears all variables keeping only useful ones as a .mat file
clear numFiles RHO_Position RHO_Time r
clear locs pks w p d e fileName fileNum i j numCSV  h axis yliml ylimu 
clear apexmin apexpls InvApexmin InvApexpls halfmin halfpls InvHalfmin InvHalfpls
clear RHO pearson1 pearson2 pearson3 k ytmp1 ytmp2 right_color left_color
clear folderPath csvFile PersShapePCC PersistAMB 
save(folderName);
