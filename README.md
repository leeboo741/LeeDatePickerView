# LeeDatePickerView
一行代码集成时间选择器

### 例图
![例图1](https://github.com/leeboo741/ImageRepository/blob/master/DatePickerImage/ymd_single.png)
![例图2](https://github.com/leeboo741/ImageRepository/blob/master/DatePickerImage/ymd_zone.png)
![例图3](https://github.com/leeboo741/ImageRepository/blob/master/DatePickerImage/ymdhm_single.png)
![例图4](https://github.com/leeboo741/ImageRepository/blob/master/DatePickerImage/ymdhm_zone.png)
![例图5](https://github.com/leeboo741/ImageRepository/blob/master/DatePickerImage/ymdhms_single.png)
![例图6](https://github.com/leeboo741/ImageRepository/blob/master/DatePickerImage/ymdhms_zone.png)
![使用方法](https://github.com/leeboo741/ImageRepository/blob/master/DatePickerImage/leeDatePicker_usingCode.png)

### 使用简单

> 很简单，代码简单，使用更简单，一句话集成
>
> [LeeDatePickerView showLeeDatePickerViewWithStyle:LeeDatePickerViewStyle_StartAndEnd
>
>                                       formatterStyle:LeeDatePickerViewDateFormatterStyle_yMd
>
>                                                block:^(NSArray<NSDate *> *dateArray) {
>
>        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
>
>        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
>
>        self.startTimelabel.text = [dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_Start]];
>
>        self.endTimelabel.text =[dateFormatter stringFromDate:dateArray[LeeDatePickerViewSelectTimeArrayIndex_End]];
>
>    }];
>
> 就可以使用时间选择器，并且在block中返回选中的时间。

### 更新

 * 添加了单选时间的样式
 * 添加了显示的时间格式
 * 取消了开始时间和结束时间的校验

### 接下来

 * 可以自主选择传入 MinDate 和 MaxDate。
 * 可以自主选择传入 初始 Date。
 * 拆分 HeadView、ContentView、FootView。
 * 拆分View、Protocol、Delegate，使其可以继承Protocol来自定义HeadView、ContentView、FootView。
 * 代码还是很堆积，会在后面把代码拆分开来。

### Orz 依旧跪求星星

 1. 如果对您有点用，跪求一颗星星。
 2. 如果对您没有用，跪求一点建议。
 3. 如果发现什么错误，提交一下错误，我会尽快改正
