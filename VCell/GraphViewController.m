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

- (void)setObject:(SimGraph *)obj
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
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    if ([simGraph.XVar count] == 0 || [simGraph.YVar count] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select atleast 1 variable for X and Y Axes" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [self initPlot];
       
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
