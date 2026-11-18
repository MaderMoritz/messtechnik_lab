%% Temperaturmessung mit Halb- und Vollbruecke
% Diese Datei in MATLAB oeffnen und mit "Run" ausfuehren.
% Alle Messwerte stehen direkt hier; keine Zusatz-Toolbox erforderlich.
% Es entstehen vier Figuren sowie PNG-, PDF- und FIG-Dateien unter
% bilder/temperaturmessung. Die Figuren bleiben zum Bearbeiten geoeffnet.
%
% Ablauf laut Nutzer: unbelastete Waage, oberer PT1000, Speisung und R_G
% unveraendert. Heizen mit Halbbruecke; bei1234 Ohm Heizung abgeschaltet;
% erst danach Umbau zur Vollbruecke und Messung beim Abkuehlen.
% Die Temperaturen werden aus dem Skriptmodell berechnet. Keine Zeitachse,
% keine Glaettung. Die linearen Naeherungen werden fuer die beiden
% Brueckenschaltungen getrennt berechnet. Der Abschaltpunkt gehoert nicht
% zum Fit der Heizreihe, bleibt aber als eigener Messpunkt sichtbar.

%% Konstanten und Raumtemperaturwerte
R0_Ohm = 1000;                % PT1000 bei0 Grad C
alpha_pro_K = 0.003910;       % Laborskript, Gleichung(3.2)
R_raum_Ohm = 1106;            % Nutzerangabe bei Raumtemperatur
Un_raum_mV = 2.35;            % Nutzerangabe zur RMS-Rauschspannung
T_raum_C = (R_raum_Ohm/R0_Ohm - 1)/alpha_pro_K;
R_60C_Ohm = R0_Ohm*(1 + alpha_pro_K*60);

%% Messwerte: Halbbruecke bei eingeschalteter Heizung
% Spalten: Messpunkt-ID, R/Ohm, Mittelwert/mV, AC-RMS/mV.
% Widerstand: Multimeter; Ausgangsmittelwert und AC-RMS: Oszilloskop.
HB_ein = [
    15 1118 627.1 3.8
    12 1130 666.8 3.3
    17 1140 623.6 3.4
    16 1150 626.3 3.5
    18 1160 616.9 3.6
    20 1170 578.3 3.9
    19 1180 512.4 3.8
    21 1190 473.2 3.8
    13 1200 446.9 3.7
    23 1210 422.4 3.7
    14 1220 405.1 3.8
    22 1229 388.2 3.7
];

% Separater Betriebszustand: noch Halbbruecke, Heizung abgeschaltet.
HB_aus = [24 1234 273.2 1.6];

%% Messwerte: Vollbruecke beim Abkuehlen, Heizung aus
VB = [
    25 1220 280.8 1.7
    26 1207 296.6 1.7
    28 1200 307.0 2.1
    27 1190 308.5 2.3
    29 1180 321.4 2.3
    31 1170 321.9 2.0
    32 1151 304.0 3.6
];
% Der zweite1180-Ohm-Messpunkt wurde auf Nutzerwunsch entfernt.
% Am Messpunkt bei1151 Ohm trat ein kurzer Signalausschlag auf.

%% Widerstand in Temperatur umrechnen
T_HB_C = (HB_ein(:,2)/R0_Ohm - 1)/alpha_pro_K;
T_aus_C = (HB_aus(:,2)/R0_Ohm - 1)/alpha_pro_K;
T_VB_C = (VB(:,2)/R0_Ohm - 1)/alpha_pro_K;

% Die Mittelwerte und AC-RMS-Werte stehen bereits in mV.
% Eine Umrechnung in Volt waere: Ua_V = HB_ein(:,3)/1000.
% Ua(T) der unbelasteten Waage ist die Nullpunktdrift, kein Gain und keine
% separat gemessene Massensensitivitaet in V/g.

%% Temperaturabhaengigkeit der Verstaerkerausgangsspannung
% Lineares Modell: Ua_mV = p(1)*T_C + p(2).
% polyfit(...,1) bestimmt Steigung und Achsenabschnitt durch Minimierung
% der Summe (Ua_gemessen - Ua_Modell).^2. Jeder Messpunkt hat gleiches Gewicht.
% In diesem Modell ist dUa/dT = p(1), Einheit mV/K.
% Ein Temperaturunterschied von1 Grad C entspricht1 K.
% Dies ist eine Naeherung im gemessenen Bereich, kein Verstaerkungsfaktor G(T).
p_HB = polyfit(T_HB_C,HB_ein(:,3),1); % nur Heizung ein, alle12 Punkte
p_VB = polyfit(T_VB_C,VB(:,3),1);     % alle7 verbleibenden Kuehlpunkte
k_HB_mV_K = p_HB(1);
k_VB_mV_K = p_VB(1);
Ua_HB_fit_mV = polyval(p_HB,T_HB_C);
Ua_VB_fit_mV = polyval(p_VB,T_VB_C);
residuen_HB_mV = HB_ein(:,3) - Ua_HB_fit_mV;
residuen_VB_mV = VB(:,3) - Ua_VB_fit_mV;
% R^2 beschreibt den Anteil der durch die Gerade erklaerten Streuung.
% Es ist keine Messunsicherheit und kein Nachweis fuer einen linearen Verlauf.
R2_HB = 1 - sum(residuen_HB_mV.^2)/sum((HB_ein(:,3)-mean(HB_ein(:,3))).^2);
R2_VB = 1 - sum(residuen_VB_mV.^2)/sum((VB(:,3)-mean(VB(:,3))).^2);
T_HB_fit_C = linspace(min(T_HB_C),max(T_HB_C),100);
T_VB_fit_C = linspace(min(T_VB_C),max(T_VB_C),100);

%% Lineare Regressionen der AC-RMS-Werte
% HB: nur12 Heizpunkte, Abschaltpunkt1234 Ohm nicht im Fit.
% Raumtemperaturwert bleibt dokumentiert, erscheint aber nicht im Plot/Fit.
p_HB_RMS = polyfit(T_HB_C,HB_ein(:,4),1);
% VB:1151-Ohm-Punkt bleibt normal dargestellt, wird wegen des kurzen
% Signalausschlags aber nur aus der RMS-Regression ausgeschlossen.
fit_VB_RMS = VB(:,1) ~= 32;
p_VB_RMS = polyfit(T_VB_C(fit_VB_RMS),VB(fit_VB_RMS,4),1);
R2_HB_RMS = 1-sum((HB_ein(:,4)-polyval(p_HB_RMS,T_HB_C)).^2) ...
    /sum((HB_ein(:,4)-mean(HB_ein(:,4))).^2);
R2_VB_RMS = 1-sum((VB(fit_VB_RMS,4) ...
    -polyval(p_VB_RMS,T_VB_C(fit_VB_RMS))).^2) ...
    /sum((VB(fit_VB_RMS,4)-mean(VB(fit_VB_RMS,4))).^2);
T_VB_RMS_fit_C = linspace(min(T_VB_C(fit_VB_RMS)), ...
    max(T_VB_C(fit_VB_RMS)),100);

%% Ausgabeordner relativ zu dieser Skriptdatei
skript_ordner = fileparts(mfilename('fullpath'));
projekt_ordner = fileparts(skript_ordner);
ausgabe_ordner = fullfile(projekt_ordner,'bilder','temperaturmessung');
if ~exist(ausgabe_ordner,'dir')
    mkdir(ausgabe_ordner);
end
blau = [0 0.447 0.741];
rot = [0.85 0.10 0.10];

%% 1. Halbbruecke: Ausgangsmittelwert ueber Temperatur
fig_hb_ua = figure('Name','Halbbruecke: Ausgangsspannung','Color','w', ...
    'Units','centimeters','Position',[2 2 17 11]);
plot([T_HB_C;T_aus_C],[HB_ein(:,3);HB_aus(:,3)],'o', ...
    'Color',blau,'MarkerFaceColor',blau,'DisplayName','Messwerte Halbbruecke');
hold on
plot(T_HB_fit_C,polyval(p_HB,T_HB_fit_C),'--','Color',rot, ...
    'LineWidth',1.4,'DisplayName',sprintf('Linearer Fit: %.3f mV/K',k_HB_mV_K));
hold off
grid on
xlabel('Temperatur oberer PT1000 T [Grad C]');
ylabel('Ausgangsmittelwert U_a [mV]');
legend('Location','northeast');
xlim([27 62]); ylim([240 720]);

%% 2. Halbbruecke: AC-RMS ueber Temperatur
fig_hb_rauschen = figure('Name','Halbbruecke: Rauschspannung','Color','w', ...
    'Units','centimeters','Position',[3 3 17 11]);
plot([T_HB_C;T_aus_C],[HB_ein(:,4);HB_aus(:,4)],'o', ...
    'Color',blau,'MarkerFaceColor',blau,'DisplayName','Messwerte Halbbruecke');
hold on
plot(T_HB_fit_C,polyval(p_HB_RMS,T_HB_fit_C),'--','Color',rot, ...
    'LineWidth',1.4,'DisplayName',sprintf('Linearer Fit: %.4f mV/K',p_HB_RMS(1)));
hold off
grid on
xlabel('Temperatur oberer PT1000 T [Grad C]');
ylabel('AC-RMS am Ausgang [mV]');
legend('Location','southwest');
xlim([27 62]); ylim([1.2 4.3]);

%% 3. Vollbruecke: Ausgangsmittelwert ueber Temperatur
fig_vb_ua = figure('Name','Vollbruecke: Ausgangsspannung','Color','w', ...
    'Units','centimeters','Position',[4 4 17 11]);
plot(T_VB_C,VB(:,3),'s','Color',blau,'MarkerFaceColor',blau, ...
    'MarkerSize',6,'DisplayName','Vollbruecke, Abkuehlung');
hold on
plot(T_VB_fit_C,polyval(p_VB,T_VB_fit_C),'--','Color',rot, ...
    'LineWidth',1.4,'DisplayName',sprintf('Linearer Fit: %.3f mV/K',k_VB_mV_K));
hold off
grid on
xlabel('Temperatur oberer PT1000 T [Grad C]');
ylabel('Ausgangsmittelwert U_a [mV]');
legend('Location','southwest');
xlim([36 59]); ylim([270 335]);

%% 4. Vollbruecke: AC-RMS ueber Temperatur
fig_vb_rauschen = figure('Name','Vollbruecke: Rauschspannung','Color','w', ...
    'Units','centimeters','Position',[5 5 17 11]);
plot(T_VB_C,VB(:,4),'s','Color',blau,'MarkerFaceColor',blau, ...
    'MarkerSize',6,'DisplayName','Vollbruecke, Abkuehlung');
hold on
plot(T_VB_RMS_fit_C,polyval(p_VB_RMS,T_VB_RMS_fit_C),'--','Color',rot, ...
    'LineWidth',1.4,'DisplayName',sprintf('Linearer Fit: %.4f mV/K',p_VB_RMS(1)));
hold off
grid on
xlabel('Temperatur oberer PT1000 T [Grad C]');
ylabel('AC-RMS am Ausgang [mV]');
legend('Location','northeast');
xlim([36 59]); ylim([1.3 4.0]);

%% Figuren und Wertetabellen speichern
figuren = [fig_hb_ua fig_hb_rauschen fig_vb_ua fig_vb_rauschen];
namen = {'halbbruecke_ua_temperatur','halbbruecke_rauschen_temperatur', ...
    'vollbruecke_ua_temperatur','vollbruecke_rauschen_temperatur'};
for k = 1:numel(figuren)
    set(findall(figuren(k),'Type','axes'),'FontName','Arial','FontSize',10);
    exportgraphics(figuren(k),fullfile(ausgabe_ordner,[namen{k} '.png']), ...
        'Resolution',180);
    exportgraphics(figuren(k),fullfile(ausgabe_ordner,[namen{k} '.pdf']), ...
        'ContentType','vector');
    savefig(figuren(k),fullfile(ausgabe_ordner,[namen{k} '.fig']));
end

% Diese Tabellen erscheinen nach dem Ausfuehren im MATLAB-Workspace.
halbbruecke = array2table([HB_ein;HB_aus], ...
    'VariableNames',{'Messpunkt_ID','R_Ohm','Ua_Mittel_mV','AC_RMS_mV'});
halbbruecke.T_C = [T_HB_C;T_aus_C];
halbbruecke.Heizung_ein = [true(size(HB_ein,1),1);false];
halbbruecke.In_Ua_Regression = halbbruecke.Heizung_ein;
halbbruecke.In_RMS_Regression = halbbruecke.Heizung_ein;
vollbruecke = array2table(VB, ...
    'VariableNames',{'Messpunkt_ID','R_Ohm','Ua_Mittel_mV','AC_RMS_mV'});
vollbruecke.T_C = T_VB_C;
vollbruecke.In_Ua_Regression = true(size(VB,1),1);
vollbruecke.In_RMS_Regression = fit_VB_RMS;
writetable(halbbruecke,fullfile(ausgabe_ordner,'halbbruecke_werte.csv'));
writetable(vollbruecke,fullfile(ausgabe_ordner,'vollbruecke_werte.csv'));
disp(halbbruecke)
disp(vollbruecke)
fprintf('Raumtemperatur aus1106 Ohm: %.2f Grad C\n',T_raum_C);
fprintf('Berechneter Widerstand bei60 Grad C: %.1f Ohm\n',R_60C_Ohm);
fprintf('Gemessener Abschaltpunkt: %.0f Ohm = %.2f Grad C\n', ...
    HB_aus(2),T_aus_C);
% Auch als bearbeitbare Ergebnistabelle im Workspace und als CSV speichern.
regression = table(["Halbbruecke_Ua";"Vollbruecke_Ua"; ...
    "Halbbruecke_RMS";"Vollbruecke_RMS"], ...
    [p_HB(1);p_VB(1);p_HB_RMS(1);p_VB_RMS(1)], ...
    [p_HB(2);p_VB(2);p_HB_RMS(2);p_VB_RMS(2)], ...
    [R2_HB;R2_VB;R2_HB_RMS;R2_VB_RMS], ...
    [min(T_HB_C);min(T_VB_C);min(T_HB_C);min(T_VB_C(fit_VB_RMS))], ...
    [max(T_HB_C);max(T_VB_C);max(T_HB_C);max(T_VB_C(fit_VB_RMS))], ...
    [numel(T_HB_C);numel(T_VB_C);numel(T_HB_C);sum(fit_VB_RMS)], ...
    'VariableNames',{'Reihe','Steigung_mV_K','Achsenabschnitt_mV', ...
    'R_Quadrat','T_min_C','T_max_C','Anzahl_Fitpunkte'});
writetable(regression,fullfile(ausgabe_ordner,'temperatur_regression.csv'));
disp(regression)
fprintf('\nLineare Naeherungen (Ua in mV, T_C als Zahlenwert in Grad C):\n');
fprintf('Halbbruecke: Ua = %.6f * T_C + %.6f; R^2 = %.6f\n', ...
    p_HB(1),p_HB(2),R2_HB);
fprintf('Vollbruecke: Ua = %.6f * T_C + %.6f; R^2 = %.6f\n', ...
    p_VB(1),p_VB(2),R2_VB);
fprintf('Temperaturkoeffizienten dUa/dT: HB %.6f, VB %.6f mV/K\n', ...
    k_HB_mV_K,k_VB_mV_K);
fprintf('AC-RMS HB: %.9f*T_C + %.9f mV; R^2 = %.6f\n', ...
    p_HB_RMS(1),p_HB_RMS(2),R2_HB_RMS);
fprintf('AC-RMS VB: %.9f*T_C + %.9f mV; R^2 = %.6f\n', ...
    p_VB_RMS(1),p_VB_RMS(2),R2_VB_RMS);
fprintf('Plots gespeichert in: %s\n',ausgabe_ordner);
