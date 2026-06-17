# Account Type Screen Components

This document explains the reusable components created for the Account Type Screen.

## Components Created

### 1. AccountTypeController

**Location**: `lib/app/controllers/account_type_controller.dart`

A GetX controller that manages:

- Account type selection state
- Loading states
- Navigation logic
- Data persistence

**Usage**:

```dart
final controller = Get.put(AccountTypeController());

// Select account type
controller.selectAccountType(AccountType.salonOwner);

// Check if type is selected
bool isSelected = controller.isSelected(AccountType.salonOwner);

// Continue to next step
await controller.continueToNextStep();
```

### 2. AccountTypeScreen

**Location**: `lib/app/views/screens/account_type/account_type_screen.dart`

The main screen that displays account type selection options with:

- Clean header with title and description
- List of account type options
- Gradient continue button
- Responsive design using ScreenUtil

### 3. Reusable Widgets

**Location**: `lib/app/views/widgets/reusable/selection_widgets.dart`

#### SelectionCard

A reusable card widget for selection interfaces:

```dart
SelectionCard(
  title: 'Card Title',
  description: 'Card description',
  icon: IconContainer(icon: Icon(Icons.business)),
  isSelected: true,
  onTap: () => print('Selected'),
  showRecommended: true,
)
```

#### GradientButton

A reusable gradient button widget:

```dart
GradientButton(
  text: 'Continue',
  onPressed: () => print('Pressed'),
  isLoading: false,
)
```

#### IconContainer

A styled container for icons:

```dart
IconContainer(
  icon: Icon(Icons.business),
  backgroundColor: Colors.blue,
  iconColor: Colors.white,
)
```

## Features

### ✅ Clean Architecture

- Separation of concerns with dedicated controller
- Reusable components for future use
- Proper state management with GetX

### ✅ Responsive Design

- Uses flutter_screenutil for responsive scaling
- Adapts to different screen sizes

### ✅ Accessibility

- Proper semantic labeling
- High contrast colors
- Touch target sizes

### ✅ User Experience

- Smooth animations
- Visual feedback for selections
- Loading states
- Error handling with snackbars

### ✅ Design System

- Consistent with app's color scheme
- Follows Material Design 3 guidelines
- Reusable components maintain consistency

## Account Types Supported

1. **Salon Owner With Staff** - Recommended
   - Manages salon and team
   - Pink/primary color scheme
   - Business icon

2. **Self-Employed**
   - Freelance Hair Stylist
   - Blue color scheme
   - Person icon

3. **Salon Staff**
   - Works under salon account
   - Purple color scheme
   - Group icon

4. **Retailer**
   - Sells products to salons
   - Orange color scheme
   - Shopping cart icon

## Navigation Flow

1. User sees account type options
2. User selects their role
3. Selection is visually highlighted
4. Continue button becomes enabled
5. User taps continue
6. Loading state is shown
7. Account type is saved
8. User navigates to appropriate next screen

## Customization

### Colors

Account type colors can be customized in the `_getIconColor` and `_getIconBackgroundColor` methods.

### Icons

Icons can be changed in the `_getIconForAccountType` method.

### Account Types

New account types can be added by:

1. Adding to the `AccountType` enum
2. Adding to the `accountTypeOptions` list in the controller
3. Adding cases to the icon and color methods

## Testing

The controller includes methods that can be easily unit tested:

- `selectAccountType()`
- `isSelected()`
- `continueToNextStep()`

The UI components are stateless and can be widget tested independently.
