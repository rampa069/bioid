function [scores datos] = Read_res(fileToRead)

%newData1 = textread(fileToRead,'%s %s %d %s %f');

[sexo,usuario,reconocido,fichero,scores] = textread(fileToRead,'%s %s %d %s %f');


if isempty(scores)
    scores = [];
    datos = [];
else
    %scores = newData1(:,5);
    datos = [sexo,usuario,fichero];
end

end

