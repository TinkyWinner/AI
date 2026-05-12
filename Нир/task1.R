library("lmtest")
#Вариант 17
data <- swiss
#1 Education
print(mean(data$Education)) #Средний показатель Детская смертность 10.97872
print(var(data$Education)) #Дисперсия Детская смертность  92.45606
print(sd(data$Education))  #СКО Детская смертность  9.615407  Значительный разброс

#1 Infant.Mortality
print(mean(data$Infant.Mortality)) #Средний показатель Детская смертность 19.94255
print(var(data$Infant.Mortality)) #Дисперсия Детская смертность  8.483802
print(sd(data$Infant.Mortality))  #СКО Детская смертность  2.912697  Значительный разброс

#1 Catholic
print(mean(data$Catholic)) #Средний показатель Католик  41.14383
print(var(data$Catholic)) #Дисперсия Католик  1739.295
print(sd(data$Catholic))  #СКО Католик   41.70485  Высокий разброс


#2-Регрессор Infant.Mortality
x1 <-data$Infant.Mortality
y1 <- data$Education
plot(x1,y1,main= "График зависимости Education от Infant.Mortality")

#2-Регрессор Catholic
x <-data$Catholic
y <- data$Education
plot(x,y,main= "График зависимости Education от Catholic")

#3- Infant.Mortality
model1=lm(data$Education ~ data$Infant.Mortality,data = swiss)
summ_m1 <- summary(model1)
print(summ_m1)
#R^2~0.009865-значение мало=> Модель плоха, зависимости нет
#Education = 17.5175 -0.3279*Infant.Mortality. Взаимосвязь отрицательная


#3- Catholic
model2=lm(data$Education ~ data$Catholic,data = swiss)
summ_m2 <- summary(model2)
print(summ_m2)
#R^2~0.02367-значение мало=> Модель плоха, зависимости нет
#Education = 12.43824 -0.03547*Catholic. Взаимосвязь отрицательная

#4 - Infant.Mortality
#p~0.5>0.05,звёздочек нет => Взаимосвязи нет

#4-Catholic
#Звездочек нет, p~0.3>0.05 => Взаимосвязи нет

#В обоих случаях взаимосвязь отрицательная

