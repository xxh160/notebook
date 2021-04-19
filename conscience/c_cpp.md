# c+-

记一些`c/c++`相关的有意思的东西。

## 数组与指针

先看这段代码：

```c++
int n;
cin >> n;
char **a;
a = (char**) malloc (n * n * sizeof(char));
for (int i = 0; i < n; ++i) 
    for (int j = 0; j < n; ++j) { 
        printf("%p ", *a + n * i + j);
        printf("%p\n", *(a + i) + j);
    }
```

本来是想偷懒不用循环`new`的，但却出现了一些意料之外的结果。

还有这段代码，运行结果和电脑是大端小端似乎有关系：

```c++
int a[10];
int *b;
const int *c;
int const *d;
char e;
cout << a << " " << &a << " " << &a[0] << endl;
cout << b << " " << &b << " " << &b[0] << endl;
cout << c << " " << &c << endl;
cout << d << " " << &d << endl;
printf("%p\n", &e);
```

和这段一起看：

```c++
class ArrayList {
public:
    int length = 0;
    int array[0];
};

int main() {
    ArrayList a;
    cout << &a.length << " " << a.array << " " << &a.array << endl;
    cout << sizeof(a) << endl;
    return 0;
}
```
