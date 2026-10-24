/// Short, in-app version of the Terms of Use in terms_and_conditions.md.
class TermsAndConditions {
  static const List<String> acceptanceOfTerm = [
    "By installing or using Self-Finance (the 'App'), you agree to these Terms. If you do not agree, do not use the App. The App is developed by Kamsali Vamshi Krishna.",
  ];

  static const List<String> userData = [
    "The App helps you record customer, loan, item, payment, and transaction information. Records are stored on your device and may be synchronized with Supabase cloud services when you sign in and use sync. See the Privacy Policy for details.",
    "You are responsible for maintaining copies of records you need. Export or sync information before uninstalling or changing devices. Contact sf.help.vamshi@gmail.com to request deletion of your account and associated cloud data.",
  ];

  static const List<String> userResponsibilities = [
    "You are responsible for the information and files you add, including having the rights and permissions required to use other people's personal information, photos, proof images, and signatures.",
    "Use the App lawfully, keep your device and account reasonably secure, check your records, and do not misuse or interfere with the App.",
  ];

  static const List<String> calculationAccuracy = [
    "The App is a recordkeeping and calculation tool, not a bank, lender, payment processor, or provider of legal, tax, or financial advice. Calculations depend on the information and settings you enter. Verify all amounts, dates, and documents before relying on or sharing them.",
  ];

  static const List<String> appUninstallation = [
    "You may stop using the App at any time. Local data may remain on your device until you delete it, clear app data, or uninstall the App. Cloud data deletion requests can be sent to sf.help.vamshi@gmail.com.",
  ];

  static const List<String> governingLaw = [
    "These Terms are governed by the laws of India, subject to any mandatory consumer protections that apply where you live.",
  ];

  static const List<String> changesToTerms = [
    "We may revise these Terms by publishing an updated version with a new effective date. Continued use after revised Terms take effect means you accept them, to the extent permitted by law.",
  ];

  static const List<String> contactInformation = [
    "For questions about these Terms or the Privacy Policy, contact Kamsali Vamshi Krishna at sf.help.vamshi@gmail.com.",
  ];

  static const Map<String, List<String>> termsAndConditionsMap = {
    "1. Acceptance of Terms": acceptanceOfTerm,
    "2. User Data and Cloud Sync": userData,
    "3. Your Responsibilities": userResponsibilities,
    "4. Calculations": calculationAccuracy,
    "5. Ending Use and Data": appUninstallation,
    "6. Governing Law": governingLaw,
    "7. Changes to Terms": changesToTerms,
    "8. Contact": contactInformation,
  };
}
