/// Shared user-facing copy used across the Senda app.
///
/// Keep these values plain strings so they can be used in widgets, providers,
/// and error handling without depending on Flutter localization APIs.
class AppStrings {
  AppStrings._();

  static const appName = 'Senda';

  // Common actions
  static const continueAction = 'Continue';
  static const cancel = 'Cancel';
  static const confirm = 'Confirm';
  static const done = 'Done';
  static const back = 'Back';
  static const close = 'Close';
  static const save = 'Save';
  static const edit = 'Edit';
  static const retry = 'Try again';
  static const seeAll = 'See all';
  static const loading = 'Loading...';

  // Navigation
  static const home = 'Home';
  static const activity = 'Activity';
  static const pay = 'Pay';
  static const profile = 'Profile';

  // Authentication
  static const signIn = 'Sign in';
  static const signUp = 'Sign up';
  static const email = 'Email';
  static const password = 'Password';
  static const fullName = 'Full name';
  static const forgotPassword = 'Forgot password?';
  static const emailRequired = 'Enter your email address.';
  static const emailInvalid = 'Enter a valid email address.';
  static const passwordRequired = 'Enter your password.';
  static const passwordTooShort = 'Password must be at least 8 characters.';
  static const showPassword = 'Show password';
  static const hidePassword = 'Hide password';
  static const fullNameRequired = 'Enter your full name.';
  static const registrationFailed = 'Sorry, we are unable to register you.';
  static const loginFailed = 'Sorry, we are unable to log you in.';
  static const signInAgain = 'Please sign in again to continue.';

  // Wallet
  static const connectWallet = 'Connect your wallet';
  static const chooseWallet = 'Choose a wallet to get started.';
  static const disconnect = 'Disconnect';
  static const logOut = 'Log out';
  static const walletConnected = 'Wallet connected';

  // Payments and services
  static const sendMoney = 'Send Money';
  static const bankTransfer = 'Bank Transfer';
  static const airtime = 'Airtime';
  static const dataBundle = 'Data Bundle';
  static const electricity = 'Electricity';
  static const tvSubscription = 'TV Subscription';
  static const reviewPayment = 'Review Payment';
  static const confirmInWallet = 'Confirm in Wallet';
  static const processingPayment = 'Processing payment...';
  static const paymentSuccessful = 'Payment Successful!';
  static const paymentFailed = 'Payment failed. Please try again.';
  static const recentActivity = 'Recent activity';
  static const noActivity = 'No activity yet.';

  // Errors and network feedback
  static const genericError = 'Something went wrong. Please try again.';
  static const noInternetConnection =
      'Unable to connect. Check your internet connection and try again.';
  static const requestTimedOut = 'The request took too long. Please try again.';
  static const requestTimedOutCheckConnection =
      'The request took too long. Check your connection and try again.';
  static const unexpectedResponse =
      'We received an unexpected response. Please try again.';
  static const secureConnectionFailed =
      'A secure connection could not be established. Please try again.';
  static const requestCancelled = 'The request was cancelled.';
  static const permissionDenied = 'You do not have permission to do that.';
  static const informationNotFound =
      'The requested information could not be found.';
  static const tooManyRequests =
      'Too many requests. Please wait a moment and try again.';
  static const serviceUnavailable =
      'The service is temporarily unavailable. Please try again.';
  static const requestFailed =
      'We could not complete your request. Please try again.';
}
