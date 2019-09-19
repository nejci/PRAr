function pplkPath = pplk_homeDir(subFolder)
% Returns path to subfolder in Pepelka root directory.
% Default subFolder is core.

%%%FIELD-PATH%%%
pplkPath = 'D:\Nejc\LASPP\mojeDelo\clanki\PRAr\code\Pepelka';
%%%FIELD-PATH%%%

if ~exist('subFolder','var') || isempty(subFolder)
    pplkPath = [pplkPath,filesep,'core',filesep];
else
    pplkPath =  [pplkPath,filesep,subFolder,filesep];
end