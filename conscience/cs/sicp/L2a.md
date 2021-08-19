# lecture 2a

- [lecture 2a](#lecture-2a)
  - [Part 1：过程作为一般性的方法](#part-1过程作为一般性的方法)
  - [Part 2：过程作为返回值](#part-2过程作为返回值)
  - [Part 3：牛顿迭代法](#part-3牛顿迭代法)

## Part 1：过程作为一般性的方法

使用 sum-int，sum-square 和莱步尼茨公式作为例子。三种过程都一个公共的基础模式。

将这种公共的基础模式抽象出来，作为高阶过程。

## Part 2：过程作为返回值

使用不动点的方式计算平方根。

第一种，用的是过程作为参数的方式：

```scheme
(define (sqrt x)
    (fixed-point
        (lambda (y) (average (/ x y) y))
        1))

(define (fixed-point f start)
    (define (iter old new)
        (if (close-enough? old new)
            new
            (iter new (f new))))
    (iter start (f start)))
```

这里使用`(average (/ x y) y)`是一种叫做**平均阻尼**的技术。

在不动点搜寻中，函数`f`本身可能并不收敛，而平均阻尼技术使得我们作出的猜测不像`f(x)`那样远离 x，对此采用`(average f(x) x)`来控制变化。

而平均阻尼本身可以用这样的过程描述：

```scheme
(define (average-damp f)
    (lambda (x) (average x (f x))))
```

这是一个返回过程的过程。

## Part 3：牛顿迭代法

求函数 g 的零点的问题可以转换为求函数 f 的不动点的问题。

> 书本 p 49

程序语言的第一级元素特征。

> 书本 p 51
