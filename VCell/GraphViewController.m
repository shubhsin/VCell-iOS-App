//
//  SecondViewController.m
//  VCell
//
//  Created by Aciid on 09/06/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController ()
{
    SimGraph *simGraph;
}

@end

@implementation GraphViewController

- (void)setGraphObject:(SimGraph *)obj
{
    simGraph = obj;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Nav bar settings
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    //Send user back if selected axes are less than required.
    if ([simGraph.XVar count] == 0 || [simGraph.YVar count] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select atleast 1 variable for X and Y Axes" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    //Init the Plotting
    [self initPlot];
    
    //Toggle view/hide of nav bar
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.hostView addGestureRecognizer:tapGestureRecognizer];
 
}
- (void)viewDidAppear:(BOOL)animated
{
    if ([simGraph.XVar count] != 0 || [simGraph.YVar count] != 0)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)toggleNavigationBar:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.navigationController setNavigationBarHidden:![self.navigationController isNavigationBarHidden] animated:YES];
    if([self.navigationController isNavigationBarHidden])
        self.hostView.hostedGraph.title = @"Results";
    else
        self.hostView.hostedGraph.title = @"";
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost
{
    self.hostView.allowPinchScaling = YES; 
}

-(void)configureGraph
{
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    
    // 2 - Set graph title
    NSString *title = @"Results";
    graph.title = title;
    
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
    // 4 - Set padding for plot area
   // [graph.plotAreaFrame setPaddingLeft:0.0f];
  //  [graph.plotAreaFrame setPaddingBottom:0.0f];
    
    // 5 - Enable user interactions for plot space
    graph.defaultPlotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots
{
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // 2 - Create the plot
    [simGraph.YVar enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {

        CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] init];
        scatterPlot.dataSource = self;
        scatterPlot.identifier = [simGraph.variables objectAtIndex:idx];
        CPTColor *color = [CPTColor colorWithComponentRed:((arc4random()%255)/255.0) green:((arc4random()%255)/255.0) blue:((arc4random()%255)/255.0) alpha:1.0];
        
        [graph addPlot:scatterPlot toPlotSpace:plotSpace];
        
        CPTMutableLineStyle *lineStyle = [scatterPlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth = 2.5;
        lineStyle.lineColor = color;
        scatterPlot.dataLineStyle = lineStyle;
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor =  color;
        
        CPTPlotSymbol *symbol = [self randomPlotSymbol];
        symbol.fill = [CPTFill fillWithColor:color];
        symbol.lineStyle = symbolLineStyle;
        symbol.size = CGSizeMake(6.0f, 6.0f);
        scatterPlot.plotSymbol = symbol;
        
    }];
    
    [plotSpace scaleToFitPlots:[graph allPlots]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
}

- (CPTPlotSymbol *)randomPlotSymbol
{
    NSUInteger rand = arc4random() % 11;
    
    NSArray *plotSymbols = [NSArray arrayWithObjects:
                                            @"crossPlotSymbol",
                                            @"ellipsePlotSymbol",
                                            @"rectanglePlotSymbol",
                                            @"plusPlotSymbol",
                                            @"starPlotSymbol",
                                            @"diamondPlotSymbol",
                                            @"trianglePlotSymbol",
                                            @"pentagonPlotSymbol",
                                            @"hexagonPlotSymbol",
                                            @"dashPlotSymbol",
                                            @"snowPlotSymbol",nil];
    SEL sel = NSSelectorFromString([plotSymbols objectAtIndex:rand]);
    return [CPTPlotSymbol performSelector:sel];
}

-(void)configureAxes
{
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    //Find the max number in values of X axis
    NSNumber *xMax = [[simGraph.values objectForKey:[simGraph.variables objectAtIndex:simGraph.XVar.firstIndex]] valueForKeyPath:@"@max.self"];
    
    int exponentialOfxMax = (int)log10f([xMax floatValue]);
    
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = [NSString stringWithFormat:@"%@ (10^%d)",[simGraph.variables objectAtIndex:simGraph.XVar.firstIndex],exponentialOfxMax]; // X-Axis Name
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    
    int xlimit = (int)ceilf([xMax floatValue]*pow(10, 1+abs(exponentialOfxMax)));
    
    CGFloat xValuesCount = xlimit;
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:xValuesCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:xValuesCount];
    
    
    //Find the limit till which the axis should be plotted

    //Plot the unit points on Axis 
    for(int i = 0;i<xlimit;i++)
    {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d",i] textStyle:x.labelTextStyle];
        label.tickLocation = CPTDecimalFromCGFloat(i/pow(10, 1+(-1)*(exponentialOfxMax)));
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:i/pow(10, 1+(-1)*(exponentialOfxMax))]];
        }
    }
    
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    
    //Find the max number in values of Y axis
    
    __block NSMutableArray *maxYNumbers = [NSMutableArray array];
    
    [simGraph.YVar enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
       
        [maxYNumbers addObject:[[simGraph.values objectForKey:[simGraph.variables objectAtIndex:idx]] valueForKeyPath:@"@max.self"]];
    }];
    
    NSNumber *yMax = [maxYNumbers valueForKeyPath:@"@max.self"];
    
    int exponentialOfyMax = (int)log10f([yMax floatValue]);
    
    
    if(simGraph.YVar.count == 1) // Y-Axis Name
        y.title = [simGraph.variables objectAtIndex:simGraph.YVar.firstIndex];
    else
        y.title = @"Multiple Variables";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    
    //Find the limit till which the axis should be plotted
    int ylimit = (int)ceilf([yMax floatValue]*pow(10, 1+abs(exponentialOfyMax)));

    
    CGFloat yValuesCount = ylimit;
    NSMutableSet *yLabels = [NSMutableSet setWithCapacity:yValuesCount];
    NSMutableSet *yLocations = [NSMutableSet setWithCapacity:yValuesCount];

    
       
    //Plot the unit points on Axis
    for(int i = 0;i<ylimit;i++)
    {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d",i] textStyle:x.labelTextStyle];
        label.tickLocation = CPTDecimalFromCGFloat(i/pow(10, 1+(-1)*(exponentialOfyMax)));
        label.offset = y.majorTickLength;
        if (label) {
            [yLabels addObject:label];
            [yLocations addObject:[NSNumber numberWithFloat:i/pow(10, 1+(-1)*(exponentialOfyMax))]];
        }
    }
    
    y.axisLabels = yLabels;
    y.majorTickLocations = yLocations;
}


#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [[simGraph.values objectForKey:[simGraph.variables objectAtIndex:0]] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    
    switch(fieldEnum)
    {
        case CPTScatterPlotFieldX:
            return [[simGraph.values objectForKey:[simGraph.variables objectAtIndex:simGraph.XVar.firstIndex]] objectAtIndex:index];

            break;
        
        case CPTScatterPlotFieldY:
                return [[simGraph.values objectForKey:plot.identifier] objectAtIndex:index];
            break;
            
    }
    return [NSDecimalNumber zero];
}

@end
