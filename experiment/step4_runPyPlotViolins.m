function step4_runPyPlotViolins()
% Run Python script that draws violin plot
fprintf('Producing violin plots ... ');

pyScriptPath = [pwd,filesep,'plotViolins.py'];
commandStr = ['python "',pyScriptPath,'"'];
[status, commandOut] = system(commandStr);
%fprintf(1,'Done. Status is %d.\nOutput:\n%s\n',status,commandOut);
fprintf('[OK]\n');