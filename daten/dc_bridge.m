
u = symunit;

x = [5*u.V, 10*u.V, 15*u.V, 20*u.V, 25*u.V, 30*u.V];
y = [0.01061, 0.0212, 0.0329, 0.0424, 0.0529, 0.0639] * u.mV;

y_in_volt = unitConvert(y, u.V);

x_plot = double(separateUnits(x));
y_plot = double(separateUnits(y_in_volt));

figure
plot(x_plot, y_plot, '-o', 'Color', [0 0.447 0.741]);
xlabel('Input Voltage U_s in V');
ylabel('Output Voltage U_d in V');
grid on;
