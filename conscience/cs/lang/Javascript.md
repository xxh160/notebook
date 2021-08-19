# js learning notes

`?script`学习笔记。

参考最新 `ECMAscript` 标准。

目前最新标准为`ECMAscript6`。

- [js learning notes](#js-learning-notes)
  - [参考文档](#参考文档)
  - [函数传入引用](#函数传入引用)
  - [undefined](#undefined)
  - [对象字面量](#对象字面量)
  - [for in 语句](#for-in-语句)
  - [apply 调用函数](#apply-调用函数)
  - [块级作用域](#块级作用域)
  - [函数表达式和函数声明](#函数表达式和函数声明)
  - [解构赋值歧义](#解构赋值歧义)
  - [箭头函数](#箭头函数)
  - [ES6 模块 和 CommonJS 模块](#es6-模块-和-commonjs-模块)

## 参考文档

- `nodejs`[官方教程](http://nodejs.cn/learn)
- [ECMAScript 6 入门](https://es6.ruanyifeng.com/)

## 函数传入引用

见如下代码：

```js
function printA(a) {
  console.log(a.sis);
  a.sis = "sis2";
}

let a = {
  name: "a",
  description: "foo",
  bro: [1, 2, 3, 4],
  sis: "sis",
};
printA(a);
printA(a);
```

输出为：

```shell
sis
sis2
```

可见 js 函数传入为引用，可以修改。

js 中对象通过引用来传递，它们永远不会被拷贝。

## undefined

这个东西真麻烦。

`undefined` 在 `if` 语句中是 `false`，`null` 也一样。

在可能出现 `undefined` 的情况可以用 `||` 来设置默认值。

```js
function printA(a) {
  console.log(a.name || "undefined.");
}

let a = {
  age: 1,
};

printA(a);
a.name = "a";
printA(a);
```

输出为：

```shell
undefined.
a
```

对 `undefined` 检索属性会报错，用 `&&` 来避免，见如下代码：

```js
function printA(a) {
  try {
    console.log((a.name || "undefined hhhh") && a.name.charAt(0));
  } catch (err) {
    console.log(err.name);
  }
  console.log(a.name && a.name.charAt(0));
}

let a = {
  age: 1,
};

printA(a);
console.log("===");
a.name = "bca";
printA(a);
```

输出为：

```shell
TypeError
undefined //这是 js 自己输出的 undefined
===
b
b
```

原理是阻断，`&&` 语句中如果前者为 `false` 后者就不会运行。

`undefined` 是 `false` 但不是 `error`。

`undefined` 基本用法：

- 变量被声明但没有赋值，等于 `undefined`；

- 调用函数时，应该提供的参数没有提供，该参数等于 `undefined`；

- 对象没有赋值的属性，该属性的值为 `undefined`；

- 函数没有返回值时，默认返回 `undefined`。

测试代码：

```js
function foo(x) {
  console.log(x);
}

let i;
console.log(i);

console.log("===");

foo();

console.log("===");

let o = new Object();
console.log(o.p);

console.log("===");

let x = foo(1);
console.log(x);
```

输出：

```shell
undefined
===
undefined
===
undefined
===
1
undefined
```

## 对象字面量

js 对象通过字面量直接创建，注意属性名必须合法。

```java
let a = {
  hwd: "a",
  "hwd": "c",
  "h-w-d": "b",
};

console.log(a);
```

如果`h-w-d`不用引号包住，js 无法识别。

对于合法的属性名，括号无法作为区分标志：`hwd` 和 `"hwd"` 会被视为同名属性。

同名属性后声明的会覆盖先声明的。

代码输出为：

```shell
{ hwd: 'c', 'h-w-d': 'b' }
```

## for in 语句

枚举对象中所有属性名，包括原型的。

所以可以使用 `Object.hasOwnProperty()` 来检测是不是自己的属性。

而且，对一个数组做枚举要这么用：

```js
a = [1, 2, 9, 3, 4, 5];

for (let i in a) {
  console.log(a[i]);
}
```

否则输出是下标。

所以，尽量使用`for of`。

## apply 调用函数

函数本身可以通过 `apply` 绑定 `this` 值，并通过数组传递参数。

简而言之：`func.apply(thisArg, [argsArray])`。

前者必选，后者可选。

如果没有 `this`，需要传入 null。

代码：

```js
function get(i) {
  console.log(i);
}

let a = {
  name: "a",
};

let app = {
  name: "app",
  getName: function (i) {
    console.log(this.name + " " + i);
  },
};

app.getName.apply(a, [1]);
get.apply(null, [2]);
```

输出：

```shell
a 1
2
```

`call` 和它的区别在于不用数组，直接传入参数列表。

下边的代码直观地展现了区别：

```js
function sum(x, y, z) {
  return x + y + z;
}

const numbers = [1, 2, 3];

console.log(sum.apply(null, numbers));
console.log(sum.call(null, ...numbers));
```

输出：

```shell
6
6
```

## 块级作用域

`var` 是全局作用域，这真是个糟糕的设计。

代码如下：

```js
{
  var a = 1;
}

console.log(a);
```

这样的代码**居然**没有任何问题。

但是 `let` 拥有块级作用域，所以用 `let`。

不过 js 拥有函数作用域，即函数内变量函数外不可见，不管是 `var` 还是 `let` 都一样。

同时，函数声明拥有块级作用域，以下代码会报错：

```js
foo();

{
  function foo() {
    console.log("foo");
  }
}
// TypeError: foo is not a function
```

## 函数表达式和函数声明

这两种方式都可以用来定义函数，区别为究竟有没有函数名。

见代码：

```js
function foo(a) {
  console.log("foo " + a);
} //函数声明

let fooo = function (a) {
  console.log("fooo " + a);
}; //函数表达式
```

函数声明有`函数声明提升`，可以在声明前调用函数：

```js
foo();

function foo() {
  console.log("foo");
}
```

函数表达式就没这待遇，以下代码会报错：

```js
foo();

let foo = function foo() {
  console.log("foo");
};
// ReferenceError: Cannot access 'foo' before initialization
```

当然，上述代码中函数表达式内含函数名的写法没问题，主要是方便递归。

> 命名函数表达式（Named function expression）

函数表达式和函数声明都可以直接执行。

通过加括号将其变为表达式：

```js
(function fooo(a) {
  console.log("fooo " + a);
})(1);

(function (a) {
  console.log("fooo " + a);
})(2);
```

以上两种写法并没有本质区别。

本处不用括号，用任意运算符都可以，主要是告诉 js 解释器这是个函数表达式。

js 解释其本身无法判断这样的代码是函数声明还是表达式：

```js
function (a) {
    console.log("foo " + a);
}(1);
// SyntaxError: Function statements require a function name
```

除非显式告诉它，这也是为什么函数表达式可以这么调用：

```js
let a = (function (a) {
  console.log("foo " + a);
})(1);

let a = (function a(a) {
  console.log("foo " + a);
})(1);
```

第二个虽然有函数名，但不影响它是个函数表达式，上文已经说过。

可以参考[这篇文章](https://segmentfault.com/a/1190000003031456)，还有[这篇文章](https://zh.javascript.info/function-expressions)

## 解构赋值歧义

不止在解构赋值这边会出现。

我是在这里发现这个问题的。

解析大括号时，会出现两种选择：

- 语句，即类似`if(){}`这样的；
- 表达式，即对象字面量

机器可一点也不聪明。所以它规定行首为`{`一律解释为语句，如果想要表达式，加括号。

所以这样的代码会报错：

```js
let obj = {};
let arr = [];

{fo: obj.prop, bar: arr[0]} = {fo: 123, bar: true};
// SyntaxError: Unexpected token ':'
// correct: ({fo: obj.prop, bar: arr[0]} = {fo: 123, bar: true});
```

还有较为清晰的代码 demo：

```js
console.log(eval("{fo:1}"));
console.log(eval("({fo:1})"));
```

输出：

```shell
1
{ fo: 1 }
```

第一个会被解释为代码块，那个`fo`是`Unnecessary label`。

但是，和模式匹配相关的部分却不能乱加括号。

本部分较杂，见参考文档中的 [ECMAscript 6 入门](#参考文档)。

## 箭头函数

参考[这篇文章](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Functions/Arrow_functions)。

箭头函数不会创建自己的 this，它只会从自己的作用域链的上一层**继承** this。

而普通函数会创建自己的 this：

1. 严格模式下是 undefined；
2. 如果是对象方法，则指向对象。但是！！在方法内部定义的函数的 this 可就直接指向全局了；
3. 如果是一个构造函数，则指向新的对象；
4. 等等。

这都什么东西？？vue 教程里提了 n 次不要使用箭头函数...

```js
const app = createApp({
  data() {
    return { a: 1 }
  },
  methods: {
    plus() {
      this.a++
    }
  }
})

const vm = app.mount('#app')

vm.plus()
console.log(vm.a) // => 2
```

>注意，不应该使用箭头函数来定义 method 函数 (例如 plus：() => this.a++)。理由是箭头函数绑定了父级作用域的上下文，所以 this 将不会按照期望指向组件实例，this.a 将是 undefined。

我的猜测是，它的父级作用域不是 methods，应该还隔了层什么。理由是：

```js
"use strict";

let a = {
    d: -100,
    m: {
        b: 1,
        c: () => {
            console.log(this);
            ++this.b;
        },
        e: function() {
            console.log(this);
            let f = () => {
                console.log(this);
            };
            f();
            ++this.b;
        },
    },
};

console.log("a.m.b: " + a.m.b);
a.m.c();
console.log("a.m.b: " + a.m.b);
a.m.e();
console.log("a.m.b: " + a.m.b);
```

输出：

```shell
a.m.b: 1
{}
a.m.b: 1
{ b: 1, c: [Function: c], e: [Function: e] }
{ b: 1, c: [Function: c], e: [Function: e] }
a.m.b: 2
```

用传统方法定义的函数 this 绑定到了 m 而不是 a，说明对象字面量是有 this 的，同时传统方法中的箭头函数的 this 也绑定到了 m，说明一个花括号可以成为父作用域的范围。

那么第一个箭头函数的 this 为空，注意不是 undefined，我认为可能是`c:()=>{}`这里隐式创建了一个空对象。

但是这个和 vue 的不符合，那就是 vue 错了吧。（x

本问题 **remains to be validated**。

## ES6 模块 和 CommonJS 模块

内容详见[这里](https://es6.ruanyifeng.com/#docs/module)

ES6 模块是编译时加载，不加载全部内容，只取需要的内容。

CommonJS 模块是运行时加载，先把模块整体导入，然后再从中取出需要的部分。

所以 ES6 的效率要高，但是它本身并不能作为模块被加载。

同时，ES6 模块输出的变量是动态绑定，可以反映模块内部的值，但是 CommonJS 只有缓存。
