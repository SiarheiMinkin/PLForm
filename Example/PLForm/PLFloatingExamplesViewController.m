//
//  BBViewController.m
//  PLForm
//
//  Created by Ash Thwaites on 11/12/2015.
//  Copyright (c) 2015 Ash Thwaites. All rights reserved.
//


#import "PLFloatingExamplesViewController.h"
#import "PLFloatingLabelDateField.h"
#import "PLFloatingLabelSelectField.h"
#import "PLFloatingLabelTextField.h"
#import "PLFloatingLabelTextView.h"
#import "PLFloatingLabelAutoCompleteField.h"
#import "PLFormValidator.h"

@interface PLFloatingExamplesViewController () <PLFormElementDelegate>
{
    PLFormTextFieldElement *textFieldElement;
    PLFormSelectFieldElement *selectFieldElement;
    PLFormDateFieldElement *dateFieldElement;
    PLFormTextViewElement *textViewElement;
    PLFormAutoCompleteFieldElement *autoCompleteElement;
}

@property (nonatomic, strong) IBOutlet PLFloatingLabelDateField *dateField;
@property (nonatomic, strong) IBOutlet PLFloatingLabelSelectField *selectField;
@property (nonatomic, strong) IBOutlet PLFloatingLabelTextField *textField;
@property (nonatomic, strong) IBOutlet PLFloatingLabelTextView *textView;
@property (nonatomic, strong) IBOutlet PLFloatingLabelAutoCompleteField *autoTextField;

@end

@implementation PLFloatingExamplesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    textFieldElement = [PLFormTextFieldElement textInputElementWithID:0 placeholderText:@"Question" value:nil delegate:self];
    selectFieldElement = [PLFormSelectFieldElement selectElementWithID:1 title:@"Select Option" values:@[@"1 minute",@"5 minutes",@"15 minutes",@"1 hour"] index:0 insertBlank:YES delegate:self];
    dateFieldElement = [PLFormDateFieldElement datePickerElementWithID:2 title:@"Enter a date" date:nil datePickerMode:UIDatePickerModeDate delegate:nil];
    textViewElement = [PLFormTextViewElement textViewElementWithID:3 placeholderText:@"Enter some text" value:nil delegate:nil];
    autoCompleteElement = [PLFormAutoCompleteFieldElement selectElementWithID:1 labelText:@"Select Option" values:@[@"Dog",@"Cat",@"Rabbity Rabbit",@"Horse",@"Dog",@"Cat",@"Rabbit",@"Horse",@"Dog",@"Cat",@"Rabbit",@"Horse"] delegate:self];
    autoCompleteElement.displayAllWhenBlank = YES;
    autoCompleteElement.indexRequired = YES;

    if (self.prePopulate)
    {
        textFieldElement.value = @"Some text";
        selectFieldElement.index = 1;
        dateFieldElement.date = [NSDate date];
        textViewElement.value = @"A longer piece of text";
        autoCompleteElement.index = 1;
    }
    
    [_textField updateWithElement:textFieldElement];
    [_selectField updateWithElement:selectFieldElement];
    [_dateField updateWithElement:dateFieldElement];
    [_textView updateWithElement:textViewElement];
    [_autoTextField updateWithElement:autoCompleteElement];

    PLConditionPresent *presentCondition = [[PLConditionPresent alloc] initWithLocalizedViolationString:NSLocalizedString(@"Please complete all fields", @"Please complete all fields")];
    textFieldElement.validator = [[PLValidator alloc] initWithCondition:presentCondition,nil];
    selectFieldElement.validator = [[PLValidator alloc] initWithCondition:presentCondition,nil];
    dateFieldElement.validator = [[PLValidator alloc] initWithCondition:presentCondition,nil];
    textViewElement.validator = [[PLValidator alloc] initWithCondition:presentCondition,nil];
    autoCompleteElement.validator = [[PLValidator alloc] initWithCondition:presentCondition,nil];
    
    self.formModel = @[textFieldElement, selectFieldElement, dateFieldElement, textViewElement, autoCompleteElement];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // create the model
}
@end
