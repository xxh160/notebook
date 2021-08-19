# lecture 3a

- [lecture 3a](#lecture-3a)
  - [Part 1：列表操作](#part-1列表操作)
  - [Part 1.5：flatmap](#part-15flatmap)
  - [Part 2：图形语言](#part-2图形语言)
  - [Part 3：分层设计](#part-3分层设计)

## Part 1：列表操作

由于 cons 的闭包性质，我们可以很容易地构造出序列。

lisp 里内置一种特定的序列：list，它是一种语法糖。

map，对表中每一个元素做操作并返回一个表。

```scheme
(define (map func list)
    (if (null? list)
        `()
        (cons (func (car list))
            (map func (cdr list)))))
```

这是一种递归写法。它可以很容易地改为迭代写法：

```scheme
(define (map_iter func pre cur)
    (if (null? cur)
        pre
        (map_iter
            func
            (cons pre (func (car cur)))
            (cdr cur))))

(define (map func list)
    (map_iter func `() list))
```

上述写法输出的结果会有点表述上的缺陷，不过问题不大。一种解决方案是先用反转方式迭代，再反转回来。

for-each 是对原 list 做操作并且没有返回值，map 产生了原 list 的一个拷贝。

## Part 1.5：flatmap

这部分老师没有讲，但我可不能不学啊。

嵌套映射，将嵌套循环用映射表示。

```scheme
(define (flatmap proc list)
    (accumulate
        append
        '()
        (map proc list)))
```

其中的 accumulate 过程就是我们通常所说的 reduce 过程。

flatmap 其实就是把对 list 操作生成的一堆列表合并成一个列表。

如果要实现嵌套，proc 过程中往往也有 map 和 range。

实例：N 皇后问题。

注意自顶而下地设计程序。

```scheme
(define (queue-iter boards cur-num total-num)
    (if (= cur-num total-num)
        boards
        ...))

(define (queue size)
    (queue-iter '() 0 size))
```

假设已经实现了一个过程：safe?，即判断当前棋盘上是否安全的过程。

一行一行地解决。每次生成在已有条件基础上一个皇后在一行中所有可能的方式。

```scheme
(define (safe? safe-board cur-pos)
    ...)

(define (queue-iter boards cur-num total-num)
# 每次生成一个新解并判断是否 safe
# 如果 safe 就生成一个新的 board
)
```

如何生成一个新解？

假设有一个过程 range，生成从 start 到 end - 1 的序列：

```scheme
(define (range-iter start end l)
    (if (= start end)
        l
        (range-iter
            (+ 1 start)
            end
            (append l (list start)))))

(define (range start end)
    (range-iter start end '()))
```

这个 range 不能接收 start > end 的输入。

于是可以很容易生成期望坐标：

```scheme
(define (get-pos cur-row total-column)
    (map
        (lambda (a) (cons cur-row a))
        (range 0 total-column)))
```

注意 boards 是列表的列表，每一个列表代表一组解。

于是可以得出：

```scheme
(define (queue-iter boards cur-num total-num)
    (if (= cur-num total-num)
        boards
        (queue-iter
            (flatmap
                (lambda (cur-board)
                    (map
                        (lambda (safe-pos) (append cur-board safe-pos))
                        (filter
                            (lambda (pos) (safe? cur-board pos))
                            (get-pos cur-num total-num))))
                boards)
            (+ cur-num 1)
            total-num)))
```

最后我们来实现 safe?，这是最简单的部分。

```scheme
(define (safe? safe-board cur-pos)
    (accumulate
        and
        nil
        (map
            (lambda (safe-pos)
                (if (is-confilct safe-pos cur-pos)
                    #f
                    #t))
            safe-board)))

(define (is-confilct safe-pos cur-pos)
    ...# 就！！就判断横竖斜，累死了不写了)
```

没有书上的简洁，但是！！！我的方法是迭代啊嘿嘿。

## Part 2：图形语言

使用向量缩放定义框架。基本图像用线段列表表示。

> 框架定义在书本 p 91，画家定义在书本 p 93

## Part 3：分层设计

当你实现了基本元素：画家，那么剩下的事情就是构造 lisp 过程罢了。

框架是三个向量的列表。

> 书本 p 94 作出了基本实现

直接操作过程最大的好处就是封装性和闭包性质。

任何针对画家的变换组合都不用关心画家本身可以画出什么东西出来。

操作过程返回过程，使得复杂度可以迅速增加。

简单高阶函数例子，repeat：

```scheme
(define (repeat func n)
    (if (= 1 n)
        func
        (lambda (a) 
            (func ((repeat func (- n 1)) a)))))
```

但是这种复杂度是 O(n) 级别的。

我们可以使用二分法：

```scheme
(define (compose f g)
  (lambda (x)
    (f (g x))))

(define (repeat f n)
  (cond ((= n 1) f)
        ((even? n) (repeated (compose f f) (/ n 2)))
        (else (compose f (repeated f (- n 1))))))
```

前提是必须知道接口。

c++ 实现：

```c++
function<int(int)> repeat(function<int(int)> cur, int n) {
  if (n == 1) return cur;
  return [=](int a) -> int { return cur(repeat(cur, n - 1)(a)); };
}
```

这种语言的健壮就在于按层次分解，每一层次都有完全的表达能力，微小的描述改动不影响大局。

用下层的基本元素，来构造这一层次的基本元素，而这些基本元素通过组合抽象又可以用作上一层次的基本元素。
