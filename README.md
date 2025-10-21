# SAPR_LR2
Репозиторий для второй лабораторной работы по САПР
Создал Панфилов М.М. группа М3О-409Б-22 вариант 9
Сложение по ИЛИ с накоплением.(необходимо реализовать регистры: добавляемое значение, контрольный регистр, текущий результат)

[LAUNCH:]
1. simulate
2. vopt +acc "tb_apb" -o "test"
3. vsim "test"

[LAUNCH:] with coverage 
vlog *.sv +cover=bcesft
vsim -coverage tb_apb -do "run -all; coverage save apb_coverage.ucdb; coverage report -detail; quit"

To see percentages on coverage go: Instance (bottom bar) -> Instance Coverage (upper tool bar) -> Code coverage reports