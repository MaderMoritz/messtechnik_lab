%% Einheitliche Farben fuer die bereits gespeicherten DC- und Gewichtsgrafiken
% DC: dokumentierte Werte aus dc_bridge.m, dessen FIG einen anderen Stand hatte.
% Gewicht: FIG als Daten laden. Urspruengliche Lernskripte werden nicht
% ausgefuehrt. Blaue Daten/Kurven, rote Regressionsgeraden; Markerformen bleiben.
% Die bisherigen FIG-Dateien werden vor dem ersten Ueberschreiben gesichert.
projekt_ordner = fileparts(fileparts(mfilename('fullpath')));
backup_ordner = fullfile(projekt_ordner,'build','farben-vorher');
if ~exist(backup_ordner,'dir'), mkdir(backup_ordner); end
blau = [0 0.447 0.741];
rot = [0.85 0.10 0.10];
fig_dateien = {fullfile(projekt_ordner,'bilder','dc_bridge_variable_us.fig'), ...
    fullfile(projekt_ordner,'daten','regression_gewichtsmessung.fig')};
ausgaben = {fullfile(projekt_ordner,'bilder','dc_bridge_variable_us'), ...
    fullfile(projekt_ordner,'bilder','gewichtsmessung','regression_gewichtsmessung')};
for k = 1:numel(fig_dateien)
    [~,basis] = fileparts(fig_dateien{k});
    sicherung = fullfile(backup_ordner,[basis '.fig']);
    if ~isfile(sicherung), copyfile(fig_dateien{k},sicherung); end
    if k==1
        % Entspricht der bisher im Bericht eingebundenen DC-Simulationskurve.
        % Der vorhandene FIG-Altstand ist NICHT die Quelle dieser Werte.
        Us_V = [5 10 15 20 25 30];
        Ud_V = [0.01061 0.0212 0.0329 0.0424 0.0529 0.0639]*1e-3;
        fig = figure('Visible','off','Color','w','Units','centimeters', ...
            'Position',[2 2 24 14]);
        plot(Us_V,Ud_V,'-o','Color',blau);
        xlabel('Input Voltage U_s in V');
        ylabel('Output Voltage U_d in V');
        grid on
        xlim([5 30]); ylim([1e-5 7e-5]);
    else
        fig = openfig(fig_dateien{k},'invisible');
    end
    linien = findall(fig,'Type','line');
    vorher = cell(numel(linien),2);
    for j = 1:numel(linien)
        vorher(j,:) = {linien(j).XData,linien(j).YData};
        % Im Gewichtsplot sind Linien ohne Marker die zwei Regressionen.
        ist_regression = k==2 && strcmp(linien(j).Marker,'none');
        if ist_regression
            linien(j).Color = rot;
        else
            linien(j).Color = blau;
            if ~strcmp(linien(j).Marker,'none')
                linien(j).MarkerEdgeColor = blau;
                if isnumeric(linien(j).MarkerFaceColor)
                    linien(j).MarkerFaceColor = blau;
                end
            end
        end
    end
    if k==2
        % Gespeicherte Figur muss die zuletzt dokumentierten Daten enthalten.
        hat_referenzen = false; hat_dms = false; hat_vergleich = false;
        for j=1:numel(linien)
            x=linien(j).XData; y=linien(j).YData;
            if numel(x)==6
                hat_referenzen = hat_referenzen || ...
                    (isequal(x(:),[0;500;600;700;800;900]) && ...
                     max(abs(y(:)-[.610;1.92;2.13;2.29;2.46;2.64]))<1e-10);
            end
            if numel(x)==1
                hat_dms = hat_dms || (abs(x-197.0439798125)<1e-5 && abs(y-1.13)<1e-10);
                hat_vergleich = hat_vergleich || (abs(x-206.1)<1e-10 && abs(y-1.13)<1e-10);
            end
        end
        assert(hat_referenzen && hat_dms && hat_vergleich, ...
            'FIG passt nicht zum aktuellen Gewichtsplot; kein Export.');
    end
    for j=1:numel(linien)
        assert(isequal(linien(j).XData,vorher{j,1}) && ...
            isequal(linien(j).YData,vorher{j,2}),'Plotdaten veraendert.');
    end
    exportgraphics(fig,[ausgaben{k} '.png'],'Resolution',180);
    exportgraphics(fig,[ausgaben{k} '.pdf'],'ContentType','vector');
    savefig(fig,[ausgaben{k} '.fig']);
    if k==2, savefig(fig,fig_dateien{k}); end
    close(fig);
end
fprintf('DC aus dokumentierten Simulationswerten; Gewichtsplot farblich geaendert, Daten unveraendert.\n');
