# c+-

记`c/c++`相关的有意思的东西。

[TOC]

## 数组、指针、引用

代码就不写了。

多态和数组是不兼容的，因为数组是靠类型大小偏移，而父类和子类的大小一般都不一样。

若把子类指针 cast 成父类指针，那当作数组用的时候就会出大问题。

---

```c++
int n;
scanf("%d", &n);
char **a;
a = (char**) malloc (n * n * sizeof(char));
for (int i = 0; i < n; ++i) 
    for (int j = 0; j < n; ++j) { 
        printf("%p ", *a + n * i + j);
        printf("%p\n", *(a + i) + j);
    }
```

本来是想偷懒不用循环`new`的，但却出现了一些意料之外的结果。

输出是这样的：

```shell
(nil) (nil)
0x1 0x1
0x2 0x2
0x3 (nil)
0x4 0x1
0x5 0x2
0x6 (nil)
0x7 0x1
0x8 0x2
```

==> 为什么一开始是`nil`？

这段代码本身是错的。

二维数组本身还是需要两次`malloc`。

`malloc`返回的本身是`void*`，把它强行转成`char**`会发生什么？

`void*`原本就是一个纯粹的用来存放地址的类型，`malloc`返回的就是堆中分配的内存的首地址。

把这个地址赋值给`char**`，然后对它取值，得到的自然是分配内存的初始化的值，也就是`0`。

这个`0`被当作了`char*`，那自然就是空指针。

==> 两种取值的方式各代表什么意思？

`*a + n * i + j`， `*a`是二级指针取值，本处只得到`0`，或者说`0x0`，类型为`char*`

`n * i + j`，`char*`加上这个是指针的移动，在**连续**内存中移动。

如果不是连续内存，就会有内存泄漏。

`*(a + i) + j`，这种方式会在连续的`char**`中取值，从而找到真正的`char*`的地址。

==> 虽然例子中代码是连续的一段`char`，但能不能当作二维数组用？

可以。

```c++
void show(char (*a)[4], int n) {
  for (int i = 0; i < n; ++i)
    for (int j = 0; j < n; ++j) {
      printf("%p %c || ", *a + n * i + j, *(*a + n * i + j));
      printf("%p %c\n", *(a + i) + j, *(*(a + i) + j));
    }
}

int main() {
  int n = 4;
  char* a = (char*)malloc(n * n * sizeof(char));
  for (int i = 0; i < n * n; ++i) a[i] = (i % 10) + '0';
  show((char(*)[4])a, n);
  return 0;
}
```

但是你必须知道`n == 4`。

所以真正的动态二维数组还是要`malloc`两次，且需要通过`*(*(a + i) + j)`访问。

当然下标也行。

不过，二维数组`malloc`两次还是太浪费空间了。真正的好方法是用重载运算符：

```c++
template <class T>
class Matrix {
 private:
  const int row;
  const int column;
  T* data;

 public:
  Matrix(int row_n, int column_n) : row(row_n), column(column_n) {
    this->data = new T(this->row * this->column);
  }
  ~Matrix() { delete this->data; }
  T* operator[](int num) { return &this->data[num * this->column]; }
};
```

如果有：

```c++
Matrix<int> matrix(3, 5);
matrix[2][3] = 1;
```

其中`[2]`是重载，`[3]`不是，写开来就是`matrix.operator[](2)[3]`。

编译器一次只能解析一个符号。

重载的那一步也可以这么写：`return this->data + num * this->column;`。

在一个一维的数组中，返回永远是一维指针。

所以如果是三维数组怎么办？只在一个类中是无法完成这样的任务的，需要一个中间对象。

中间对象中只需要一个指针属性和一个重载操作符函数。

第一次重载返回一个对象，第二次重载返回一维指针。

更高维可以类推。

三维实例如下：

```c++
class Cube {
 private:
  int* p;
  int l;
  int w;
  int h;

  class Cube2D {
   private:
    int* p;
    // 第三维
    int h;

   public:
    Cube2D(int* p, int h) : p(p), h(h) {}

    int* operator[](int j) { return p + h * j; }
  };

 public:
  Cube(int l, int w, int h) : l(l), w(w), h(h) { this->p = new int[l * w * h]; }

  Cube2D operator[](int i) { return Cube2D(p + i * (this->w + this->h), h); }

  void set(int* s, int len) {
    for (int i = 0; i < len; ++i) this->p[i] = s[i];
  }
};
```

注意`Cube`的重载中的指针移动，第二维第三维均需要考虑。

顺便一提，`c++`的内部类和`Java`不同，外部类对内没有特权，内部类对外同样没有特权，作用只是隐藏实现。

---

`const`引用可以指向一个常量，它究竟是怎么实现的？

```c++
const int& a = 3;
int b = 4;
cout << &a << " " << &b << endl;
char* f = (char*)&a;
printf("%02x %02x %02x %02x\n", *(f), *(f + 1), *(f + 2), *(f + 3));
cout << sizeof(int&) << " " << sizeof(char&) << endl;
```

输出是：

```shell
0x7fffffffd8e4 0x7fffffffd8e0
03 00 00 00
4 1
```

可以看出，`int& a`和`int b`的地址都在运行时栈区。

而所谓指向常量的引用，其实和`int a = 3`的实现基本一致。

同时，当我试图使用：

```c++
int& c = a;
```

时，`vscode`提醒我：

`将 "int &" 类型的引用绑定到 "const int" 类型的初始值设定项时，限定符被丢弃`。

可见，在现在的编译器眼里，`a`其实就是`const int`。

---

```c++
int a[4] = {0, (1 << 2) + (1 << 8) + (1 << 9) + (1 << 17) + (1 << 24), 2, 3};
int *b = &a[0];
const int *c = &a[1];
int const *d = &a[2];
int e = a[3];
cout << a << " " << &a << " " << &a[0] << " " << a[0] << endl;
cout << b << " " << &b << " " << &b[0] << " " << b[0] << endl;
cout << c << " " << &c << " " << &c[0] << " " << c[0] << endl;
cout << d << " " << &d << " " << &d[0] << " " << d[0] << endl;
printf("%p\n", &e);
cout << sizeof(a) << " " << sizeof(b) << endl;
char *f = (char *)c;
printf("%p %p %p %d\n", f, &f, &f[0], f[0]);
printf("%02x %02x %02x %02x\n", *(f), *(f + 1), *(f + 2), *(f + 3));
```

运行输出如下：

```shell
0x7fffffffd710 0x7fffffffd710 0x7fffffffd710 0
0x7fffffffd710 0x7fffffffd6f0 0x7fffffffd710 0
0x7fffffffd714 0x7fffffffd6f8 0x7fffffffd714 16909060
0x7fffffffd718 0x7fffffffd700 0x7fffffffd718 2
0x7fffffffd6ec
16 8
0x7fffffffd714 0x7fffffffd708 0x7fffffffd714 4
04 03 02 01
```

上述代码运行时栈内存分配图粗略如下：

![c_cpp_1](../../../assets/c_cpp_1.png)

低地址存放低位，跑这个代码的电脑是小端。

相信这张图基本已经可以说明一切了。

需要注意的是，`a`和`&a`是同一个值，甚至可以说`a`本身就没有实际意义 ==> `a`被分为4份，`a[0]`，`a[1]`，`a[2]`，`a[3]`。

当然，是编程所需的一切。想要理解真正的内存分配，还需要去看操作系统。

---

结构体中的柔性数组。

柔性数组是`array[]`，`array[0]`是零长数组。

```c++
class ArrayList {
 public:
  int length = 1;
  int array[0];
};

int main() {
  char str[] = "what";
  ArrayList* a = (ArrayList*)malloc(sizeof(ArrayList) + sizeof(str) + 1);
  strcpy((char*)(a + 1), str);
  printf("%p %d %p %p %s\n", a, a->length, &a->length, a->array, a->array);
  printf("%p %02x\n", (char*)a->array + sizeof(str) + 1,
         *((char*)a->array + sizeof(str) + 1));
  cout << sizeof(*a) << endl;
  return 0;
}
```

输出为：

```shell
0x55555556aeb0 0 0x55555556aeb0 0x55555556aeb4 what
0x55555556aeba 00
4
```

柔性数组必须出现在结构体或者说类的尾部，且其中一定要有别的元素。

长度为0的数组是不占空间的，它只是一个符号，指向结构体后第一个地址的符号。

当结构体中有指针指向另外的空间时，这种方法可以使用。

出于节省空间（不愿意再写一个`*array`指针指向某片空间），和结构体空间连续的需要，人们大量使用这种方法。

他们把结构体所需的空间以及其中字符串分配在一块连续的空间内，那多出来的1字节是`\0`，标识字符串结尾用的。

本处也可以看出，`malloc`并没有进行类的初始化。

---

类方法的`const`可以通过某些手段绕过去，比如引用。

代码示例：

```c++
// ref.cpp
class Ref {
 private:
  int& b;

 public:
  int a;

  Ref() : a(1), b(a) {}

  void set(int c) const { this->b = c; }

  int get() { return this->a; }
};

// main.cpp
int main() {
  Ref r;

  cout << "r.a: " << r.get() << endl;
  r.set(10086);
  cout << "r.a: " << r.get() << endl;

  return 0;
}
```

输出为：

```shell
r.a: 1
r.a: 10086
```

可见修饰为`const`的方法改变了类属性的值。

这里是因为编译器认为引用的值，也就是它指向的对象是没法改的，所以编译就过了。

这里`Ref::b`换成指针，指向`Ref::a`，效果一样。

c++ 实现的是按逻辑保证`const`，所以甚至编译器自己都给你提供了在`const`方法里修改成员变量的方法：

`mutable`关键字，用于修饰属性，修饰的属性在`const`方法里照样可以修改。

其实所谓`const`函数，不过是其隐含的`this`变成了：`f(const T* const this)`，前边多一个`const`。

所以可以用`const_cast<T*>(this)`来干坏事。

## sizeof

`sizeof`是类型特化的。可变长度的类型不会影响其`sizeof`的值。

```c++
#define my_sizeof(type) ((char*)(&type + 1) - (char*)(&type))

class A {
 public:
  int a;
  string b;
};

class B {};

int main() {
  vector<string> c{string(33, 'i'), "1", "2", "3", "4", "5"};
  A* e = (A*)malloc(sizeof(int) * 1000);
  cout << sizeof(*e) << endl;
  cout << sizeof(c) << " " << my_sizeof(c) << endl;
  cout << sizeof(A) << " " << sizeof(B) << endl;
  return 0;
}
```

输出是：

```shell
40
24 24
40 1
```

但是造成这种情况的原因不一定是`sizeof`，更可能是`c++`类型实现机制。

以`string`为例，它里边有一个`c_str`的`const char*`指针，但它指向的内存在哪里不知道。

这块内存大概率也不算在`string`的大小里边。

关于`string`内存分配可以看一下[这一篇博文](http://www.downeyboy.com/2019/06/24/c++_string/)。

毕竟无法验证，就不多写了。

## derive and virtual

```c++
class B {
 protected:
  int y = 1;

 public:
  int get() { return this->y; }
  void set(int v) { this->y = v * 2 + y; }
  virtual void set(int x, int y) { this->y = x + y * 1000; }
};

class D : public B {
 public:
  int y = -1;
  void set() { this->y = -2; }
  void set(int v) { B::set(v); }
};

int main() {
  D* d = new D();
  d->set(100);
  // 下一行编译错误
  // d->set(-1, -2);
  cout << d->get() << endl;
  return 0;
}
```

输出：

```shell
201
```

最重要的是父类的`B::y`和子类的`D::y`不是一个东西，也不是覆盖的关系。

在父类`B`中的`get`被`D d`调用，取的还是`B::y`，不会因为在子类就取子类的`D::y`。

即使是`virtual int D::get()`也是一样。虚函数是动态绑定函数，但不会改变函数的行为。

编译错误是因为，子类的函数重写是先匹配函数名，若同名，直接在子类中找参数列表，父类的参数列表就直接被忽略了。这里是不是虚函数没有影响，它只是动态绑定，编译都没过，弹何动态绑定？

---

```c++
class A {
 protected:
  int y = -2;

 public:
  virtual int getY() { return y; }
};

class B : public A {
 private:
  int getY() { return -100; }
};

int main() {
  A* a = new B;
  cout << a->getY() << endl;
  return 0;
}
```

结果：

```shell
-100
```

运行时没有权限机制，权限机制只有编译时按照静态类型检查。

这里的虚函数就直接跳过了权限检查，因为在编译时没有错误，而运行时虚函数指针根据虚函数表找到了`B`的`getY()`。

下边的代码进一步佐证。

```c++
class A {
 private:
  virtual void foo() = 0;

 public:
  void fooo() { foo(); }
};

class C : public A {
 public:
  void foo() { cout << "In c!" << endl; }
};

int main() {
  A* a = new C;
  a->fooo();
  return 0;
}
```

输出：

```shell
In c!
```

同时顺便提一句，父类的`public`和`protected`属性，子类是可以改的。

---

不同类型的继承。

```c++
class A {};

class B : public A {};

class C : protected A {};

int main() {
  A a;
  B b;
  C c;
  foo(a);
  foo(b);
  foo(c);
  return 0;
}
```

结果如下：

![c_cpp_2](../../../assets/c_cpp_2.png)

此时的`C`和`A`的接口不一样。

私有继承只在实现层面用，设计层面没有用。

可以自己重载类型转换操作符：

```c++
class A {};

class C {
 public:
  operator A() { return *new A; }
};


int main() {
  A a;
  C c;
  A d = c;
  return 0;
}
```

上述代码无报错。但是如果`C`是`class C : protected A {...};`

即使有重载类型转换，似乎也不行。

---

虚函数和缺省参数是不对付的。

虚函数是动态绑定，缺省参数是静态绑定。

```c++
class A {
 public:
  virtual void foo(int a = 2) {
    cout << "In a!"
         << " " << a << endl;
  };
};

class C : public A {
 public:
  void foo(int a = 3) {
    cout << "In c!"
         << " " << a << endl;
  }
};

int main() {
  A* a = new C;
  a->foo();
  return 0;
}
```

输出：

```shell
In c! 2
```

笑死。

就是虚函数只是个指针指向虚函数表的，它哪知道表里是什么牛鬼蛇神。

参数什么的还是静态绑定的啦。

## overload operator

箭头操作符重载。在迭代器里经常见到这种用法。

需要注意的是，这个箭头运算符是对象调用的，不是对象指针调用的，后者是内置的`(*a).f()`。

箭头操作符重载必须返回指针类型，防止套娃。当然还是可以套的。

对于一个`a->f()`，可以看作`a.operator->()->f()`。

```c++
class A {
 public:
  A* operator->() {
    cout << "xs" << endl;
    return this;
  }
  void say() { cout << "xswl" << endl; }
};

int main() {
  A a;
  a.operator->()->say();
  return 0;
}
```

输出如下：

```shell
xs
xswl
```

---

下标运算符重载。需要重载两种，一种是正常的那种，另外一种是有`const`修饰符的。

代码示例：

```c++
// index_operator.cpp
class IndexOperator {
 private:
  string c;

 public:
 IndexOperator() : c("indexoperator") {}

  char& operator[](int i) {
    cout << "non-const" << endl;
    return this->c[i];
  }

  const char& operator[](int i) const {
    cout << "const" << endl;
    return this->c[i];
  }
};

// main.cpp
void foo(const IndexOperator& a) { cout << a[0] << endl; }

int main() {
  freopen("stdin.txt", "r", stdin);

  IndexOperator i;

  cout << i[0] << endl;
  foo(i);

  return 0;
}
```

输出为：

```shell
non-const
i
const
i
```

一个是可修改，另外一个是用于`const`。

下标运算符和取地址运算符都属于需要重载两种的运算符。

## exception

```cpp
class A {
 public:
  int c = 1;
  virtual void say() { cout << "tmd A" << endl; }
};

class B : public A {
 public:
  void say() { cout << "tmd B" << endl; }
};


void f(B& a) {
  a.c = 2;
  a.say();
  // 在throw这里拷贝构造
  // B b1 = b;
  // throw b1;
  throw a;
}

int main() {
  B b = B();
  A& a = b;

  b.say();
  a.say();

  try {
    f(b);
  } catch (A& d) {
    d.say();
    d.c = 3;
  }

  cout << b.c << " " << a.c << endl;
  return 0;
}
```

两个地方需要注意，一个是引用仍然可以使用虚函数，因为不是真正的拷贝构造。

这里把子类赋值给父类的引用，但是二者本质上还是指向同一块内存。

另外一个是，throw 的时候，是进行了拷贝构造，和原来的变量不是同一个。

拷贝构造只看类型。

输出：

```shell
tmd B
tmd B
tmd B
tmd B
2 2
```

这里倒数第二行是`tmd B`，但如果函数`f`的参数变成`A&`，那这里就会输出`tmd A`。

同时，最后一行数字没有改变也说明这是拷贝不是引用。

## static

类内的静态变量的初始化必须在类外，且只初始化一次。

所以一般放在类的实现文件中初始化。

`const`静态变量可以在类内初始化，因为可以视作常量。

为什么？

==> 静态成员属于整个类，而不属于某个对象。如果在类内初始化，会导致每个对象都包含该静态成员，这是矛盾的。

可以见[这篇文章](https://zhuanlan.zhihu.com/p/79144299)。

关于`static`和`const`以及`constexpr`的关系详见《c++ primer》。

## 友元

c++ 要求使用前先声明。

友元函数不用事先声明，友元函数若是类中方法则类一定要有完全的声明，即确保类中有对应方法。

友元类有点麻烦。如果是`friend class B`，则若没有声明编译器会帮你生成一个。若是`friend B`，则没有声明会报错。后者一般用于模板那里。

友元产生的循环依赖问题。

一般来说，循环依赖可以用不完全声明解决。前提是循环依赖所牵扯到的类都是使用指针和引用方式使用的，编译器知道如何分配内存。

```c++
// important！！！！！！！！！！！
class C;

class B {
  friend class C;

 public:
  void f(B b, C c);

 private:
  int b = -10086;
};

class C {
  friend class B;

 public:
  void f(B b, C c);

 private:
  int c = 10086;
};

void B::f(B b, C c) { cout << b.b << " B " << c.c << endl; }
void C::f(B b, C c) { cout << b.b << " C " << c.c << endl; }

int main() {
  B b;
  C c;
  b.f(b, c);
  c.f(b, c);
  return 0;
}
```

如果少了第一句的类声明，编译不通过。

个人认为编译器帮你生成的`friend class C`和后来的实际的`C`是两个类，所以会出现这样的问题。

`friend class C`是声明`C`可以访问`B`，但是和`f`中要用的`C`应该不能混为一谈。

还有，`friend class C`如果先前没有定义`C`，则会引入`C`，但不定义它。

来自 Microsoft Doc：

若要声明两个互为友元的类，则必须将**整个**第二个类指定为第一个类的友元。此限制的原因是该编译器仅在声明第二个类的位置有足够的信息来声明各个友元函数。

**但暂时还没办法验证**。

**考试后细细探究**。友元与前置声明问题。

问题集中在`friend class C`和`class C`到底是什么关系。

还有一个不用引用就编译还能过的问题也没个准。
