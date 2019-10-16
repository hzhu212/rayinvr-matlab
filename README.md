# rayinvr-matlab

地震射线追踪与地层模型反演软件 rayinvr 的 Matlab 版本。

关于 rayinvr 的详细信息请参考：

- [rayinvr by Zelt](http://terra.rice.edu/department/faculty/zelt/rayinvr.html)
- [修正版的 rayinvr 源码，可在 Windows10 和 Ubuntu18.04 上编译并运行](https://github.com/hzhu212/rayinvr)

## 使用方法

- 下载该代码仓库，在 Matlab 中进入该仓库根目录。
- 准备 rayinvr 项目数据。所有项目文件应放在同一个目录下，主要包括 `r.in`、`v.in`、`tx.in` 等。项目不要求放在代码目录下。
- 使用如下命令对项目进行正演计算：

```matlab
>> project_dir = 'D:\path\to\project\';
>> start_rayinvr(project_dir);
```

### 输出示例

正演程序将会输出两幅图像：

1. 射线追踪图像

    ![ray trace](https://raw.githubusercontent.com/hzhu212/image-store/master/blog/1.png)

2. 走时图像

    ![reduced time](https://raw.githubusercontent.com/hzhu212/image-store/master/blog/2.png)

控制台输出的计算细节与原版 rayinvr 一致：

```
>> start_rayinvr(p)
shot#  -1:   ray code  2.3:    23 rays traced  
shot#  -1:   ray code  4.2:    81 rays traced  
shot#  -1:   ray code  6.2:   156 rays traced  
shot#  -1:   ray code  7.2:   140 rays traced  
shot#  -1:   ray code 10.2:   213 rays traced  
shot#  -1:   ray code 11.3:    46 rays traced  
shot#  -1:   ray code 12.2:   141 rays traced  
shot#  -1:   ray code 14.2:    99 rays traced  
shot#   1:   ray code  2.3:    31 rays traced  
shot#   1:   ray code  4.2:    89 rays traced  
shot#   1:   ray code  6.2:   166 rays traced  
shot#   1:   ray code  7.2:   142 rays traced  
shot#   1:   ray code 10.2:   236 rays traced  
shot#   1:   ray code 11.3:    43 rays traced  
shot#   1:   ray code 12.2:   174 rays traced  
shot#   1:   ray code 14.2:   106 rays traced  

|----------------------------------------------------------------|
|                                                                |
| total of  14712 rays consisting of   409229 points were traced |
|                                                                |
|           model consists of 15 layers and 363 blocks           |
|                                                                |
|----------------------------------------------------------------|

 
Number of data points used:     1886
RMS traveltime residual:       0.013
Normalized chi-squared:        1.117
 
 phase    npts   Trms   chi-squared
-----------------------------------
     1      54   0.009     0.896
     2     170   0.011     1.242
     3     322   0.003     0.123
     4     282   0.007     0.527
     5     449   0.020     1.705
     6      89   0.004     0.159
     7     315   0.014     1.923
     8     205   0.012     1.371
 
     shot  dir   npts   Trms   chi-squared
------------------------------------------
    11.531 -1     899   0.014     1.156
    11.531  1     987   0.012     1.083
 

ans =

    0.0127

```

## 相关项目

注意，本仓库仅翻译了原始软件的一部分模块，即 `rayinvr/rayinvr`，不包括 `rayinvr/pltsyn`、`rayinvr/tramp`。要使用这些模块，请参考以下仓库：

- [pltsyn-matlab](https://github.com/hzhu212/pltsyn-matlab)
- [tramp-matlab（未完成）]()

其他 rayinvr 周边：

- [rayinvr-vin-editor: 使用图形界面编辑 rayinvr 地层模型](https://github.com/hzhu212/rayinvr-v.in-editor)
- [rayinvr-data：我使用 rayinvr 处理过的项目数据](https://github.com/hzhu212/rayinvr-data)
- [rayinvr-ext: 通过包装脚本在 Matlab 中方便地调用 Fortran 源码编译的 rayinvr 原始程序](https://github.com/hzhu212/rayinvr-ext)
