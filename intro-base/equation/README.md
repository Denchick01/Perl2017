## Решить квадратное уравнение

* Необходимо решить квадратное уравнение вида ax² + bx + c = 0
* В качестве аргументов передаются коэффициенты a, b и c
* Аргументы и их количество необходимо проверять (возможно передать от 1 до 3)
* Необходимо так же проверить, что уравнение квадратное и имеет решение в действительных числах

В ответ необходимо вывести значение корней или сообщение о том, что решения нет

```sh
$ perl equation.pl
Bad arguments
$ perl equation.pl 0
Not a quadratic equation
$ perl equation.pl 1 0 -4
2, -2
```
