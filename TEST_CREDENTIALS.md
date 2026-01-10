# Test Credentials - Essivi Water

## Client Account
- **Username/Email**: `client@essivi.com`
- **Password**: `client123`
- **User Type**: Water Customer
- **Name**: Daniel Martinez
- **Location**: Colorado, USA
- **Subscription**: Monthly (20L bottles)

## Agent Account
- **Username/Email**: `agent@essivi.com`
- **Password**: `agent123`
- **User Type**: Water Delivery Agent
- **Name**: Jimmy Jordan
- **Rating**: 4.9 ⭐
- **Vehicle**: Water Delivery Truck

---

## How to Use

1. Launch the app
2. On the login screen, enter one of the credentials above
3. The app will automatically detect the user type based on the email:
   - If email contains "agent" → redirects to Agent Dashboard (Water Delivery Routes)
   - Otherwise → redirects to Client Home Screen (Water Orders)

## Notes
- These are mock credentials for testing purposes
- Authentication logic is in `lib/presentation/screens/auth/login_screen.dart`
- No actual backend validation is performed (simulated with 1-second delay)
- App context: **Water bottle delivery and distribution service**
