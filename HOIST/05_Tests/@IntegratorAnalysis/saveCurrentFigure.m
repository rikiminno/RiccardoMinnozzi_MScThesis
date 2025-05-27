function saveCurrentFigure(obj, filename)
startDir = pwd;
cd(obj.analysisResultsFolder);
if ~isfolder("IntegratorAnalysis"), mkdir("IntegratorAnalysis"); end
cd("IntegratorAnalysis");
% expand figure and save
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
saveas(gcf, filename, 'fig');
saveas(gcf, filename, 'jpeg');
cd(startDir);

end