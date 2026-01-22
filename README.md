# Self-Finance App

## Overview

The Self-Finance app is a mobile application specifically designed for shopkeepers and small finance companies. It offers secure data storage, calculates monthly interest, and provides offline capabilities. The app aims to simplify financial operations and enhance efficiency for its target users.

## Development Team

- **UI/UX Designer**: Sai Keerthi
- **Developers**: Vamshi and Akhilesh Kiran

## 📦 Builds (APK / IPA)

Precompiled application builds are available in the **GitHub Releases** section.

- 🔹 Android APK: [Download APK](https://github.com/dumbun/self-finance/releases/download/v2.3.0%2B0/app-release.apk)
- 🔹 iOS IPA: [Download IPA](https://github.com/dumbun/self-finance/releases/download/v2.3.0%2B0/sf.ipa)

> Note: Source code is available in this repository.  
> Binaries are provided for testing/demo purposes only.


The development team emphasizes thorough testing, effective project management, and collaboration among team members.

## Getting Started

### Prerequisites

To get started with the development or to run the project locally, ensure you have the following installed:

- Flutter SDK
- Dart SDK
- A suitable IDE (e.g., Android Studio, Visual Studio Code)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/dumbun/self-finance.git
   ```
2. Navigate to the project directory:
   ```bash
   cd self-finance
   ```
3. Install the required dependencies:
   ```bash
   flutter pub get
   ```

### Running the Application

To start the application on your device or emulator, run:

```bash
flutter run
```

## Database Structure

![Schema](https://github.com/dumbun/self-finance/assets/113350510/af4f60ae-9b55-434b-81c8-66cf0c17cc6a)

## Loan Calculator Class Overview

This `LoanCalculator` class is designed to perform basic loan calculations, helping users calculate the number of days between a loan's initiation date and a specified tenure date, as well as compute the interest accrued and the total payable amount. The class also provides useful information such as the number of months and remaining days for a loan, daily interest rate, and total interest to be paid.

## Features

The `LoanCalculator` offers the following capabilities:

- **Days Calculation**: Determine the number of days between the loan's starting date and a tenure end date (defaults to the current date if not provided).
- **Months and Days Calculation**: Convert the number of days into a readable format of months and remaining days.
- **Daily Interest Calculation**: Compute the daily interest rate based on the annual interest rate and the principal loan amount.
- **Total Interest Calculation**: Calculate the total interest accrued over the loan period.
- **Total Amount Calculation**: Determine the total amount payable by summing the loan principal and the total interest accrued.

## LoanCalculator Class Structure

### Properties

- `takenAmount`: The principal loan amount.
- `rateOfInterest`: The annual interest rate (in percentage).
- `takenDate`: The date the loan was taken in the format `"dd-MM-yyyy"`.
- `tenureDate`: The optional date representing the loan's tenure end. Defaults to the current date if not provided.

### Getter Properties

- `days`: The total number of days between the loan's start and end date.
- `monthsAndRemainingDays`: A formatted string showing the duration in months and days.
- `interestPerDay`: The interest accrued per day.
- `totalInterestAmount`: The total interest accrued.
- `totalAmount`: The total amount payable, including principal and interest.

### Methods

1. **`getDays()`**: Calculates the total number of days between the loan's start and end date (defaults to the current date if `tenureDate` is not provided).
2. **`daysToMonthsAndRemainingDays()`**: Converts the total number of days into months and remaining days.
3. **`getInterestPerDay()`**: Computes the daily interest rate by dividing the monthly interest rate by 30.
4. **`totalInterest()`**: Calculates the total interest accrued by multiplying the daily interest rate with the total number of days.
5. **`getTotal()`**: Returns the total payable amount by summing the loan principal and the total interest accrued.

### DateUtils Class

Contains a static method `getDaysDifference()` to calculate the difference in days between two dates.

## Interest Calculation Method

The code uses **simple interest** calculation. In simple interest, the interest is computed on the original loan amount (the principal) for the entire loan duration.

### Formula Used:

1. **Daily Interest Rate**:
   \[
   \text{Interest per day} = \frac{{\text{Principal} \times \left(\frac{{\text{Annual Interest Rate}}}{100}\right)}}{30}
   \]
   This formula calculates the interest generated per day by dividing the monthly interest (principal multiplied by the annual interest rate) by 30 days.
2. **Total Interest**:
   \[
   \text{Total Interest} = \text{Interest per day} \times \text{Total number of days}
   \]
   The total interest accrued over the loan period is the product of the daily interest rate and the total number of days the loan has been active.
3. **Total Amount Payable**:
   \[
   \text{Total Amount} = \text{Principal} + \text{Total Interest}
   \]
   The total amount payable is the sum of the loan's principal amount and the interest accrued over the period.

## Resources

This project is a starting point for a Flutter application. A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.

## Contributing

We welcome contributions! Please follow these steps to contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

If you have any questions or feedback, feel free to contact us at [vamsikrishna2644@gmail.com](mailto:vamsikrishna2644@gmail.com).

Enjoy using the Self-Finance app and happy managing your finances!
