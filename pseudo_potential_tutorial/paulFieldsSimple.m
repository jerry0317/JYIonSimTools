function result = paulFieldsSimple(i,varSTL,v)
if nargin < 3
    v = 1;
end

% varSTL = 'STLs/Paul_Var_2L0_DC.stl'; % <-- Change here

% model = createpde();
% importGeometry(model,varSTL);
% 
% figure;
% pdegplot(model,'FaceLabels','on','FaceAlpha',0.15);
% xlabel('x');
% ylabel('y');
% zlabel('z');
% title('Geometry of system');

if i == 1
    result = solvepdeOnVarBaseDC(v,0,0,0);
elseif i == 2
    result = solvepdeOnVarBaseDC(0,v,0,0);
elseif i == 3
    result = solvepdeOnVarBaseDC(0,0,v,0);
elseif i == 4
    result = solvepdeOnVarBaseDC(0,0,0,v);
end

    function result = solvepdeOnVarBaseDC(vLeft,vMiddle,vRight,RF)
        model = createpde();
        importGeometry(model,varSTL);
        
        applyBoundaryCondition(model,'dirichlet','face',1:6,'u',0); % Ground Boundaries
        if strcmp(varSTL,'STLs/Paul_Var_L0.stl')
            applyBoundaryCondition(model,'dirichlet','face',[37:50,51:64],'u',RF); % RF
            applyBoundaryCondition(model,'dirichlet','face',[17:26,85:94],'u',vLeft); % Left DC
            applyBoundaryCondition(model,'dirichlet','face',[7:16,65:74],'u',vMiddle); % Middle DC
            applyBoundaryCondition(model,'dirichlet','face',[27:36,75:84],'u',vRight); % Right DC
        elseif strcmp(varSTL,'STLs/Paul_Var_0.5L0.stl')
            applyBoundaryCondition(model,'dirichlet','face',[30:43,44:57],'u',RF); % RF
            applyBoundaryCondition(model,'dirichlet','face',[61:70,71:80],'u',vLeft); % Left DC
            applyBoundaryCondition(model,'dirichlet','face',[27:29,58:60],'u',vMiddle); % Middle DC
            applyBoundaryCondition(model,'dirichlet','face',[7:16,17:26],'u',vRight); % Right DC
        elseif strcmp(varSTL,'STLs/Paul_Var_2L0.stl')
            applyBoundaryCondition(model,'dirichlet','face',[23:36,37:50],'u',RF); % RF
            applyBoundaryCondition(model,'dirichlet','face',[61:63,64:66],'u',vLeft); % Left DC
            applyBoundaryCondition(model,'dirichlet','face',[13:22,51:60],'u',vMiddle); % Middle DC
            applyBoundaryCondition(model,'dirichlet','face',[7:9,10:12],'u',vRight); % Right DC
        end
        
        specifyCoefficients(model,'m',0,'d',0,'c',1,'a',0,'f',0);
        %Laplace's equation: https://www.mathworks.com/help/pde/ug/equations-you-can-solve.html

        generateMesh(model,'hmax',0.7);
        result = solvepde(model);
        
    end


end

% FinalPaul Faces: 60
%   Outer Boundaries: 1:6
%   Lower RF: 22:33  
%   Upper RF: 34:45
%   DC layout:
%
%   =======     =======     =======     =======     =======
%   =19:21=     = 7:9 =     =10:12=     =16:18=     =13:15=
%   =======     =======     =======     =======     =======
%
%
%   =======     =======     =======     =======     =======
%   =46:48=     =49:51=     =52:54=     =55:57=     =58:60=
%   =======     =======     =======     =======     =======
%     ^           ^           ^           ^           ^
%     |           |           |           |           |
%    i=1         i=2         i=3         i=4         i=5
%
%   2 RF rods (not shown): i=6
%
%       Looking at the model from view(0,0)




