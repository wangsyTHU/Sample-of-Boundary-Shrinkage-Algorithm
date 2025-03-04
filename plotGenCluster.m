close all


timeTick = linspace(datenum('00:00'), datenum('24:00'), 96+1);
timeTick = [timeTick(Tarray), timeTick(Tarray(end)+deltaT)];

maxPclus =  paramb(1:numT, :);
minPclus = -paramb(numT+1:2*numT, :);
maxRclus =  paramb(2*numT+1:3*numT-1, :);
minRclus = -paramb(3*numT:end, :);

maxPclusVec =  parambVec(1:numT, :);
minPclusVec = -parambVec(numT+1:2*numT, :);
maxRclusVec =  parambVec(2*numT+1:3*numT-1, :);
minRclusVec = -parambVec(3*numT:end, :);

upperBoundColor = "#E76F51";
lowerBoundColor = "#264653";


% --------------------
% equivalent generator power
% --------------------
figure(1); hold on
% Circumscribed
plt11 = stairs(timeTick, [maxPclusVec(:, 1); maxPclusVec(end, 1)], '--', 'LineWidth', 1.5, 'Color', upperBoundColor, 'DisplayName', 'Circumscribed');
plt12 = stairs(timeTick, [minPclusVec(:, 1); minPclusVec(end, 1)], '--', 'LineWidth', 1.5, 'Color', lowerBoundColor, 'DisplayName', 'Circumscribed');
% Inner-approximated
plt13 = stairs(timeTick, [maxPclus; maxPclus(end, :)], 'LineWidth', 1.5, 'Color', upperBoundColor, 'DisplayName', 'Inner-approximated');
plt14 = stairs(timeTick, [minPclus; minPclus(end, :)], 'LineWidth', 1.5, 'Color', lowerBoundColor, 'DisplayName', 'Inner-approximated');

datetick('x', 'HH:MM');
xlim([-inf, inf]);
% ylim([-4, 14]);
set(gca, 'FontName', 'Arial', 'FontSize', 12); 

xlabel('Time', 'FontName', 'Arial', 'FontSize', 12);
ylabel('Power / MW', 'FontName', 'Arial', 'FontSize', 12)

legend([plt11, plt13], 'FontName', 'Arial', 'FontSize', 12)

set(gcf, 'Position', [10  200  700  400])


% --------------------
% ramp rate of equivalent generator
% --------------------
figure(2); hold on
% Circumscribed
plt21 = stairs(timeTick(1:end-1), [maxRclusVec(:, 1); maxRclusVec(end, 1)], '--', 'LineWidth', 1.5, 'Color', upperBoundColor, 'DisplayName', 'Circumscribed');
plt22 = stairs(timeTick(1:end-1), [minRclusVec(:, 1); minRclusVec(end, 1)], '--', 'LineWidth', 1.5, 'Color', lowerBoundColor, 'DisplayName', 'Circumscribed');
% Inner-approximated
plt23 = stairs(timeTick(1:end-1), [maxRclus; maxRclus(end, :)], 'LineWidth', 1.5, 'Color', upperBoundColor, 'DisplayName', 'Inner-approximated');
plt24 = stairs(timeTick(1:end-1), [minRclus; minRclus(end, :)], 'LineWidth', 1.5, 'Color', lowerBoundColor, 'DisplayName', 'Inner-approximated');

datetick('x', 'HH:MM');
xlim([-inf, inf]);
% ylim([-10, 10]);
set(gca, 'FontName', 'Arial', 'FontSize', 12);

xlabel('Time', 'FontName', 'Arial', 'FontSize', 12);
ylabel('Ramp rate', 'FontName', 'Arial', 'FontSize', 12)

legend([plt21, plt23], 'FontName', 'Arial', 'FontSize', 12)

set(gcf, 'Position', [740  200  700  400])

% --------------------
% process of bound shrinkage
% --------------------
figure(3); hold on
plot(outDistVec, 'LineWidth', 1.5, 'Color', lowerBoundColor)
set(gca, 'FontName', 'Arial', 'FontSize', 12);
title('Convergence process', 'FontName', 'Arial', 'FontSize', 12);
xlabel('# Iterations', 'FontName', 'Arial', 'FontSize', 12);
ylabel('Maximum distance', 'FontName', 'Arial', 'FontSize', 12)




