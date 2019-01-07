/**
 * 记账model
 * @author 郑业强 2018-12-31 创建文件
 */

#import "BKModel.h"


@implementation BKModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self = [NSObject decodeClass:self decoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [NSObject encodeClass:self encoder:aCoder];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[BKModel class]]) {
        return false;
    }
    BKModel *model = object;
    if ([self Id] == [model Id]) {
        return true;
    }
    return false;
}

- (NSString *)dateStr {
    NSString *str = [NSString stringWithFormat:@"%ld-%02ld-%02ld", _year, _month, _day];
    NSDate *date = [NSDate dateWithYMD:str];
    return [NSString stringWithFormat:@"%ld年%02ld月%02ld日   %@", _year, _month, _day, [date dayFromWeekday]];
}

- (NSDate *)date {
    return [NSDate dateWithYMD:[NSString stringWithFormat:@"%ld-%02ld-%02ld", _year, _month, _day]];
}

- (NSInteger)dateNumber {
    return [[NSString stringWithFormat:@"%ld%02ld%02ld", _year, _month, _day] integerValue];
}

- (NSInteger)week {
    return [self.date weekOfYear];
}

@end



@implementation BKMonthModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self = [NSObject decodeClass:self decoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [NSObject encodeClass:self encoder:aCoder];
}

- (NSString *)dateStr {
    return [NSString stringWithFormat:@"%02ld月%02ld日   %@", [_date month], [_date day], [_date dayFromWeekday]];
}

- (NSString *)moneyStr {
    NSMutableString *strm = [NSMutableString string];
    if (_income != 0) {
        [strm appendFormat:@"收入: %@", [@(_income) description]];
    }
    if (_income != 0 && _pay != 0) {
        [strm appendString:@"    "];
    }
    if (_pay != 0) {
        [strm appendFormat:@"支出: %@", [@(_pay) description]];
    }
    return strm;
}

+ (NSMutableArray<BKMonthModel *> *)statisticalMonthWithYear:(NSInteger)year month:(NSInteger)month {
    // 根据时间过滤
    NSMutableArray<BKModel *> *bookArr = [[PINDiskCache sharedCache] objectForKey:PIN_BOOK];
    NSString *preStr = [NSString stringWithFormat:@"year == %ld AND month == %ld", year, month];
    NSPredicate *pre = [NSPredicate predicateWithFormat:preStr];
    NSMutableArray<BKModel *> *models = [NSMutableArray arrayWithArray:[bookArr filteredArrayUsingPredicate:pre]];
    
    // 统计数据
    NSMutableDictionary *dictm = [NSMutableDictionary dictionary];
    for (BKModel *model in models) {
        NSString *key = [NSString stringWithFormat:@"%ld-%02ld-%02ld", model.year, model.month, model.day];
        // 初始化
        if (![[dictm allKeys] containsObject:key]) {
            BKMonthModel *submodel = [[BKMonthModel alloc] init];
            submodel.list = [NSMutableArray array];
            submodel.income = 0;
            submodel.pay = 0;
            submodel.date = [NSDate dateWithYMD:key];
            [dictm setObject:submodel forKey:key];
        }
        // 添加数据
        BKMonthModel *submodel = dictm[key];
        [submodel.list addObject:model];
        // 收入
        if (model.cmodel.is_income == true) {
            [submodel setIncome:submodel.income + model.price];
        }
        // 支出
        else {
            [submodel setPay:submodel.pay + model.price];
        }
        [dictm setObject:submodel forKey:key];
    }
    
    // 排序
    NSMutableArray<BKMonthModel *> *arrm = [NSMutableArray arrayWithArray:[dictm allValues]];
    arrm = [NSMutableArray arrayWithArray:[arrm sortedArrayUsingComparator:^NSComparisonResult(BKMonthModel *obj1, BKMonthModel *obj2) {
        return [obj1.dateStr compare:obj2.dateStr];
    }]];
    return arrm;
}

@end




@implementation BKChartModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self = [NSObject decodeClass:self decoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [NSObject encodeClass:self encoder:aCoder];
}

+ (BKChartModel *)statisticalChart:(NSInteger)status isIncome:(BOOL)isIncome date:(NSDate *)date {
    NSMutableString *preStr = [NSMutableString string];
    NSMutableArray *arrm = [[PINDiskCache sharedCache] objectForKey:PIN_BOOK];
    [preStr appendFormat:@"cmodel.is_income == %d", isIncome];
    // 周
    if (status == 0) {
        NSDate *start = [date offsetDays:[date weekday] - 1];
        NSDate *end = [date offsetDays:7 - [date weekday]];
        NSDateFormatter *fora = [[NSDateFormatter alloc] init];
        [fora setDateFormat:@"yyyyMMdd"];
        [fora setTimeZone:[NSTimeZone localTimeZone]];
        NSInteger startStr = [[fora stringFromDate:start] integerValue];
        NSInteger endStr = [[fora stringFromDate:end] integerValue];
        
        [preStr appendFormat:@" AND dateNumber >= %ld AND dateNumber <= %ld", startStr, endStr];
    }
    // 月
    else if (status == 1) {
        [preStr appendFormat:@" AND year == %ld AND month == %ld", date.year, date.month];
    }
    // 年
    else if (status == 2) {
        [preStr appendFormat:@" AND year == %ld", date.year];
    }
    NSPredicate *pre = [NSPredicate predicateWithFormat:preStr];
    NSMutableArray<BKModel *> *models = [NSMutableArray arrayWithArray:[arrm filteredArrayUsingPredicate:pre]];
    
    
    NSMutableArray<BKModel *> *chartArr = [NSMutableArray array];
    NSMutableArray<NSMutableArray<BKModel *> *> *chartHudArr = [NSMutableArray array];
    // 周
    if (status == 0) {
        NSDate *first = [date offsetDays:[date weekday] - 1];
        for (int i=0; i<7; i++) {
            NSDate *date = [first offsetDays:i];
            BKModel *model = [[BKModel alloc] init];
            model.year = date.year;
            model.month = date.month;
            model.day = date.day;
            model.price = 0;
            [chartArr addObject:model];
            [chartHudArr addObject:[NSMutableArray array]];
        }
        for (BKModel *model in models) {
            chartArr[[model.date weekday] - 1].price += model.price;
            [chartHudArr[7 - [model.date weekday]] addObject:model];
        }
    }
    // 月
    else if (status == 1) {
        for (int i=1; i<=[date daysInMonth]; i++) {
            BKModel *model = [[BKModel alloc] init];
            model.year = date.year;
            model.month = [date daysInMonth];
            model.day = i;
            model.price = 0;
            [chartArr addObject:model];
            [chartHudArr addObject:[NSMutableArray array]];
        }
        for (BKModel *model in models) {
            chartArr[model.day-1].price += model.price;
            [chartHudArr[model.day-1] addObject:model];
        }
    }
    // 年
    else if (status == 2) {
        for (int i=1; i<=12; i++) {
            BKModel *model = [[BKModel alloc] init];
            model.year = date.year;
            model.month = i;
            model.day = 1;
            model.price = 0;
            [chartArr addObject:model];
            [chartHudArr addObject:[NSMutableArray array]];
        }
        for (BKModel *model in models) {
            chartArr[model.month-1].price += model.price;
            [chartHudArr[model.month-1] addObject:model];
        }
    }
    
    
    NSMutableArray<BKModel *> *groupArr = [NSMutableArray array];
    for (BKModel *model in models) {
        NSInteger index = -1;
        for (NSInteger i=0; i<groupArr.count; i++) {
            BKModel *submodel = groupArr[i];
            if (submodel.category_id == model.category_id) {
                index = i;
            }
        }
        if (index == -1) {
            [groupArr addObject:model];
        }
        else {
            groupArr[index].price += model.price;
        }
    }
    [groupArr sortUsingComparator:^NSComparisonResult(BKModel *obj1, BKModel *obj2) {
        return obj1.price < obj2.price;
    }];
    
    
    BKChartModel *model = [[BKChartModel alloc] init];
    model.groupArr = groupArr;
    model.chartArr = chartArr;
    model.chartHudArr = chartHudArr;
    model.sum = [[chartArr valueForKeyPath:@"@sum.price.floatValue"] floatValue];
    model.max = [[chartArr valueForKeyPath:@"@max.price.floatValue"] floatValue];
    model.avg = [[NSString stringWithFormat:@"%.2f", model.sum / chartArr.count] floatValue];
    model.is_income = isIncome;
    return model;
}

@end
