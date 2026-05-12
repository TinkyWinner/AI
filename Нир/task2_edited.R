library(lmtest)
library(car)
#Вариант 17
data <- swiss
#1) Проверка, что в наборе данных нет линейной зависимости
model_1 = lm(Catholic ~ Agriculture, data)
summary(model_1)
#R^2: 0.1609 => можно оставить оба регрессора
model_2 = lm(Catholic ~ Infant.Mortality, data)
summary(model_2)
#R^2: 0.0308 => можно оставить оба регрессора
model_3 = lm(Agriculture ~ Infant.Mortality, data)
summary(model_3)
#R^2: 0.003704 => можно оставить оба регрессора

#2) Построим и оценим нашу модель от трех переменных
model = lm(Education~Catholic+Agriculture+Infant.Mortality, data)
summary(model)
#R^2=41% модель относительно хороша
#p-значениям каждого коэффициента: 
#Из трёх независимых переменных только Agriculture(9.02e-07) имеет значимое влияние на Education.
#Catholic(0.204) и Infant.Mortality(0.147) в этой модели статистически не значимы (p > 0.05).

#3) Построим модель используя логарифмы и экспоненту. Сравним модели и выберем наилучшую.
model_catholic_ln = lm(Catholic ~ log(Catholic), data)
summary(model_catholic_ln)
#R^2:89% => зависимость есть

model_catholic_e = lm(Catholic ~ exp(Catholic), data)
summary(model_catholic_e)
#R^2:35% => зависимость есть

model_agriculture_ln = lm(Agriculture ~ log(Agriculture), data)
summary(model_agriculture_ln)
#R^2:77% => зависимость есть

model_agriculture_e = lm(Agriculture ~ exp(Agriculture), data)
summary(model_agriculture_e)
#R^2: 7% => зависимости нет можно добавить в модель

model_infant.mortality_ln = lm(Infant.Mortality ~ log(Infant.Mortality), data)
summary(model_infant.mortality_ln)
#R^2:98% => зависимость есть

model_infant.mortality_e = lm(Infant.Mortality ~ exp(Infant.Mortality), data)
summary(model_infant.mortality_e)
#R^2: 22% => зависимости нет можно добавить в модель

#Построим модель с логарифмами и экспонентами
model_ln_exp1 = lm(Education~I(log(Catholic))+I(log(Agriculture))+I(log(Infant.Mortality))+I(exp(Agriculture))+I(exp(Infant.Mortality)), data)
summary(model_ln_exp1)
vif(model_ln_exp1)
#Зависимости между регрессорами не появилось. R^2 = 55% => ниже чем у исходной модели

#4)Введем в модель всевозможные пары регрессоров, в том числе квадраты регрессоров
model_full1 <- lm(Education ~ Catholic + Agriculture + Infant.Mortality + I(Catholic^2) + I(Agriculture^2) + I(Infant.Mortality^2) 
                 + I(Catholic*Agriculture) + I(Catholic*Infant.Mortality) + I(Agriculture*Infant.Mortality), data)
summary(model_full1)
vif(model_full1)#Убираем Catholic

model_full2 <- lm(Education ~  Agriculture + Infant.Mortality + I(Catholic^2) + I(Agriculture^2) + I(Infant.Mortality^2) 
                 + I(Catholic*Agriculture) + I(Catholic*Infant.Mortality) + I(Agriculture*Infant.Mortality), data)
summary(model_full2)
vif(model_full2)#убираем I(Infant.Mortality^2)

model_full3 <- lm(Education ~  Agriculture + Infant.Mortality + I(Catholic^2) + I(Agriculture^2) 
                  + I(Catholic*Agriculture) + I(Catholic*Infant.Mortality) + I(Agriculture*Infant.Mortality), data)
summary(model_full3)
vif(model_full3)#убираем Agriculture

model_full4 <- lm(Education ~ Infant.Mortality + I(Catholic^2) + I(Agriculture^2) 
                  + I(Catholic*Agriculture) + I(Catholic*Infant.Mortality) + I(Agriculture*Infant.Mortality), data)
summary(model_full4)
vif(model_full4)#убираем I(Catholic^2)

model_full5 <- lm(Education ~ Infant.Mortality + I(Agriculture^2) 
                  + I(Catholic*Agriculture) + I(Catholic*Infant.Mortality) + I(Agriculture*Infant.Mortality), data)
summary(model_full5)
vif(model_full5)#убираем I(Agriculture^2)

model_full6 <- lm(Education ~ Infant.Mortality
                  + I(Catholic*Agriculture) + I(Catholic*Infant.Mortality) + I(Agriculture*Infant.Mortality), data)
summary(model_full6)
vif(model_full6)#убираем I(Catholic * Agriculture)

model_full7 <- lm(Education ~ Infant.Mortality
                  + I(Catholic*Infant.Mortality) + I(Agriculture*Infant.Mortality), data)
summary(model_full7)
vif(model_full7)#оставляем
#R^2: 38%

#5) Выберем лучшую модель
model_ln_exp1 = lm(Education~I(log(Catholic))+I(log(Agriculture))+I(log(Infant.Mortality))+I(exp(Agriculture))+I(exp(Infant.Mortality)), data)
summary(model_ln_exp1)
#исключим незначимые параметры

model_final <- lm(Education~log(Agriculture), data)
summary(model_final)
#R^2 ~ 55%, модель относительно хороша
#p-value = 8.664e-10 взаимосвязь хорошая и отрицательная: y= 46.461 -9.472*log(Agriculture) 

model_thebest1 = lm(Education~I(log(Catholic))+I(log(Agriculture))+I(log(Infant.Mortality))+I(exp(Agriculture))+I(exp(Infant.Mortality)), data)

model_tb_reg1 = lm(Education~log(Catholic),data)
summary(model_tb_reg1)
#R^2 ~ -2%, модель плохая
#p-value = 0.8766 взаимосвязь плохая положительная: y= 10.517 +0.158*log(Agriculture) 

model_tb_reg2 = lm(Education~I(log(Agriculture)),data)
summary(model_tb_reg2)
#R^2 ~ -2%, модель плохая
#p-value = 0.8766 взаимосвязь плохая положительная: y= 10.517 +0.158*log(Agriculture) 

model_tb_reg3 = lm(Education~I(log(Infant.Mortality)),data)
summary(model_tb_reg3)
#R^2 ~ 55%, модель относительно хороша
#p-value = 8.664e-10 взаимосвязь хорошая и отрицательная: y= 46.461 -9.472*log(Agriculture) 

model_tb_reg4 = lm(Education~I(exp(Agriculture)),data)
summary(model_tb_reg4)
#R^2 ~ -0.1%, модель плохая
#p-value = 0.3351 взаимосвязь плохая и отрицательная: y= 1.119e+01 -1.049e-38*log(Agriculture) 

model_tb_reg5 = lm(Education~I(exp(Infant.Mortality)),data)
summary(model_tb_reg5)
#R^2 ~ -0.2%, модель плохая
#p-value = 0.6147 взаимосвязь плохая и отрицательная: y= 1.115e+01 -1.371e-11*log(Agriculture) 

#Задание 2.2
#итоговая модель 
model_thebest = lm(Education~I(log(Catholic))+I(log(Agriculture))+I(log(Infant.Mortality))+I(exp(Agriculture))+I(exp(Infant.Mortality)), data)
summary(model_thebest)
nrow(data)#47-6 = 41 степеней свободы
#Вычислим доверительный интервал для коэффициента log(Catholic)
se1 = 7.155e-01
#критерий Стьюдента: 95%
t_critical = qt(0.975, df = 41)
9.800e-01 - t_critical * se1
9.800e-01 + t_critical * se1
#получили доверительный интервал [-0.4649816 ; 2.424982] => нельзя отвергнуть теорию что В = 0

#Вычислим доверительный интервал для коэффициента log(Agriculture)
se2 = 1.265e+00
#критерий Стьюдента: 95%
t_critical = qt(0.975, df = 41)
-9.496e+00 - t_critical * se2
-9.496e+00 + t_critical * se2
#получили доверительный интервал [-12.05072 ;-6.941281]  => можем отвергнуть теорию что В = 0

#Вычислим доверительный интервал для коэффициента log(Infant.Mortality)
se3 = 6.773e+00
#критерий Стьюдента: 95%
t_critical = qt(0.975, df = 41)
-3.446e+00 - t_critical * se3
-3.446e+00 + t_critical * se3
#получили доверительный интервал [-17.12435 ;10.23235]  => можем отвергнуть теорию что В = 0

#Вычислим доверительный интервал для коэффициента exp(Agriculture)
se4 = 7.496e-39
#критерий Стьюдента: 95%
t_critical = qt(0.975, df = 41)
-4.642e-39 - t_critical * se4
-4.642e-39 + t_critical * se4
#получили доверительный интервал [-1.978048e-38 ; 1.049648e-38] => нельзя отвергнуть теорию что В = 0

#Вычислим доверительный интервал для коэффициента exp(Infant.Mortality)
se5 = 2.000e-11
#критерий Стьюдента: 95%
t_critical = qt(0.975, df = 41)
-1.642e-11 - t_critical * se5
-1.642e-11 + t_critical * se5
#получили доверительный интервал [-5.681082e-11 ; 2.397082e-11] => нельзя отвергнуть теорию что В = 0

# Найдем доверительный интервал для одного прогноза
new.data = data.frame(Agriculture = 10, Catholic = 15, Infant.Mortality = 20)
predict(model_thebest, new.data, interval = "confidence")
# Получили прогноз = 24.71857 и интервал [20.53754 ; 28.89961]

# Построим парные зависимости между Education и Agriculture/Catholic/Infant.Mortality
model_trust1 = lm(Education ~ Agriculture, data = swiss)
summary(model_trust1)
se6 = 0.05
#критерий Стьюдента: 95%, 47 - 2 = 45 степеней свободы
-0.27-t_critical * se6
-0.27+t_critical * se6
#получили доверительный интервал [-0.370977 ; -0.169023] => связь отрицательна

model_trust2 = lm(Education ~ Catholic, data = swiss)
summary(model_trust2)
se7 = 0.03
#критерий Стьюдента: 95%, 47 - 2 = 45 степеней свободы
-0.04-t_critical * se7
-0.04+t_critical * se7
#получили доверительный интервал [-0.1005862 ; 0.02058623] => связь незначима

model_trust3 = lm(Education ~ Infant.Mortality, data = swiss)
summary(model_trust3)
se8 = 0.49
#критерий Стьюдента: 95%, 47 - 2 = 45 степеней свободы
-0.33-t_critical * se8
-0.33+t_critical * se8
#получили доверительный интервал [-1.319575 ; 0.6595751] => связь незначима

