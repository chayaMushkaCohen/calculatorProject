//
//  calculatorViewController.m
//  calculatorProject
//
//  Created by TAL on 12/04/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

#import "calculatorViewController.h"

@interface calculatorViewController ()
@property(nonatomic) NSMutableArray *numbers;
@property(nonatomic) NSMutableArray *fullyNmubersAndArithmeticSignsSequence;
@property (strong, nonatomic) IBOutlet UILabel *calculatorScreen;
@property (nonatomic) BOOL isNewNumber;
@property (nonatomic) BOOL isCurrentNumberFraction;
@property (nonatomic) int locationAfterPoint;
@property (nonatomic) BOOL isArrayConsistsOfNumbersOrOperations;
@property (nonatomic) NSString *lastMathematicalOperaion;
@property (nonatomic) NSString *previousCalculationResult;
@property (nonatomic) double consequtiveMultiplyingOrDividingCalculationValue;
@property (strong, nonatomic) IBOutlet UIButton *ACButton;



@end

@implementation calculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numbers = [NSMutableArray new];
    self.fullyNmubersAndArithmeticSignsSequence = [NSMutableArray new];
    self.calculatorScreen.text = @"0";
    self.isNewNumber = YES;
    self.isCurrentNumberFraction = NO;
    self.locationAfterPoint = 0;
    self.lastMathematicalOperaion = @"0";
    self.previousCalculationResult = @"0";
}

- (IBAction)identifyArithmeticSignButtonPressed:(id)sender {
    _lastMathematicalOperaion = @"0";
    _previousCalculationResult = @"0";
    if (self.locationAfterPoint != 0)
    {
        self.isCurrentNumberFraction = NO;
        self.locationAfterPoint = 0;
    }
    if ([[_numbers lastObject]  isEqual: @"fractionPlaceHolder"])
    {
        _isCurrentNumberFraction = NO; // need to check it
        [_numbers removeLastObject]; // last object is "frctionPlaceHolder"
    }
    UIButton *buttonSelected = (UIButton *)sender;
    UILabel *buttonTitle = buttonSelected.titleLabel;
    if ([[_numbers lastObject] isEqual:@"+"] || [[_numbers lastObject] isEqual:@"-"] || [[_numbers lastObject] isEqual:@"*"] || [[_numbers lastObject] isEqual:@"/"])
    {
        [_numbers removeLastObject]; // 2 consecutive math operations cancel the first one
    }
    [_fullyNmubersAndArithmeticSignsSequence addObject:buttonTitle.text]; // document last operation choosed
    if (buttonTitle.text == [NSString stringWithFormat:@"+"])
    {
        [self calculateEquation];
        [self.numbers addObject:@"+"];
    }
    else if (buttonTitle.text == [NSString stringWithFormat:@"-"])
    {
        [self calculateEquation];
        [self.numbers addObject:@"-"];
    }
    else if (buttonTitle.text == [NSString stringWithFormat:@"*"])
    {
        [self addMultiplicationOperationAndCalculateLastOperation];
    }
    
    else if (buttonTitle.text == [NSString stringWithFormat:@"/"])
    {
        [self addDistributionOperationAndCalculateLastOperation];

    }
    NSLog(@"%@", [_numbers lastObject]);
    _isNewNumber = YES;
}


- (void)addMultiplicationOperationAndCalculateLastOperation
{
    if (_numbers.count > 2)
    {
        double lastCalculation = 0;
        if ([[_numbers objectAtIndex:(_numbers.count - 2)] isEqual:@"*"])
        {
            lastCalculation = [[_numbers objectAtIndex:(_numbers.count - 3)]doubleValue] * [[_numbers objectAtIndex:(_numbers.count - 1)]doubleValue];
        }
        
        else if ([[_numbers objectAtIndex:(_numbers.count - 2)] isEqual:@"/"])
        {
            lastCalculation = [[_numbers objectAtIndex:(_numbers.count - 3)]doubleValue] / [[_numbers objectAtIndex:(_numbers.count - 1)]doubleValue];
        }
        [_numbers removeLastObject]; // remove the second number of caculation
        [_numbers removeLastObject]; // remove last operator
        [_numbers removeLastObject]; // remove the first number of calculation
        [_numbers addObject:[NSString stringWithFormat:@"%lf", lastCalculation]];
        [self adjustFontSizeToResultLength:lastCalculation];
    }
    [self.numbers addObject:@"*"];
}


- (void)addDistributionOperationAndCalculateLastOperation
{
    if (_numbers.count > 2)
    {
        if ([[_numbers objectAtIndex:(_numbers.count - 2)] isEqual:@"*"] || [[_numbers objectAtIndex:(_numbers.count - 2)] isEqual:@"/"])
        {
            double lastCalculation;
            if ([[_numbers objectAtIndex:(_numbers.count - 2)] isEqual:@"*"])
            {
                lastCalculation = [[_numbers objectAtIndex:(_numbers.count - 3)]doubleValue] * [[_numbers objectAtIndex:(_numbers.count - 1)]doubleValue];
            }
            else //if ([[_numbers objectAtIndex:(_numbers.count - 2)] isEqual:@"/"])
            {
                lastCalculation = [[_numbers objectAtIndex:(_numbers.count - 3)]doubleValue] / [[_numbers objectAtIndex:(_numbers.count - 1)]doubleValue];
            }
            [self adjustFontSizeToResultLength:lastCalculation];
            [_numbers removeLastObject]; // remove the second number of calculation
            [_numbers removeLastObject]; // remove * or / sign
            [_numbers removeLastObject]; // remove the first number of calculation
            [_numbers addObject:[NSString stringWithFormat:@"%lf", lastCalculation]];
        }
    }
    [self.numbers addObject:@"/"];
}


- (IBAction)addNewNumberToArray:(id)sender {
    UIButton *button = _ACButton;
    [button setTitle:@"C" forState:UIControlStateNormal];
    [self replaceAndRemoveObjectsThatRemainedFromLastCalculation];

    UIButton *buttonSelected = (UIButton *)sender;
    UILabel *buttonTitle = buttonSelected.titleLabel;
    int currentIndex = ((int)[self.numbers count]) - 1;
    _lastMathematicalOperaion = @"0";
    _previousCalculationResult = @"0";
    double existingNumber = [[self.numbers lastObject]doubleValue];
    existingNumber *= 10;
    existingNumber += [buttonTitle.text doubleValue];
    
    if (_isNewNumber == YES)
    {
        [self.numbers addObject:[NSString stringWithFormat:@"%lf", existingNumber]];
    }
    else if (_isCurrentNumberFraction)
    {
        [self addFractionAtCurrentIndex:currentIndex ToPreviousNumber:existingNumber];
    }
    else
    {
        [self.numbers removeObjectAtIndex:currentIndex];
        [self.numbers insertObject:[NSString stringWithFormat:@"%lf",existingNumber] atIndex: currentIndex];
    }
    self.calculatorScreen.textAlignment = NSTextAlignmentRight;
    double lastNumber = [[self.numbers lastObject]doubleValue];
    
    if (_isCurrentNumberFraction)
    {
        if (currentIndex == 0) // case of .5 for example
        {
            lastNumber = [[_numbers objectAtIndex:0]doubleValue];
        }
        else
        {
            lastNumber = [[self.numbers objectAtIndex:(currentIndex - 1)]doubleValue];            
        }
    }
    [self adjustFontSizeToResultLength:lastNumber];
    [self documentNumberEnteredAccordingToItsType];

    if (_isCurrentNumberFraction && [buttonTitle.text isEqual:@"0"])
    {
        [self printFractionNumber:lastNumber withMissingsZeros:currentIndex];
    }
    self.isNewNumber = NO;
}


- (void) replaceAndRemoveObjectsThatRemainedFromLastCalculation
{
    if (_numbers.count == 1)
    {
        if ([_numbers.lastObject isEqual:@"+"] || [_numbers.lastObject isEqual:@"-"] || [_numbers.lastObject isEqual:@"*"] || [_numbers.lastObject isEqual:@"/"])
        {
            [_numbers insertObject:@"0" atIndex:0]; // o is the first number
        }
        else if (_isNewNumber) // new number can not be entered without operation between two numbers
        {
            [_numbers replaceObjectAtIndex:0 withObject:@"0"]; // its only number in _numbers and its not 0
            _isNewNumber = NO;
        }
    }
    else if (_numbers.count == 2 && [_numbers.lastObject isEqual:@"fractionPlaceHolder"]) // remained from last fractions multipplication calculation
    {
        if (_fullyNmubersAndArithmeticSignsSequence.count != 1) // case of regular fraction creating
        {
            _isCurrentNumberFraction = NO;
            [_numbers removeAllObjects];
        }
    }
}


- (void) addFractionAtCurrentIndex:(int)currentIndex ToPreviousNumber:(double)existingNumber
{
    self.locationAfterPoint++;
    int divider = 1;
    for (int i = 0; i < self.locationAfterPoint; i++)
    {
        divider *= 10;
    }
    double fraction = existingNumber / divider;
    if (_numbers.count == 1) // case of .5 for example
    {
        [_numbers replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%lf", fraction]];
    }
    else
    {
        double totalNumber = [[_numbers objectAtIndex:(currentIndex - 1)] doubleValue] + fraction;
        
        [self.numbers removeObjectAtIndex:currentIndex]; // remove the @0 object fron numbers array
        [self.numbers addObject:[NSString stringWithFormat:@"%lf",totalNumber]];
        [self.numbers removeObjectAtIndex:(currentIndex - 1)]; // remove the last number in order to replace it by total number
    }

    [self.numbers addObject:[NSString stringWithFormat:@"fractionPlaceHolder"]]; //for another fraction
}


- (void) printFractionNumber:(double)lastNumber withMissingsZeros:(int)currentIndex
{
    int fractionAsInt = [[_numbers objectAtIndex:(currentIndex - 1)]doubleValue];
    int lengthOfIntPartOfFraction = [NSString stringWithFormat:@"%d", fractionAsInt].length;
    int amountOfMIssingZeros = _locationAfterPoint + lengthOfIntPartOfFraction - _calculatorScreen.text.length;
    NSString *calculatorScreenWithMissingsZeros = [NSString stringWithFormat:@"%g", lastNumber];
    if ([_calculatorScreen.text containsString:@"."])
    {
        amountOfMIssingZeros+= 1;
    }
    else
    {
        calculatorScreenWithMissingsZeros = [calculatorScreenWithMissingsZeros stringByAppendingString:@"."];
    }
    
    for (int i = 0; i < amountOfMIssingZeros; i++)
    {
        calculatorScreenWithMissingsZeros = [calculatorScreenWithMissingsZeros stringByAppendingString:@"0"];
    }
    _calculatorScreen.text = calculatorScreenWithMissingsZeros;
}


- (void) documentNumberEnteredAccordingToItsType
{
    if (_isCurrentNumberFraction) // we need not to put "fractionPlaceHolder" as _fullyNumber last object
    {
        if (_fullyNmubersAndArithmeticSignsSequence.count == 0) // case of .5 for exmple. _fully has no objects
        {
            [_fullyNmubersAndArithmeticSignsSequence addObject:[_numbers objectAtIndex:0]];
        }
        
        [_fullyNmubersAndArithmeticSignsSequence replaceObjectAtIndex:(_fullyNmubersAndArithmeticSignsSequence.count - 1) withObject:[_numbers objectAtIndex: (_numbers.count - 2)]];
    }
    else if (!_isNewNumber && _fullyNmubersAndArithmeticSignsSequence.count > 0)
    {
        [_fullyNmubersAndArithmeticSignsSequence replaceObjectAtIndex:(_fullyNmubersAndArithmeticSignsSequence.count - 1) withObject:_numbers.lastObject];
    }
    else
    {
        [_fullyNmubersAndArithmeticSignsSequence addObject:_numbers.lastObject]; // document last number entered into _numbers
    }
}


- (IBAction)turnNumberIntoPercentage:(id)sender {
    if (_numbers.count == 0)
    {
        [_numbers addObject:@"0"];
        [_fullyNmubersAndArithmeticSignsSequence addObject:@"0"];
    }
    if ([_numbers.lastObject isEqual:@"fractionPlaceHolder"])
    {
        _isCurrentNumberFraction = NO;
        [_numbers removeLastObject];
    }
    if (_numbers.count == 1) // last operation was =. we need to reset _fully array
    {
        [_fullyNmubersAndArithmeticSignsSequence removeAllObjects];
        [_fullyNmubersAndArithmeticSignsSequence addObject:_numbers.lastObject];
    }
    double multyplicationNewNumberByPreviousNumberAmount = 0;
    double lastNumber = [_fullyNmubersAndArithmeticSignsSequence.lastObject doubleValue];
    lastNumber /= 100;
    [_fullyNmubersAndArithmeticSignsSequence replaceObjectAtIndex:(_fullyNmubersAndArithmeticSignsSequence.count - 1) withObject:[NSString stringWithFormat:@"%lf", lastNumber]];
    if (_fullyNmubersAndArithmeticSignsSequence.count == 1) //only one number
    {
        multyplicationNewNumberByPreviousNumberAmount = lastNumber;
    }
    else
    {
        multyplicationNewNumberByPreviousNumberAmount += lastNumber * [_fullyNmubersAndArithmeticSignsSequence[0]doubleValue];
        
        for (int index = 2; index < (_fullyNmubersAndArithmeticSignsSequence.count - 2); index+=2)
        {
            if ([_fullyNmubersAndArithmeticSignsSequence[index - 1] isEqual:@"+"])
            {
                multyplicationNewNumberByPreviousNumberAmount += lastNumber * [_fullyNmubersAndArithmeticSignsSequence[index]doubleValue];
            }
            else if ([_fullyNmubersAndArithmeticSignsSequence[index - 1] isEqual:@"-"])
            {
                multyplicationNewNumberByPreviousNumberAmount -= lastNumber * [_fullyNmubersAndArithmeticSignsSequence[index]doubleValue];
            }
            else if ([_fullyNmubersAndArithmeticSignsSequence[index - 1] isEqual:@"*"])
            {
                multyplicationNewNumberByPreviousNumberAmount *= lastNumber * [_fullyNmubersAndArithmeticSignsSequence[index]doubleValue];
            }
            else if ([_fullyNmubersAndArithmeticSignsSequence[index - 1] isEqual:@"/"])
            {
                multyplicationNewNumberByPreviousNumberAmount /= lastNumber * [_fullyNmubersAndArithmeticSignsSequence[index]doubleValue];
            }

        }
    }
    [_numbers replaceObjectAtIndex:(_numbers.count - 1) withObject:[NSString stringWithFormat:@"%lf", multyplicationNewNumberByPreviousNumberAmount]]; // _numbers last object gets the multyplications amount result
    [_fullyNmubersAndArithmeticSignsSequence replaceObjectAtIndex:(_numbers.count - 1) withObject:[NSString stringWithFormat:@"%lf", multyplicationNewNumberByPreviousNumberAmount]]; // _numbers last object gets the multyplications amount result
    
    [self adjustFontSizeToResultLength:multyplicationNewNumberByPreviousNumberAmount];
    
}


- (IBAction)addFractionToCurrentNumber:(id)sender {
    _isCurrentNumberFraction = YES;
    double lastNumber = [[_numbers lastObject]doubleValue];
    self.calculatorScreen.text = [NSString stringWithFormat:@"%g.",  lastNumber];
    [_numbers addObject:@0];
}


- (IBAction)cleanCalculatorScreen:(id)sender {
    UIButton *button = _ACButton;
    [button setTitle:@"AC" forState:UIControlStateNormal];

    [self adjustFontSizeToResultLength:0];
    [self.numbers removeAllObjects];
    [self.fullyNmubersAndArithmeticSignsSequence removeAllObjects];
    self.isNewNumber = YES;
}


- (IBAction)changeSign:(id)sender {
    if (!(_numbers.count == 0))
    {
        double oppositeSignNumber = [[self.numbers lastObject]doubleValue];
        oppositeSignNumber = oppositeSignNumber * (-1);
        [self.numbers removeLastObject];
        [self.numbers addObject:[NSString stringWithFormat:@"%lf", oppositeSignNumber]];
        [self.fullyNmubersAndArithmeticSignsSequence replaceObjectAtIndex:(_fullyNmubersAndArithmeticSignsSequence.count - 1) withObject:[NSString stringWithFormat:@"%lf", oppositeSignNumber]];
        [self adjustFontSizeToResultLength:oppositeSignNumber];
    }
}


- (IBAction)calculateAccordingToTheActionBeforeClickingCompare:(id)sender {
    if (!([_lastMathematicalOperaion isEqual:@"0"])) // its + - / * during consequtive pressing =
    {
        [_numbers addObject:_lastMathematicalOperaion];
        [_numbers addObject:_previousCalculationResult];
        [self calculateEquation];
    }
    else if ([[_numbers lastObject] isEqual:@"+"] || [[_numbers lastObject] isEqual:@"-"])
    {
        [self calculateEquationForLastPressingIsSubstractionOrAdditionCase];

    }
    else if ([[_numbers lastObject] isEqual:@"*"])
    {
        [self calculateEquationforLastPressingIsMultiplicationCase];

    }
    else if ([[_numbers lastObject] isEqual:@"/"])
    {
        [self calculateEquationForLastPressingIsDistributionCase];
    }

    else // last object in _numbers is number and not arithmetic value
    {
        if (_isCurrentNumberFraction == YES)
        {
            _isCurrentNumberFraction = NO;
            [_numbers removeLastObject];
            //[_fullyNmubersAndArithmeticSignsSequence removeLastObject]; // no "fraction place holder"
        }
        
        if (_numbers.count > 1) // at least one number and one mathematical operation
        {
            _lastMathematicalOperaion = [_numbers objectAtIndex:(_numbers.count - 2)];
            _previousCalculationResult = [_numbers objectAtIndex:(_numbers.count - 1)];
        }
        
        [self calculateEquation];
    }
}


-(void)calculateEquationForLastPressingIsSubstractionOrAdditionCase
{
    self.lastMathematicalOperaion = _numbers.lastObject;
    [_numbers removeLastObject];
    [self calculateEquation];
    self.previousCalculationResult = _calculatorScreen.text;
    [_numbers addObject:_lastMathematicalOperaion];
    [_numbers addObject:_previousCalculationResult];
    if ([[_numbers objectAtIndex:0] isEqual:@"+"] || [[_numbers objectAtIndex:0] isEqual:@"-"])
    {
        [_numbers insertObject:@"0" atIndex:0]; // in case of += or -= we need to add 0 first
    }
    [self calculateEquation];
}


- (void)calculateEquationforLastPressingIsMultiplicationCase
{
    self.lastMathematicalOperaion = @"*";
    [_numbers removeLastObject]; // remove * sign
    self.previousCalculationResult = [_numbers lastObject]; // the last number
    [_numbers removeLastObject]; // remove the last number
    if (_numbers.count == 0)
    {
        if (_previousCalculationResult == nil)
        {
            _previousCalculationResult = @"0"; // user entered *= only
        }
        [_numbers addObject:_previousCalculationResult];
    }
    else
    {
        [_numbers addObject:@"1"];
    }
    [self calculateEquation];
    [_numbers addObject:@"*"];
    [_numbers addObject:_previousCalculationResult];
    [self calculateEquation];
}


- (void)calculateEquationForLastPressingIsDistributionCase
{
    self.lastMathematicalOperaion = @"/";
    [_numbers removeLastObject]; // remove / sign
    self.previousCalculationResult = [_numbers lastObject];
    if (_numbers.count > 2)
    {
        NSString *mathematicalOperationBeforeLastNumber = [_numbers objectAtIndex:(_numbers.count - 2)];
        [_numbers addObject:mathematicalOperationBeforeLastNumber];
        [_numbers addObject:_previousCalculationResult];
        [self calculateEquation];
        //[_numbers addObject:_lastMathematicalOperaion];
        //[_numbers addObject:_previousCalculationResult];
        //[self calculateEquation];
    }
    else if (_previousCalculationResult == nil) // user entered /= only)
    {
        [_numbers addObject:@"0"];
        _previousCalculationResult = @"0";
    }
    [_numbers addObject:_lastMathematicalOperaion];
    [_numbers addObject:_previousCalculationResult];
    [self calculateEquation];
}


- (void)calculateEquation
{
    NSMutableArray *numbersCopy = _numbers;
    double result = [[numbersCopy lastObject]doubleValue] ;
    BOOL dividedByZero = NO;
    for (int index = 0; index < (_numbers.count - 1) && _numbers.count > 1; index++)
    {
        if ([_numbers[index] isEqual:@"/"])
        {
            if ([_numbers[index + 1]doubleValue] == 0.0)
            {
                dividedByZero = YES;
            }
        }
    }
    if (dividedByZero == NO)
    {
        result = [self calculateHighPrecedenceOperations:result];
        result = [self calculateLowPrecedenceOperations: result];
    }
    [self showResult:result OrNotANumber:dividedByZero];
}


- (double)calculateHighPrecedenceOperations:(double)result
{
    for (int index = 0; index < (_numbers.count - 1) && _numbers.count > 1; index++)
    {
        if ([_numbers[index] isEqual: @"*"] || [_numbers[index] isEqual: @"/"])
        {
            if ([_numbers[index] isEqual: @"*"])
            {
                result = [(_numbers[index - 1])doubleValue] * [(_numbers[index + 1])doubleValue];
            }
            else if ([_numbers[index] isEqual: @"/"])
            {
                    result = [(_numbers[index - 1])doubleValue] / [(_numbers[index + 1])doubleValue];
            }
            [_numbers insertObject:[NSString stringWithFormat:@"%lf", result] atIndex:(index + 2)];
            [_numbers removeObjectAtIndex:(index - 1)];
            [_numbers removeObjectAtIndex:(index - 1)];
            [_numbers removeObjectAtIndex:(index - 1)];
            index--; // equation has been shorter. risk of missing index
        }
    }
    return result;
}


- (double)calculateLowPrecedenceOperations:(double)result
{
    for (int index = 0; index < (_numbers.count - 1) && _numbers.count > 1; index++)
    {
        if ([_numbers[index] isEqual: @"+"] || [_numbers[index] isEqual: @"-"])
        {
            if ([_numbers[index] isEqual: @"+"])
            {
                result = [(_numbers[index - 1])doubleValue] + [(_numbers[index + 1])doubleValue];
            }
            else if ([_numbers[index] isEqual: @"-"])
            {
                result = [(_numbers[index - 1])doubleValue] - [(_numbers[index + 1])doubleValue];
            }
            [_numbers removeObjectAtIndex:(index - 1)];
            [_numbers removeObjectAtIndex:(index - 1)];
            [_numbers removeObjectAtIndex:(index - 1)];
            [_numbers insertObject:[NSString stringWithFormat:@"%lf", result] atIndex:(index - 1)];
            index--; // equation has been shorter. risk of missing index
        }
    }
    return result;
}


- (void)showResult:(double)result OrNotANumber:(BOOL)dividedByZero
{
    if (dividedByZero)
    {
        self.calculatorScreen.textAlignment = NSTextAlignmentCenter;
        [self.calculatorScreen setFont:[UIFont fontWithName:@"Arial" size:40]];
        self.calculatorScreen.text = [NSString stringWithFormat:@"Not a number"];
    }
    else
    {
        [self adjustFontSizeToResultLength:result];
    }
    NSLog(@"%lu", (unsigned long)_numbers.count);

    self.isNewNumber = YES;
}


- (void) adjustFontSizeToResultLength:(double)result
{
    NSString *calculatorScreenResult = [NSString stringWithFormat:@"%g", result];
    long int resultLength = calculatorScreenResult.length;
    
    long int fontSize = 0;
    if (resultLength <= 8)
    {
        fontSize = 70;
    }
    else
    {
        fontSize = 70 - (resultLength - 8) * 5;
        if (fontSize < 5)
        {
            fontSize = 5;
        }
    }
    [self.calculatorScreen setFont:[UIFont fontWithName:@"Arial" size:fontSize]];
    self.calculatorScreen.numberOfLines = 1;
    self.calculatorScreen.adjustsFontSizeToFitWidth = YES;
    self.calculatorScreen.minimumScaleFactor = 8;
    self.calculatorScreen.textAlignment = NSTextAlignmentRight;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.calculatorScreen.alpha = 0.5f;
        self.calculatorScreen.text = calculatorScreenResult;
        self.calculatorScreen.alpha = 1.0f;}];
}

@end
