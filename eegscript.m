%% SCRIPT PARA EL ANALISIS DE VOLTAJES CEREBRALES
%%
%% Apertura de Archivo CSV y Ajuste de Dimensiones
% Apertura de archivo y asignacion de la variable _*"eeg"*_. 

[Num,eeg] = uigetfile('*.csv','Selecciona los voltajes'); tic;
eeg = [eeg Num];
eeg = csvread(eeg);

%%
% Generacion de variable _*"alfa"*_ de 8 celdas, cada una con los 15,000
% voltajes del primer minuto de cada canal.

alfa = cell(1,8);
for ii = 1:8
    alfa{ii} = eeg(1:15000, ii);
end
clear ii

%%
% Ajuste de dimensiones de la variable _*"eeg"*_ para contener los 500
% segundos que dura el experimento, es decir, 125,000 voltajes de un
% registro realizado a 250 Hz.

eeg = eeg((end-124999:end),:);

%%
% Ajuste de canales en una variable _*"v"*_ de 8 celdas, una celda por
% cada canal. A su vez en cada canal se distribuiran los voltajes en 10
% celdas, cada una con 12,500 voltajes, o 50 segundos a 250 Hz.

b = 12500;
for ii = 1:8
    for jj = 1:10
        if jj == 1
            bb = 1;
        else
            bb = (b*jj)-b;
        end
    v{ii}{jj} = eeg(bb:((bb+b)-1),ii);
    end
end
clear ('b','bb','eeg','ii','jj');

fprintf('Importacion de archivo %s y ajuste de dimensiones realizada correctamente.\n', Num);
clear Num;

%% Determinacion de Medidas de Dispersion
%%
% Determinacion de la media aritmetica, asignandola a la variable _*"mv"*_. 
% 8 canales con 10 bloques, cada cual conteniendo la media aritmetica
% de los 12,500 voltajes de su bloque.

for ii = 1:8
    for jj = 1:10
        mv{ii}{jj} = mean(v{ii}{jj});
    end
end
clear('ii','jj');

%%
% Determinacion varianza, asignandola a la variable _*"vv"*_. 
% 8 canales con 10 bloques, cada cual conteniendo la varianza
% de los 12,500 voltajes de su bloque.

for ii = 1:8
    for jj = 1:10
        vv{ii}{jj} = var(v{ii}{jj});
    end
end
clear('ii','jj');

%%
% Determinacion de la desviacion estandar, asignadola a la variable _*"sv"*_. 
% 8 canales con 10 bloques, cada cual conteniendo la desviacion estandar
% de los 12,500 voltajes de su bloque.

for ii = 1:8
    for jj = 1:10
        sv{ii}{jj} = std(v{ii}{jj});
    end
end
clear('ii','jj');

fprintf('Medidas de dispersion (media, varianza y desviacion estandar) calculadas correctamente.\n');

%% Determinacion de Variables Cartesianas
%%
% Calculo de diferencias de numeros contiguos, asignandolos a la variable
% _*"dv"*_, en el formato _x{y}{z}_, en donde _"x"_ es la variable; _"y"_ 
% el canal del 1 al 8, y _"z"_ el bloque del 1 al 10 cada cual con 12,500 digitos. 

for ii = 1:8
    for jj = 1:10
        dv{ii}{jj} = diff(v{ii}{jj});
    end
end
clear('ii','jj')

for ii = 1:8
    for jj = 1:10
        dv{ii}{jj}(12500) = (v{ii}{jj}(12500)) - (v{ii}{jj}(12499));
    end
end
clear('ii','jj')

%%
% Determinacion de la desviacion estandar de las diferencias de voltaje,
% asignandolas a la variable _*"sdv"*_ en el formato general _x{y}{z}_.

for ii = 1:8
    for jj = 1:10
        sdv{ii}{jj} = std(dv{ii}{jj});
    end
end
clear('ii','jj');

%%
% Determinacion del espacio en el que transcurren las diferencias de
% voltaje, de ±3 desviaciones estandares de la diferencia de sus
% voltajes, asignandolos a la variable _*"fsdv"*_ en el formato general.

for ii = 1:8
    for jj = 1:10
        fsdv{ii}{jj} = (6).*(sdv{ii}{jj});
    end
end
clear('ii','jj');

%%
% Determinacion de la potencia angular, partiendo de la distribucion de ±90
% grados de ±3 desviaciones estandares de las diferencias de voltaje,
% considerando ese rango como el hemicirculo propio de la distribucion
% anterograda del voltaje a travez del vector del tiempo. La varable
% _*"ang"*_ contendra en el formato general, la potencia angular calculada
% como ±90 grados entre 6 desviaciones estandares de la diferencia
% voltaica.

for ii = 1:8
    for jj = 1:10
        ang{ii}{jj} = (fsdv{ii}{jj}) / 90;
    end
end
clear('ii','jj');

%%
% Determinacion del vector resultante de la multiplicacion de la diferencia
% de voltajes y la potencia angular, asignandoles la variable _*"vdv"*_ en
% el formato general.

vdv = cell(1,8);
for ii = 1:8
    vdv{ii} = cell(1,10);
end
clear('ii','jj');

for ii = 1:8
    for jj = 1:10
        for kk = 1:12500
            vdv{ii}{jj}(kk) = dv{ii}{jj}(kk) .* (ang{ii}{jj});
        end
    end
end
clear('ii','jj');

fprintf('Variables cartesianas determinadas correctamente.\n')

%% Determinacion del Poder Espectral
%%
% Determinacion de valores contiguos superiores a 0, asignandolos a la
% variable _*"loa"*_ en el formato general.

for ii = 1:8
    for jj = 1:10
        ploa{ii}{jj} = vdv{ii}{jj} > 0;
        ploa{ii}{jj}(1) = 0; 
    end
end
clear('ii','jj')

loa = cell(1,8);
for ii = 1:8
    loa{ii} = cell(1,10);
end
clear('ii','jj');

for ii = 1:8
    for jj = 1:10
        for kk = 1:12500
            if ploa{ii}{jj}(kk) == 1
               loa{ii}{jj}(kk) = ploa{ii}{jj}(kk) + loa{ii}{jj}(kk-1);
            else 
                loa{ii}{jj}(kk) = 0;
            end
        end
    end
end
clear('ii','jj','kk')

%%
%%
% Determinacion de valores contiguos inferiores a 0, asignandolos a la
% variable _*"lod"*_ en el formato general.

for ii = 1:8
    for jj = 1:10
        plod{ii}{jj} = vdv{ii}{jj} < 0;
        plod{ii}{jj}(1) = 0; 
    end
end
clear('ii','jj')

lod = cell(1,8);
for ii = 1:8
    lod{ii} = cell(1,10);
end
clear('ii','jj');

for ii = 1:8
    for jj = 1:10
        for kk = 1:12500
            if plod{ii}{jj}(kk) == 1
               lod{ii}{jj}(kk) = plod{ii}{jj}(kk) + lod{ii}{jj}(kk-1);
            else 
                lod{ii}{jj}(kk) = 0;
            end
        end
    end
end
clear('ii','jj','kk')








%%
% Codigo creado por *Miguel Angel Santos Saldivar* en Julio 2017
