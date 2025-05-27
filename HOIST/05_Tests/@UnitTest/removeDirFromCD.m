function removeDirFromCD(~, dirName)
% function that force-removes a folder from the current directory

try
    warning('off', 'MATLAB:RMDIR:RemovedFromPath');
    rmdir(dirName, 's');
    warning('on', 'MATLAB:RMDIR:RemovedFromPath');
catch
    cprintf('SystemCommand', strcat("The ", dirName, ... 
        " folder was not removed from the current", ...
        " directory.\n"));
end

end

