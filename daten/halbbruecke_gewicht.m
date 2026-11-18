% Kalibrierung der Halbbruecke, Labor 3, Abschnitt 3.3.1.
% Nutzerwerte vom 17.11.2026; keine Nullpunktkorrektur der Rohdaten.
% Bestaetigte Nullmessung: 610 mV bei gespeister, unbelasteter Bruecke.

script_dir = fileparts(mfilename('fullpath'));
project_dir = fileparts(script_dir);
output_dir = fullfile(project_dir, 'bilder', 'plots');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

m_g = [0; 500; 600; 700; 800; 900];
Ua_V = [0.610; 1.92; 2.13; 2.29; 2.46; 2.64];
Ua_handy_V = 1.13;
m_handy_waage_g = 206.1;

% Theoretische Sensitivitaet fuer entgegengesetzte DMS-Aenderungen.
RG_Ohm = 35.7;
R0_Ohm = 1000;
UB_V = 24;
G_erwartet = 1 + 49400 / RG_Ohm;
S_deltaR_V_pro_Ohm = G_erwartet * UB_V / (2 * R0_Ohm);

% Freie lineare Ausgleichsrechnung: Ua = S_m * m + b.
p = polyfit(m_g, Ua_V, 1);
S_m_V_pro_g = p(1);
b_V = p(2);
Ua_fit_V = polyval(p, m_g);
R2 = 1 - sum((Ua_V - Ua_fit_V).^2) / sum((Ua_V - mean(Ua_V)).^2);
m_handy_formal_g = (Ua_handy_V - b_V) / S_m_V_pro_g;
abweichung_g = m_handy_formal_g - m_handy_waage_g;
abweichung_prozent = 100 * abweichung_g / m_handy_waage_g;
p_belastet = polyfit(m_g(2:end), Ua_V(2:end), 1);
max_residuum_V = max(abs(Ua_V - Ua_fit_V));
Ua_handy_erwartet_V = polyval(p, m_handy_waage_g);

fig = figure('Visible', 'off', 'Color', 'w', ...
    'Units', 'centimeters', 'Position', [2 2 16 11]);
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');
box(ax, 'on');
set(ax, 'FontName', 'Arial', 'FontSize', 10, 'Layer', 'top');
blue = [0.125 0.298 0.376];

plot(ax, [0 900], polyval(p, [0 900]), '-', ...
    'Color', blue, 'LineWidth', 1.5, ...
    'DisplayName', 'Ausgleichsgerade mit Nullmessung');
plot(ax, [0 500], polyval(p_belastet, [0 500]), ...
    '--', 'Color', [0.50 0.50 0.50], 'LineWidth', 1.1, ...
    'DisplayName', 'Extrapolation nur aus 500-900 g');
plot(ax, [500 900], polyval(p_belastet, [500 900]), ...
    ':', 'Color', [0.50 0.50 0.50], 'LineWidth', 1.3, ...
    'HandleVisibility', 'off');
plot(ax, m_g(2:end), Ua_V(2:end), 'o', 'Color', blue, ...
    'MarkerFaceColor', blue, 'MarkerSize', 5, ...
    'DisplayName', 'Referenzgewichte');
plot(ax, m_handy_waage_g, Ua_handy_V, 's', ...
    'Color', [0.64 0.15 0.15], 'MarkerFaceColor', [0.64 0.15 0.15], ...
    'MarkerSize', 6, 'DisplayName', 'Handy (Masse laut Vergleichswaage)');
plot(ax, 0, Ua_V(1), '^', 'Color', [0.75 0.40 0.05], ...
    'MarkerFaceColor', 'w', 'MarkerSize', 7, ...
    'DisplayName', 'Nullmessung bei gespeister Bruecke');

xlabel(ax, 'Masse m / g');
ylabel(ax, 'Ausgangsspannung U_a / V');
xlim(ax, [-35 950]);
ylim(ax, [0.45 2.85]);
legend(ax, 'Location', 'northwest', 'FontSize', 8);
exportgraphics(fig, fullfile(output_dir, 'halbbruecke_gewicht.pdf'), ...
    'ContentType', 'vector');
exportgraphics(fig, fullfile(output_dir, 'halbbruecke_gewicht.png'), ...
    'Resolution', 180);
close(fig);

fprintf('S_m = %.9f V/g = %.6f mV/g\n', S_m_V_pro_g, 1000*S_m_V_pro_g);
fprintf('G_erwartet = %.8f; S_deltaR = %.8f V/Ohm\n', ...
    G_erwartet, S_deltaR_V_pro_Ohm);
fprintf('b = %.6f V; R^2 = %.8f\n', b_V, R2);
fprintf('Maximales Spannungsresiduum = %.8f V\n', max_residuum_V);
fprintf('Nur belastet: S_m = %.8f mV/g; b = %.8f V\n', ...
    1000*p_belastet(1), p_belastet(2));
fprintf('Erwartete Spannung bei 206.1 g = %.8f V\n', Ua_handy_erwartet_V);
fprintf('Handymasse aus der Kalibriergeraden = %.6f g\n', m_handy_formal_g);
fprintf('Abweichung zur Waage = %.6f g = %.6f %%\n', ...
    abweichung_g, abweichung_prozent);
