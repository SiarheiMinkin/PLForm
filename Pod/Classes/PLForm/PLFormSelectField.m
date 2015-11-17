//
//  PLFormSelectField.m
//  PLForm
//
//  Created by Ash Thwaites on 11/12/2015.
//  Copyright (c) 2015 Pitch Labs. All rights reserved.
//


#import "PLFormSelectField.h"
#import "PureLayout.h"
#import "PLExtras-UIView.h"

@implementation PLFormSelectFieldElement

+ (id)selectElementWithID:(NSInteger)elementID title:(NSString *)title values:(NSArray*)values delegate:(id<PLFormElementDelegate>)delegate;
{
    PLFormSelectFieldElement *element = [super elementWithID:elementID delegate:delegate];
    element.title = title;
    element.values = values;
    element.index = -1;
    element.originalIndex = -1;
    return element;
}

+ (id)selectElementWithID:(NSInteger)elementID title:(NSString *)title values:(NSArray*)values index:(NSInteger)index delegate:(id<PLFormElementDelegate>)delegate;
{
    PLFormSelectFieldElement *element = [self selectElementWithID:elementID title:title values:values delegate:delegate];
    element.index = index;
    element.originalIndex = index;
    return element;
}

+ (id)selectElementWithID:(NSInteger)elementID title:(NSString *)title values:(NSArray*)values index:(NSInteger)index insertBlank:(BOOL)insertBlank delegate:(id<PLFormElementDelegate>)delegate;
{
    PLFormSelectFieldElement *element = [super elementWithID:elementID delegate:delegate];
    element.title = title;
    element.values = values;
    element.index = -1;
    element.originalIndex = -1;
    element.insertBlank = insertBlank;
    return element;
}

-(NSString*)valueAsString
{
    if ((self.index >=0) && (self.index < self.values.count))
        return [self.values objectAtIndex:self.index];
    return nil;
}

@end


@interface PLFormSelectField ()
{
    UITapGestureRecognizer *insideTapGestureRecognizer;
    UITapGestureRecognizer *outsideTapGestureRecognizer;
}

@property (nonatomic, readwrite) UITextField *textfield;
@property (nonatomic, readwrite) UILabel *titleLabel;
@property (nonatomic, readwrite) UILabel *valueLabel;
@property (nonatomic, readwrite) UIPickerView *pickerView;

@end


@implementation PLFormSelectField

-(void)setup
{
    [super setup];
    
    // create the value label
    // create the value label
    _valueLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _valueLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_valueLabel];
    
    // create a title label
    _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_titleLabel];
    
    // hidden textfield to trigger the picker...
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.delegate = self;
    _pickerView.showsSelectionIndicator = YES;

    _textfield = [[UITextField alloc] initWithFrame:self.bounds];
    _textfield.hidden = YES;
    [_textfield setInputView:_pickerView];
    [self addSubview:_textfield];

    _contentInsets = UIEdgeInsetsMake(2, 10, 2, 10);
    
    insideTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapInside:)];
    [self addGestureRecognizer:insideTapGestureRecognizer];
    outsideTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOutside:)];
}

- (BOOL)canBecomeFirstResponder
{
    return [_textfield canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [_textfield becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    UIWindow *frontWindow = [[UIApplication sharedApplication] keyWindow];
    [frontWindow removeGestureRecognizer:outsideTapGestureRecognizer];
    return [_textfield resignFirstResponder];
}


// attributes
-(void)setFont:(UIFont *)font
{
    _titleLabel.font = font;
}

-(UIFont*)font
{
    return _titleLabel.font;
}

-(void)setTextColor:(UIColor *)color
{
    _titleLabel.textColor = color;
}

-(UIColor *)textColor
{
    return _titleLabel.textColor;
}

-(void)setValueFont:(UIFont *)font
{
    _valueLabel.font = font;
}

-(UIFont*)valueFont
{
    return _valueLabel.font;
}

-(void)setValueColor:(UIColor *)color
{
    _valueLabel.textColor = color;
}

-(UIColor *)valueColor
{
    return _valueLabel.textColor;
}

-(void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

-(NSString*)title
{
    return _titleLabel.text;
}


// handle constraints

-(void)removeInsetConstraints
{
    [self removeConstraintsForView:_titleLabel];
    [self removeConstraintsForView:_valueLabel];
    [self setNeedsUpdateConstraints];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    [self removeInsetConstraints];
}

- (void)updateConstraints
{
    if (![self hasConstraintsForView:_valueLabel])
    {
        [_valueLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:_contentInsets.left];
        [_valueLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:_contentInsets.right];
        [_valueLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:0];
    }
    
    if (![self hasConstraintsForView:_titleLabel])
    {
        [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:_contentInsets.left];
        [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:_contentInsets.right];
        [_titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:0];
    }
    
    [super updateConstraints];
}

-(void)dealloc
{
    [self resignFirstResponder];
}


-(void)updateWithElement:(PLFormSelectFieldElement*)element
{
    self.element = element;
    self.title = element.title;
    self.valueLabel.text = [element valueAsString];
}

- (void)onTapInside:(UIGestureRecognizer*)sender
{
    [_textfield becomeFirstResponder];
    UIWindow *frontWindow = [[UIApplication sharedApplication] keyWindow];
    [frontWindow addGestureRecognizer:outsideTapGestureRecognizer];
}

- (void)onTapOutside:(UIGestureRecognizer*)sender
{
    [_textfield resignFirstResponder];
    [sender.view removeGestureRecognizer:outsideTapGestureRecognizer];
    if ([self.element.delegate respondsToSelector:@selector(formElementDidEndEditing:)])
    {
        [(id<PLFormElementDelegate>)self.element.delegate formElementDidEndEditing:self.element];
    }
}



#pragma mark -
#pragma mark Picker view data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger adjustedRow = (_element.insertBlank) ? row-1:row;
    _valueLabel.text = (adjustedRow<0) ? nil : _element.values[adjustedRow];
    _element.index = adjustedRow;

    if ([_element.delegate respondsToSelector:@selector(formElementDidChangeValue:)])
    {
        [(id<PLFormElementDelegate>)_element.delegate formElementDidChangeValue:_element];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return (_element.insertBlank) ? _element.values.count+1:_element.values.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    NSInteger adjustedRow = (_element.insertBlank) ? row-1:row;
    return (adjustedRow<0) ? @"" : _element.values[adjustedRow];
}


@end
