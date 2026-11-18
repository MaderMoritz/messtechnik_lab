%% Vollbruecken-Kalibrierung und Filtervergleich, Labor3
% In MATLAB oeffnen und Run ausfuehren. Messwerte hier direkt bearbeiten.
% Keine zusaetzliche Toolbox. Die Figur bleibt zum Bearbeiten geoeffnet.
% Vollbruecken-Lastreihe: Balken noch warm, Temperatur unbekannt.
% Den PT1000-Wert der separaten Filtermessung NICHT auf die Lastreihe uebertragen.

%% Lastmessungen: Masse in g, Ausgangsspannung in V
m_VB_g = [400;500;600;700;800;900];
Ua_VB_V = [2.17;2.57;3.01;3.42;3.84;4.18]; % 3.01 V vom Nutzer bestaetigt
% Bereits dokumentierte Halbbruecken-Referenzmessung:
m_HB_g = [0;500;600;700;800;900];
Ua_HB_V = [0.610;1.92;2.13;2.29;2.46;2.64];

%% Lineare Regression Ua = S*m + b
p_VB = polyfit(m_VB_g,Ua_VB_V,1);
p_HB = polyfit(m_HB_g,Ua_HB_V,1);
S_VB_mV_g = 1000*p_VB(1);
S_HB_mV_g = 1000*p_HB(1);
Ua_VB_Modell_V = polyval(p_VB,m_VB_g);
residuen_VB_V = Ua_VB_V-Ua_VB_Modell_V;
R2_VB = 1-sum(residuen_VB_V.^2)/sum((Ua_VB_V-mean(Ua_VB_V)).^2);
verhaeltnis_gesamte_reihen = p_VB(1)/p_HB(1);
% b ist ein extrapolierter Achsenabschnitt, keine gemessene Nullspannung.
% Eine Nullmessung der warmen Vollbruecke liegt nicht vor.

%% Zusatzvergleich im gemeinsamen Lastbereich500-900 g
idx_VB = m_VB_g>=500 & m_VB_g<=900;
idx_HB = m_HB_g>=500 & m_HB_g<=900;
p_VB_gemeinsam = polyfit(m_VB_g(idx_VB),Ua_VB_V(idx_VB),1);
p_HB_gemeinsam = polyfit(m_HB_g(idx_HB),Ua_HB_V(idx_HB),1);
verhaeltnis_gemeinsam = p_VB_gemeinsam(1)/p_HB_gemeinsam(1);
% Gleicher Lastbereich beseitigt den Unterschied der Temperaturbedingungen
% nicht. Die Verhaeltnisse beweisen keinen isolierten Brueckeneffekt.

%% Filtermessung: eigene Messbedingungen
R_PT1000_Ohm = 1138;
R0_Ohm = 1000;
alpha_pro_K = 0.003910; % Laborskript Gl.(3.2)
T_Filter_C = (R_PT1000_Ohm/R0_Ohm-1)/alpha_pro_K;
Un_ungefiltert_V = 2.7e-3;
Un_gefiltert_V = 150e-6;
rauschfaktor = Un_ungefiltert_V/Un_gefiltert_V;
verbleibend_prozent = 100/rauschfaktor;
reduktion_prozent = 100-verbleibend_prozent;
reduktion_dB = 20*log10(rauschfaktor); % positiver Wert fuer die Reduktion
% Das ist das Verhaeltnis zweier gemessener Gesamt-RMS-Werte, keine
% Daempfung bei einer einzelnen Frequenz und kein Rauschquellennachweis.

%% Tatsaechlich verwendete RC-Bauteilwerte laut Nutzer
% Letzte Nutzerkorrektur:22 kOhm und1 uF, vorherige220-kOhm-Angabe ueberholt.
RF_Ohm = 22e3;
CF_F = 1e-6;
fg_Hz = 1/(2*pi*RF_Ohm*CF_F);
tau_s = RF_Ohm*CF_F;
daempfung_50Hz_dB = 10*log10(1+(50/fg_Hz)^2);

%% Vollbruecken-Kennlinie zeichnen
blau = [0 0.447 0.741];
rot = [0.85 0.10 0.10];
fig_vb_kalibrierung = figure('Name','Vollbruecke: warme Kalibrierung', ...
    'Color','w','Units','centimeters','Position',[3 3 17 11]);
plot(m_VB_g,Ua_VB_V,'o','Color',blau,'MarkerFaceColor',blau, ...
    'DisplayName','Messwerte, Temperatur unbekannt');
hold on
m_fit_g = linspace(min(m_VB_g),max(m_VB_g),100);
plot(m_fit_g,polyval(p_VB,m_fit_g),'-','Color',rot,'LineWidth',1.5, ...
    'DisplayName',sprintf('Fit: S = %.3f mV/g',S_VB_mV_g));
hold off
grid on
xlabel('Masse m [g]');
ylabel('Ausgangsspannung U_a [V]');
legend('Location','northwest');
set(gca,'FontName','Arial','FontSize',10);
xlim([380 920]); ylim([2.0 4.5]);

%% Export relativ zum Speicherort dieses Skripts
projekt_ordner = fileparts(fileparts(mfilename('fullpath')));
ausgabe_ordner = fullfile(projekt_ordner,'bilder','vollbruecke');
if ~exist(ausgabe_ordner,'dir'), mkdir(ausgabe_ordner); end
plot_name = fullfile(ausgabe_ordner,'kalibrierung_vollbruecke');
exportgraphics(fig_vb_kalibrierung,[plot_name '.png'],'Resolution',180);
exportgraphics(fig_vb_kalibrierung,[plot_name '.pdf'],'ContentType','vector');
savefig(fig_vb_kalibrierung,[plot_name '.fig']);
messwerte_VB = table(m_VB_g,Ua_VB_V,Ua_VB_Modell_V,residuen_VB_V);
writetable(messwerte_VB,fullfile(ausgabe_ordner,'kalibrierung_werte.csv'));

%% Ergebnisse im Command Window und im Workspace
disp(messwerte_VB)
fprintf('Vollbruecke: Ua[V] = %.9f*m[g] + %.9f; R^2 = %.9f\n', ...
    p_VB(1),p_VB(2),R2_VB);
fprintf('Sensitivitaeten VB/HB, gesamte Reihen: %.6f / %.6f mV/g\n', ...
    S_VB_mV_g,S_HB_mV_g);
fprintf('Verhaeltnis gesamte Reihen: %.6f\n',verhaeltnis_gesamte_reihen);
fprintf('Gemeinsamer Bereich500-900g: VB %.6f, HB %.6f mV/g; Faktor %.6f\n', ...
    1000*p_VB_gemeinsam(1),1000*p_HB_gemeinsam(1),verhaeltnis_gemeinsam);
fprintf('Filtermessung: R=%.0f Ohm, T=%.6f Grad C\n',R_PT1000_Ohm,T_Filter_C);
fprintf('RMS: %.3f mV -> %.3f mV; Faktor %.6f\n', ...
    1000*Un_ungefiltert_V,1000*Un_gefiltert_V,rauschfaktor);
fprintf('Reduktion %.6f%% bzw. %.6f dB; verbleibend %.6f%%\n', ...
    reduktion_prozent,reduktion_dB,verbleibend_prozent);
fprintf('RC-Idealmodell fuer verwendete Bauteile: fg=%.6f Hz, tau=%.6f s, Daempfung50Hz=%.6f dB\n', ...
    fg_Hz,tau_s,daempfung_50Hz_dB);
ergebnisse = struct('S_VB_mV_g',S_VB_mV_g,'b_VB_V',p_VB(2), ...
    'R2_VB',R2_VB,'S_HB_mV_g',S_HB_mV_g, ...
    'Verhaeltnis_gesamte_reihen',verhaeltnis_gesamte_reihen, ...
    'S_VB_gemeinsam_mV_g',1000*p_VB_gemeinsam(1), ...
    'S_HB_gemeinsam_mV_g',1000*p_HB_gemeinsam(1), ...
    'Verhaeltnis_gemeinsam',verhaeltnis_gemeinsam, ...
    'T_Filter_C',T_Filter_C,'Rauschfaktor',rauschfaktor, ...
    'Reduktion_prozent',reduktion_prozent,'Reduktion_dB',reduktion_dB, ...
    'fg_Hz',fg_Hz,'tau_s',tau_s,'Daempfung50Hz_dB',daempfung_50Hz_dB);
fid = fopen(fullfile(ausgabe_ordner,'auswertung.json'),'w');
if fid<0, error('Ergebnisdatei konnte nicht geoeffnet werden.'); end
fprintf(fid,'%s',jsonencode(ergebnisse,PrettyPrint=true));
fclose(fid);
