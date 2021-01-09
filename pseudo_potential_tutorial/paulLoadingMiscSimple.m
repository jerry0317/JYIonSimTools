function paulLoadingMiscSimple(resultsC)

% **** Function Enabled ****
Radial_Instant = true; % Radial Instantaneous Maximum Potential
Radial_Pseudo = true; % Radial Pseudopotential
Axial_Pseudo = true; % Axial Pseudopotential
Axial_DC = true; % Axial DC Potential 
Radial_SecFreq = true; % Radial Secular Frequency
Axial_SecFreq = true; % Axial Secular Frequency
Ion_Sim = true; % Ion Trajectory Simulation
% **************************

results = resultsC{1};
varSTL = resultsC{2};
varL = resultsC{3};

totalLength = 2*2 + 16.764*2 + 1 + varL;

xRange = [(totalLength/2 - 2) (totalLength/2 + 2)];
xCenter = mean(xRange);
cutoffV = 5e-3;

% Voltage Sequence
RFfreq = 2.3e6;
angFreq = 2 * pi * RFfreq;

DC = [20, 0, 20];
AC = 150;

turnOnTime = 20e-6;

syms t;
symAmps(t) = [DC(1), DC(2), DC(3)*heaviside(t-turnOnTime), AC*cos(angFreq*t)];

% Initial Condition
y0 = [(totalLength - 0.5) 8.2 7.5 -7.8e5 0 0];
T = 100e-6;
m = 88;

% Calculate Pseudopotential
resultRF = paulFieldsSimple(4,varSTL,AC);

% Radial Instantaneous Maximum Potential
if Radial_Instant
figure(21);
[X,Y,Z] = meshgrid(xCenter,0:0.1:16,0:0.1:16);
V = interpolateSolution(resultRF,X,Y,Z);
V = reshape(V,size(X));
y = reshape(Y,[161,161]);
z = reshape(Z,[161,161]);
v = reshape(V,[161,161]);
surf(y,z,v);
xlabel('y (mm)');
ylabel('z (mm)');
zlabel('Potential (V)');
title('Radial Instantaneous Maximum Potential');
end

% Radial Pseudopotential
if Radial_Pseudo
figure(22);
[X,Y,Z] = meshgrid(xCenter,0:0.1:16,0:0.1:16);
V = calcPseudoPot(resultRF,X,Y,Z,RFfreq);
V = reshape(V,size(X));
y = reshape(Y,[161,161]);
z = reshape(Z,[161,161]);
v = reshape(V,[161,161]);
surf(y,z,v);
xlabel('y (mm)');
ylabel('z (mm)');
zlabel('Potential (V)');
title('Radial Pseudopotential');
end

% Axial Pseudopotential
if Axial_Pseudo
figure(23);
[X,Y,Z] = meshgrid(xRange(1):0.005:xRange(2),8,8);
V = calcPseudoPot(resultRF,X,Y,Z,RFfreq);
V = reshape(V,size(X));
plot(X,V);
hold on;
ylabel('Potential (V)');
xlabel('x (mm)');
title('Axial Pseudopotential');
end

% Axial DC Potential
if Axial_DC
figure(24);
[X,Y,Z] = meshgrid(xRange(1):0.1:xRange(2),8,8);
VInterpolate = zeros([3 size(X)]);
for i = 1:3
    VTemp = interpolateSolution(results(i),X,Y,Z);
    VInterpolate(i,:) = reshape(VTemp,size(X));
end
Vs = sum((DC.') .* VInterpolate);
V = Vs(1,:);
plot(X,V);
hold on
ylabel('Potential (V)');
xlabel('x (mm)');
title('Axial DC Potential');
end

%Calculate Secular Frequency
if Radial_SecFreq
% Radial
[Xt,Yt,Zt] = meshgrid(xCenter,4:0.01:12,8);
X = Xt.';
Y = Yt.';
Z = Zt.';
Vpseudo = calcPseudoPot(resultRF,X,Y,Z,RFfreq);
Vpseudo = reshape(Vpseudo,size(X));
VInterpolate = zeros([3 size(X)]);
for i = 1:3
    VTemp = interpolateSolution(results(i),X,Y,Z);
    VInterpolate(i,:) = reshape(VTemp,size(X));
end
Vs = sum((DC.') .* VInterpolate);
V = Vs(1,:);
V = V + Vpseudo;

% figure(28);
% plot(Y,V);
% xlabel('y (mm)');
% ylabel('Potential (V)');
% title('Radial Effective Potential');

[RadialFrequency01,SSRradial01] = harmonicity(Y,V,cutoffV,"Radial Secular Frequency");
fprintf('Radial Secular Frequency: %0.3f kHz\n',RadialFrequency01*1e-3);
fprintf('Sum of Squared Residuals: %0.5e\n',SSRradial01);

end

if Axial_SecFreq
% Axial
[X,Y,Z] = meshgrid(xRange(1):0.005:xRange(2),8,8);
Vpseudo = calcPseudoPot(resultRF,X,Y,Z,RFfreq);
Vpseudo = reshape(Vpseudo,size(X));
VInterpolate = zeros([3 size(X)]);
for i = 1:3
    VTemp = interpolateSolution(results(i),X,Y,Z);
    VInterpolate(i,:) = reshape(VTemp,size(X));
end
Vs = sum((DC.') .* VInterpolate);
V = Vs(1,:);
V = V + Vpseudo;

[AxialFrequency01,SSRaxial01] = harmonicity(X,V,cutoffV,"Axial Secular Frequency");
fprintf('Axial Secular Frequency: %0.3f kHz\n',AxialFrequency01*1e-3);
fprintf('Sum of Squared Residuals: %0.5e\n',SSRaxial01);
end

if Ion_Sim
% Ion Simulations
[trajectory,simTimes,amps] = evolveIonCustom(y0,T,m,5e-9,results,symAmps);

% Ion Trajectories
figure(11);
showModel = createpde();
importGeometry(showModel,varSTL);
pdegplot(showModel,'FaceAlpha', 0.25);
hold on
plot3(trajectory(:,1),trajectory(:,2),trajectory(:,3),'LineWidth',2);
xlim([-5 (totalLength + 5)]);
ylim([0 16]);
zlim([0 16]);
view(20,5)
end