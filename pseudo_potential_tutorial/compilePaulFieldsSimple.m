function resultsPaul = compilePaulFieldsSimple(varSTL)
% Runtime: ~ 5 mins

resultLeft = paulFieldsSimple(1,varSTL);
fprintf('Completed left DC electrodes (1/4) \n');

resultMiddle = paulFieldsSimple(2,varSTL);
fprintf('Completed center DC electrodes (2/4) \n');

resultRight = paulFieldsSimple(3,varSTL);
fprintf('Completed right DC electrodes (3/4) \n');

resultRF = paulFieldsSimple(4,varSTL);
fprintf('Completed RF rod electrodes (4/4) \n');

if strcmp(varSTL,'STLs/Paul_Var_L0.stl')
    varL = 16.764;
elseif strcmp(varSTL,'STLs/Paul_Var_0.5L0.stl')
    varL = 8.382;
elseif strcmp(varSTL,'STLs/Paul_Var_2L0.stl')
    varL = 33.528;
end

resultsPaul = {[resultLeft, resultMiddle, resultRight, resultRF], varSTL, varL};