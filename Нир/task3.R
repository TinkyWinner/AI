library("lmtest")
library("rlms")
library("dplyr")
library("GGally")
library("car")
library("sandwich")
library("haven")

#Подготвим данные
data <- read_sav("/workspaces/AI/Нир/r13i_os26b.sav")
glimpse(data)
data2 =  select(data, ij13.2, i_age, ih5, i_educ, status, ij6.2, i_marst)#отбираем нужные столбцы

#Исключаем строки с отсутсвующим значением NA
data2 = na.omit(data2)

#зарплата c элементами нормализации
data2$ij13.2
sal = as.numeric(data2$ij13.2)
sal1 = as.character(data2$ij13.2)
sal2 = lapply(sal1, as.integer)
sal = as.numeric(unlist(sal2))
mean(sal)
data2["salary"] = (sal - mean(sal)) / sqrt(var(sal))
data2["salary"]

#возраст c элементами нормализации
age1 = as.character(data2$i_age)
age2 = lapply(age1, as.integer)
age3 = as.numeric(unlist(age2))
data2["age"]= (age3 - mean(age3)) / sqrt(var(age3))
data2["age"]

#пол
data2["sex"]=as.character(data2$ih5)
data2$sex[which(data2$sex!='1')] <- 0
data2$sex[which(data2$sex=='1')] <- 1
data2$sex = as.numeric(data2$sex)

#образование
data2["h_educ"] = as.character(data2$i_educ)
data2["higher_educ"] = data2$i_educ
data2["higher_educ"] = 0
data2$higher_educ[which(data2$h_educ=='21')] <- 1
data2$higher_educ[which(data2$h_educ=='22')] <- 1
data2$higher_educ[which(data2$h_educ=='23')] <- 1

#населенный пункт
data2["status1"]=as.character(data2$status)
data2["status2"] = 0
data2$status2[which(data2$status1=='1')] <- 1
data2$status2[which(data2$status1=='2')] <- 1
data2$status2 = as.numeric(data2$status2)

#продолжительность рабочей недели
dur1 = as.character(data2$ij6.2)
dur2 = lapply(dur1, as.integer)
dur3 = as.numeric(unlist(dur2))
data2["dur"] = (dur3 - mean(dur3)) / sqrt(var(dur3))

#семейное положение
data2["wed"]= data2$i_marst
data2["wed"] = unlist(lapply(data2$i_marst, as.character))
data2$wed1 = 0
data2$wed1[which(data2$wed=='1')] <- 1
data2$wed1[which(data2$wed=='3')] <- 1
data2$wed1 = as.numeric(data2$wed1)

data2["wed2"] = lapply(data2["wed"], as.character)
data2$wed2 = 0
data2$wed2[which(data2$wed=='2')] <- 1
data2$wed2 = as.numeric(data2$wed2)

data2["wed3"]=data2$i_marst
data2$wed3 = 0
data2$wed3[which(data2$wed=='4')] <- 1
data2$wed3 = as.numeric(data2$wed3)

data2["wed4"]=data2$i_marst
data2$wed4 = 0
data2$wed4[which(data2$wed=='5')] <- 1
data2$wed4 = as.numeric(data2$wed4)

data2 = na.omit(data2)

data3 = select(data2, salary, age, sex, higher_educ, status2, dur, wed1,wed2,wed3,wed4)

uniqv <- unique(data2$salary)
u1 = uniqv[which.max(tabulate(match(data2$salary, uniqv)))]
table_salary = data.frame(Value = "salary", Mean = mean(data2$salary,na.rm = TRUE), Median = median(data2$salary,na.rm = TRUE), Mode = u1)
table_salary

uniqv <- unique(data2$age)
u1 = uniqv[which.max(tabulate(match(data2$age, uniqv)))]
table_age = data.frame(Value = "age", Mean = mean(data2$age,na.rm = TRUE), Median = median(data2$age,na.rm = TRUE), Mode = u1)
table_age

mean(data2$sex)

mean(data2$status2)

uniqv <- unique(data2$dur)
u1 = uniqv[which.max(tabulate(match(data2$dur, uniqv)))]
table_dur = data.frame(Value = "dur", Mean = mean(data2$dur,na.rm = TRUE), Median = median(data2$dur,na.rm = TRUE), Mode = u1)
table_dur

mean(data3$wed1)
mean(data3$wed2)
mean(data3$wed3)
mean(data3$wed4)
mean(data3$higher_educ)



#№1 Построим зависимость зарплаты от всех переменных

model1 = lm(data=data3, salary~age + sex + higher_educ + status2 + dur + wed1 + wed2 + wed3 + wed4)
summary(model1)
vif(model1)
#Уберём wed2

model2 = lm(data=data3, salary~age + sex + higher_educ + status2 + dur + wed1 + wed3 + wed4)
summary(model2)
vif(model2)
#Vif приемлемый. Оставим эту модель. R^2 = 0.01807

#№2 добавим функции регрессоров
data3$log_age <- log(data3$age - min(data3$age) + 1)  # избегаем log(0) или log(отрицат.)
data3$log_dur <- log(data3$dur - min(data3$dur) + 1)

data3$age_sq <- data3$age^2
data3$dur_sq <- data3$dur^2

data3$age_dur <- data3$age * data3$dur
data3$age_educ <- data3$age * data3$higher_educ
data3$dur_educ <- data3$dur * data3$higher_educ

model3 <- lm(salary ~ log_age + log_dur + age_sq + dur_sq + 
               age_dur + age_educ + dur_educ + 
               sex + higher_educ + status2 + wed1 + wed3 + wed4, data = data3)

summary(model3)
vif(model3)
#Уберём log_dur 

model4 <- lm(salary ~ log_age + age_sq + dur_sq + 
               age_dur + age_educ + dur_educ + 
               sex + higher_educ + status2 + wed1 + wed3 + wed4, data = data3)

summary(model4)
vif(model4)
#Vif приемлемый. Оставим эту модель. R^2 = 0.0254

# Перебор степеней для переменных age и dur
opt_model <- model4
best_degrees <- c(0, 0)

for (deg_age in seq(0.1, 2, by = 0.1)) {
  for (deg_dur in seq(0.1, 2, by = 0.1)) {
    temp_model <- lm(salary ~ log_age + age_sq + dur_sq + 
                       age_dur + age_educ + dur_educ + 
                       sex + higher_educ + status2 + wed1 + wed3 + wed4 + I(dur^deg_dur) + I(age^deg_age), data = data3)
    if (summary(temp_model)$adj.r.squared > summary(opt_model)$adj.r.squared) {
      opt_model <- temp_model
      best_degrees <- c(deg_age, deg_dur)
    }
  }
}

# Вывод лучших степеней и итоговой модели
best_degrees # age^1 dur^0.1
summary(opt_model) #Adjusted R-squared:  0.1037  
vif(opt_model, type = "predict")


#№3 Оптимизируем модель используя vif 

opt_model1 <- lm(salary ~ log_age + age_sq + dur_sq + 
               age_dur + age_educ + dur_educ + 
               sex + higher_educ + status2 + wed1 + wed3 + wed4 + I(age^(1.0)) + I(dur^(0.1)), data = data3)
summary(opt_model1)
vif(opt_model1, type = "predictor")
#уберём age_dur

opt_model2 <- lm(salary ~ log_age + age_sq + dur_sq + 
                    + age_educ + dur_educ + 
                   sex + higher_educ + status2 + wed1 + wed3 + wed4 + I(age^(1.0)) + I(dur^(0.1)), data = data3)
summary(opt_model2)
vif(opt_model2, type = "predictor")
#уберём higher_educ

opt_model3 <- lm(salary ~ log_age + age_sq + dur_sq + 
                   + age_educ + dur_educ + 
                   sex + status2 + wed1 + wed3 + wed4 + I(age^(1.0)) + I(dur^(0.1)), data = data3)
summary(opt_model3)
vif(opt_model3, type = "predictor")
#уберём  dur_sq

opt_model4 <- lm(salary ~ log_age + age_sq + 
                   + age_educ + dur_educ + 
                   sex + status2 + wed1 + wed3 + wed4 + I(age^(1.0)) + I(dur^(0.1)), data = data3)
summary(opt_model4)
vif(opt_model4, type = "predictor")
#уберём  log_age

opt_model5 <- lm(salary ~age_sq + 
                   + age_educ + dur_educ + 
                   sex + status2 + wed1 + wed3 + wed4 + I(age^(1.0)) + I(dur^(0.1)), data = data3)
summary(opt_model5)
vif(opt_model5, type = "predictor")
#Vif приемлемый. Оставляем модель

#Проверяем связь opt_model5 с регрессорами
#4
#критерий Стьюдента
qt(0.975,df= 125-10)
#t = 1.98

model = lm(salary ~ sex, data3) 
summary(model)
#b = 0.018757, σ = 0.034372
#t = qt(0.975, df = 115) = 1.980
#доверительный интервал = [0.018757 - 1.980×0.034372, 0.018757 + 1.980×0.034372] = [-0.0493, 0.0868]
#0 внутри диапазона, связь отсутствует

model = lm(salary ~ status2, data3) 
summary(model)
#b = -0.000147, σ = 0.038761
#t = qt(0.975, df = 115) = 1.980
#доверительный интервал = [-0.000147 - 1.980×0.038761, -0.000147 + 1.980×0.038761] = [-0.0768, 0.0765]
#0 внутри диапазона, связь отсутствует

model = lm(salary ~ wed1, data3) 
summary(model)
#b = 0.12744, σ = 0.03933
#t = qt(0.975, df = 115) = 1.980
#доверительный интервал = [0.12744 - 1.980×0.03933, 0.12744 + 1.980×0.03933] = [0.0496, 0.2053]
#0 вне диапазона, связь положительная

model = lm(salary ~ wed2, data3) 
summary(model)
#b = -0.06760, σ = 0.03487
#t = qt(0.975, df = 115) = 1.980
#доверительный интервал = [-0.06760 - 1.980×0.03487, -0.06760 + 1.980×0.03487] = [-0.1366, 0.0014]
#0 внутри диапазона, связь отсутствует (p = 0.0526 > 0.05, на границе)

model = lm(salary ~ wed3, data3) 
summary(model)
#b = -0.051568, σ = 0.057530
#t = qt(0.975, df = 115) = 1.980
#доверительный интервал = [-0.051568 - 1.980×0.057530, -0.051568 + 1.980×0.057530] = [-0.1655, 0.0624]
#0 внутри диапазона, связь отсутствует

model = lm(salary ~ wed4, data3) 
summary(model)
#b = -0.081647, σ = 0.077816
#t = qt(0.975, df = 115) = 1.980
#доверительный интервал = [-0.081647 - 1.980×0.077816, -0.081647 + 1.980×0.077816] = [-0.2357, 0.0724]
#0 внутри диапазона, связь отсутствует

model = lm(salary ~ age, data3) 
summary(model)
#b = -0.1001, σ = 0.01703
#t = qt(0.975, df = 115) = 1.980
#доверительный интервал = [-0.1001 - 1.980×0.01703, -0.1001 + 1.980×0.01703] = [-0.1338, -0.0664]
#0 вне диапазона, связь отрицательная

model = lm(salary ~ dur, data3) 
summary(model)
#b = 0.09692, σ = 0.01703
#t = qt(0.975, df = 115) = 1.980
#доверительный интервал = [0.09692 - 1.980×0.01703, 0.09692 + 1.980×0.01703] = [0.0632, 0.1306]
#0 вне диапазона, связь положительная

#5
#подмножества:
#1. Городские жители, состоящие в браке
#2. Разведённые, без высшего образования

data5_1 = subset(data3, status2 == 1 & wed1 == 1)
sub_model_1 = lm(salary~
                   age_sq
                 + age_educ
                 + dur_educ
                 + sex
                 # + status2 (константа)
                 # + wed1 (константа)
                 + I(age^1)
                 , data5_1)
summary(sub_model_1)  # R^2adj = 4.62%

# посмотрим доверительные интервалы
qt(0.975, 652-7)
# t = 1.96

# age_sq
# b = 0.100570, σ = 0.047990
# доверительный интервал = [0.006346, 0.194801]
# 0 вне диапазона, связь положительная

# age_educ
# b = -0.322610, σ = 0.094770
# доверительный интервал = [-0.508704, -0.136517]
# 0 вне диапазона, связь отрицательная

# dur_educ
# b = 0.364770, σ = 0.094910
# доверительный интервал = [0.178408, 0.551131]
# 0 вне диапазона, связь положительная

# sex
# b = 0.056950, σ = 0.087360
# доверительный интервал = [-0.114597, 0.228490]
# 0 в диапазоне, связь отсутствует

# I(age^1)
# b = -0.015950, σ = 0.062990
# доверительный интервал = [-0.139646, 0.107738]
# 0 в диапазоне, связь отсутствует

# качество модели на подмножестве низкое (R^2adj = 4.62%),
# значимое влияние имеют age_sq, age_educ, dur_educ

data5_2 = subset(data3, wed2 == 1 & higher_educ == 0)
sub_model_2 = lm(salary~
                   age_sq
                 + sex
                 + status2
                 # + wed2 (константа)
                 # + higher_educ (константа)
                 + I(age^1)
                 , data5_2)
summary(sub_model_2)  # R^2adj = 0.15%

# посмотрим доверительные интервалы
qt(0.975, 1499-6)
# t = 1.96

# age_sq
# b = 0.016590, σ = 0.025730
# доверительный интервал = [-0.033882, 0.067062]
# 0 в диапазоне, связь отсутствует

# sex
# b = 0.021320, σ = 0.048190
# доверительный интервал = [-0.073209, 0.115845]
# 0 в диапазоне, связь отсутствует

# status2
# b = 0.055320, σ = 0.051410
# доверительный интервал = [-0.045523, 0.156164]
# 0 в диапазоне, связь отсутствует

# I(age^1)
# b = -0.065310, σ = 0.029730
# доверительный интервал = [-0.123633, -0.006994]
# 0 вне диапазона, связь отрицательная

# качество модели на подмножестве очень низкое (R^2adj = 0.15%),
# модель незначима (p-value = 0.1866),
# только возраст имеет слабую отрицательную связь с зарплатой

