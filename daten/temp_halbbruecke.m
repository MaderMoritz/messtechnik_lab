%% Konstanten und Raumtemperaturwerte
R0_Ohm = 1000;                % PT1000 bei0 Grad C
alpha_pro_K = 0.003910;       % Laborskript, Gleichung(3.2)
R_raum_Ohm = 1106;            % Nutzerangabe bei Raumtemperatur
Un_raum_mV = 2.35;            % Nutzerangabe zur RMS-Rauschspannung
T_raum_C = (R_raum_Ohm/R0_Ohm - 1)/alpha_pro_K;
R_60C_Ohm = R0_Ohm*(1 + alpha_pro_K*60);



%% Messwerte: Halbbruecke bei eingeschalteter Heizung
% Spalten: R/Ohm, Mittelwert/mV, AC-RMS/mV.
% Widerstand: Multimeter; Ausgangsmittelwert und AC-RMS: Oszilloskop.
HB_ein = [
    1118 627.1 3.8
    1130 666.8 3.3
    1140 623.6 3.4
    1150 626.3 3.5
    1160 616.9 3.6
    1170 578.3 3.9
    1180 512.4 3.8
    1190 473.2 3.8
    1200 446.9 3.7
    1210 422.4 3.7
    1220 405.1 3.8
    1229 388.2 3.7
    ];

% Separater Betriebszustand: Halbbruecke, Heizung abgeschaltet.
HB_aus = [24 1234 273.2 1.6];

%% Messwerte: Vollbruecke beim Abkuehlen, Heizung aus
VB = [
    1220 280.8 1.7
    1207 296.6 1.7
    1200 307.0 2.1
    1190 308.5 2.3
    1180 321.4 2.3
    1170 321.9 2.0
    1151 304.0 3.6
    ];

%% Widerstand in Temperatur umrechnen
T_HB_C = (HB_ein(:,1)/R0_Ohm - 1)/alpha_pro_K;
T_aus_C = (HB_aus(:,1)/R0_Ohm - 1)/alpha_pro_K;
T_VB_C = (VB(:,1)/R0_Ohm - 1)/alpha_pro_K;