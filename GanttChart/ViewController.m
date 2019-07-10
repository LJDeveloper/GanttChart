//
//  ViewController.m
//  GanttChart
//
//  Created by 凯悦 on 2019/7/10.
//  Copyright © 2019 kaiyue. All rights reserved.
//

#import "ViewController.h"
#import <ZMJGanttChart/ZMJGanttChart.h>
#import "ZMJCells.h"
#define SSCREEN_WIDTH       ([UIScreen mainScreen].bounds.size.width)   //屏幕宽度
#define SSCREEN_HEIGHT      ([UIScreen mainScreen].bounds.size.height)  //屏幕高度
@interface ViewController ()
<SpreadsheetViewDelegate, SpreadsheetViewDataSource>
@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, strong) NSArray<UIColor  *>            *colors;
@property (nonatomic, strong) SpreadsheetView *spreadsheetView;
@property (nonatomic,strong)NSMutableArray *dataSource;

@property (nonatomic, assign) NSInteger dayCount;
@end

@implementation ViewController

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        self.dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (NSMutableArray *)tasks
{
    if (!_tasks) {
        self.tasks = [NSMutableArray array];
    }
    return _tasks;
}
- (SpreadsheetView *)spreadsheetView {
    if (!_spreadsheetView) {
        _spreadsheetView = ({
            SpreadsheetView *ssv = [SpreadsheetView new];
            ssv.dataSource = self;
            ssv.delegate   = self;
            ssv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view addSubview:ssv];
            ssv;
        });
    }
    return _spreadsheetView;
}
- (void)setupMembers {
    self.tasks = @[
                   @[@"专项1", @"2", @"17", @"1"],
                   @[@"", @"2", @"8", @"0"],
                   @[@"专项2", @"2", @"7", @"1"],
                   @[@"", @"3", @"7", @"0"],
                   @[@"专项3", @"11", @"8", @"1"],
                   @[@"", @"11", @"8", @"0"],
                   @[@"专项", @"14", @"5", @"1"],
                   @[@"", @"14", @"5", @"0"],
                   ];
    self.colors = @[[[UIColor redColor] colorWithAlphaComponent:.8],
                    [[UIColor greenColor] colorWithAlphaComponent:.5],
                    [[UIColor yellowColor] colorWithAlphaComponent:.7],
                    [UIColor clearColor],
                    ];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupMembers];
    self.dayCount = 30;
    
    CGFloat hairline = 1 / [UIScreen mainScreen].scale;
    self.spreadsheetView.intercellSpacing = CGSizeMake(hairline, hairline);
    self.spreadsheetView.gridStyle = [[GridStyle alloc] initWithStyle:GridStyle_none width:hairline color:[UIColor grayColor]];
    [self.spreadsheetView registerClass:[ZMJHeaderCell class] forCellWithReuseIdentifier:[ZMJHeaderCell description]];
    [self.spreadsheetView registerClass:[ZMJTextCell class] forCellWithReuseIdentifier:[ZMJTextCell description]];
    [self.spreadsheetView registerClass:[ZMJTaskCell class] forCellWithReuseIdentifier:[ZMJTaskCell description]];
    [self.spreadsheetView registerClass:[ZMJChartBarCell class] forCellWithReuseIdentifier:[ZMJChartBarCell description]];
    self.spreadsheetView.showsVerticalScrollIndicator = NO;
    self.spreadsheetView.showsHorizontalScrollIndicator = NO;
    self.spreadsheetView.frame = CGRectMake(0, 80, self.view.frame.size.width, 280);
    
    UIView *firstview = [[UIView alloc]initWithFrame:CGRectMake(20, self.spreadsheetView.frame.origin.y+self.spreadsheetView.frame.size.height+20, 20, 20)];
    firstview.backgroundColor = self.colors[1];
    [self.view addSubview:firstview];
    UILabel *firstLable = [[UILabel alloc]initWithFrame:CGRectMake(50, self.spreadsheetView.frame.origin.y+self.spreadsheetView.frame.size.height+20,(SSCREEN_WIDTH-80)/2-30, 20)];
    firstLable.text = @"计划进度";
    firstLable.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:firstLable];
    
    UIView *secondview = [[UIView alloc]initWithFrame:CGRectMake((SSCREEN_WIDTH-80)/2+30, self.spreadsheetView.frame.origin.y+self.spreadsheetView.frame.size.height+20, 20, 20)];
    secondview.backgroundColor = self.colors[0];
    [self.view addSubview:secondview];
    UILabel *secondLable = [[UILabel alloc]initWithFrame:CGRectMake((SSCREEN_WIDTH-80)/2+60, self.spreadsheetView.frame.origin.y+self.spreadsheetView.frame.size.height+20,(SSCREEN_WIDTH-80)/2-30, 20)];
    secondLable.text = @"实际进度";
    secondLable.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:secondLable];
    
}

//MARK: DataSource
- (NSInteger)numberOfColumns:(SpreadsheetView *)spreadsheetView {
    return 1 + self.dayCount;
}

- (NSInteger)numberOfRows:(SpreadsheetView *)spreadsheetView {
    return 1 + self.tasks.count;
}

- (CGFloat)spreadsheetView:(SpreadsheetView *)spreadsheetView widthForColumn:(NSInteger)column {
    if (column == 0) {
        return 80.f;
    }else {
        return 20;
    }
}

- (CGFloat)spreadsheetView:(SpreadsheetView *)spreadsheetView heightForRow:(NSInteger)row {
    if (row == 0 ) {
        return 28.f;
    } else {
        return 25.f;
    }
}

- (NSInteger)frozenColumns:(SpreadsheetView *)spreadsheetView {
    return 1;
}

- (NSInteger)frozenRows:(SpreadsheetView *)spreadsheetView {
    return 1;
}

- (NSArray<ZMJCellRange *> *)mergedCells:(SpreadsheetView *)spreadsheetView {
    NSMutableArray<ZMJCellRange *> *result = [NSMutableArray array];
    
    NSArray<ZMJCellRange *> *charts = [self.tasks wbg_mapWithIndex:^ZMJCellRange* _Nullable(NSArray<NSString *> * _Nonnull task, NSUInteger index) {
        NSInteger start = [task[1] integerValue];
        NSInteger end   = [task[2] integerValue];
        return [ZMJCellRange cellRangeFrom:[Location locationWithRow:index + 1 column:start ]
                                        to:[Location locationWithRow:index + 1 column:start + end - 1 ]];
    }];
    [result addObjectsFromArray:charts];
    
    for (int i=0; i<self.tasks.count/2; i++) {
        NSArray<ZMJCellRange *> *charts0 = [self.tasks wbg_mapWithIndex:^ZMJCellRange* _Nullable(NSArray<NSString *> * _Nonnull task, NSUInteger index) {
            return [ZMJCellRange cellRangeFrom:[Location locationWithRow:i*2+1 column:0 ]
                                            to:[Location locationWithRow:i*2+2 column:0]];
        }];
        [result addObjectsFromArray:charts0];
    }
    
    
    return result.copy;
}
- (ZMJCell *)spreadsheetView:(SpreadsheetView *)spreadsheetView cellForItemAt:(NSIndexPath *)indexPath {
    NSInteger column = indexPath.column;
    NSInteger row    = indexPath.row;
    if (column == 0 && row == 0) {
        ZMJHeaderCell *cell = (ZMJHeaderCell *)[spreadsheetView dequeueReusableCellWithReuseIdentifier:[ZMJHeaderCell description] forIndexPath:indexPath];
        cell.label.text = @"专项工序/日期";
        cell.gridlines.left = [GridStyle style:GridStyle_default width:0 color:nil];
        cell.gridlines.right = [GridStyle borderStyleNone];
        return cell;
    }
    else if (column >= 1 && column < (1 + self.dayCount) && row == 0) {
        ZMJHeaderCell *cell = (ZMJHeaderCell *)[spreadsheetView dequeueReusableCellWithReuseIdentifier:[ZMJHeaderCell description] forIndexPath:indexPath];
        cell.label.text = [NSString stringWithFormat:@"%02ld", indexPath.column];
        cell.gridlines.left  = [GridStyle style:GridStyle_default width:0 color:nil];
        cell.gridlines.right = [GridStyle style:GridStyle_default width:0 color:nil];
        return cell;
    }
    else if (column == 0 && row >= 1 && row < (1 + self.tasks.count)) {
        ZMJHeaderCell *cell = (ZMJHeaderCell *)[spreadsheetView dequeueReusableCellWithReuseIdentifier:[ZMJHeaderCell description] forIndexPath:indexPath];
        cell.label.text = self.tasks[indexPath.row - 1][0];
        cell.label.font = [UIFont systemFontOfSize:14];
        cell.gridlines.left  = [GridStyle style:GridStyle_default width:0 color:nil];
        cell.gridlines.right = [GridStyle style:GridStyle_default width:0 color:nil];
        return cell;
    }
    else if (column >= 1 && column < (1 + 7 * self.dayCount) && row >= 1 && row < (1 + self.tasks.count)) {
        ZMJChartBarCell *cell = (ZMJChartBarCell *)[spreadsheetView dequeueReusableCellWithReuseIdentifier:[ZMJChartBarCell description] forIndexPath:indexPath];
        NSInteger start = [self.tasks[indexPath.row - 1][1] integerValue];
        if (start == indexPath.column ){
            //cell.label.text = self.tasks[indexPath.row - 1][0];
            NSInteger colorIndex = [self.tasks[indexPath.row - 1][3] integerValue];
            cell.color = self.colors[colorIndex];
        } else {
            cell.label.text = @"";
            cell.color = [UIColor clearColor];
        }
        return cell;
    }
    else {
        return nil;
    }
}

/// Delegate
- (void)spreadsheetView:(SpreadsheetView *)spreadsheetView didSelectItemAt:(NSIndexPath *)indexPath {
    NSLog(@"Selected: (row: %ld, column: %ld)", (long)indexPath.row, (long)indexPath.column);
}

@end
