function [sexo usuario reconocido fichero scores] = Read_res(fileToRead)

[sexo,usuario,reconocido,fichero,scores] = textread(fileToRead,'%s %s %d %s %f');


if isempty(scores)
    scores = [];
end

end

