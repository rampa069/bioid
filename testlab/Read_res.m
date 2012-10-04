function [scores datos] = Read_res(fileToRead)

newData1 = dlmread(fileToRead,' ');

%disp(newData1);

if isempty(newData1)
    scores = [];
    datos = [];
else
    scores = newData1(:,5);
    datos = newData1(:,[1:4]);
end

end

