# c+-

记`c/c++`相关的有意思的东西。

## 数组、指针、引用

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

其中`[2]`是重载，`[3]`不是。

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
