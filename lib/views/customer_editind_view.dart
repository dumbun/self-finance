import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customer_contacts_provider.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/providers/items_provider.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/views/contact_details_view.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class ContactEditingView extends ConsumerWidget {
  const ContactEditingView({super.key, required this.contact});
  final Customer contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController customerName = TextEditingController(text: contact.name);
    final TextEditingController gaurdianName = TextEditingController(text: contact.guardianName);
    final TextEditingController address = TextEditingController(text: contact.address);
    final TextEditingController mobileNumber = TextEditingController(text: contact.number);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Row buildImagePickers() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(14.sp),
              child: Consumer(
                builder: (context, ref, child) {
                  final updateCustomerPhoto = ref.watch(updatedCustomerPhotoStringProvider);
                  return GestureDetector(
                    onTap: () async {
                      try {
                        await pickImageFromCamera().then((value) {
                          if (value != "" && value.isNotEmpty) {
                            ref.read(updatedCustomerPhotoStringProvider.notifier).update((state) => value);
                          }
                        });
                      } catch (e) {
                        //
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        updateCustomerPhoto.isNotEmpty
                            ? Utility.imageFromBase64String(updateCustomerPhoto)
                            : const DefaultUserImage(),
                        SizedBox(height: 12.sp),
                        const BodyOneDefaultText(text: "Customer Photo"),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(14.sp),
              child: Consumer(
                builder: (context, ref, child) {
                  final updateProofPhoto = ref.watch(updatedCustomerProofStringProvider);
                  return GestureDetector(
                    onTap: () async {
                      try {
                        final value = await pickImageFromCamera();
                        if (value != "" && value.isNotEmpty) {
                          ref.read(updatedCustomerProofStringProvider.notifier).update((state) => value);
                        }
                      } catch (e) {
                        //
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        updateProofPhoto.isNotEmpty
                            ? Utility.imageFromBase64String(updateProofPhoto)
                            : const DefaultUserImage(),
                        SizedBox(height: 12.sp),
                        const BodyOneDefaultText(text: "Customer Proof"),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    void navigateToDetailsView(List<Customer> customer, List<Items> customerItems, List<Trx> customerTransactions) {
      Routes.navigateToContactDetailsView(
        context,
        customer: customer.first,
        items: customerItems,
        transacrtions: customerTransactions,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: BodyOneDefaultText(text: contact.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(18.sp),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.sp),
                  InputTextField(
                    controller: customerName,
                    hintText: "ustomer Name",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    controller: mobileNumber,
                    hintText: "Contact Number",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    controller: gaurdianName,
                    hintText: "Guardian Name",
                  ),
                  SizedBox(height: 20.sp),
                  InputTextField(
                    controller: address,
                    hintText: "Address",
                  ),
                  SizedBox(height: 20.sp),
                  buildImagePickers(),
                  SizedBox(height: 32.sp),
                  RoundedCornerButton(
                    text: "update",
                    onPressed: () {
                      ref.read(asyncCustomersContactsProvider.notifier).updateCustomer(
                            customerId: contact.id!,
                            newCustomerName: customerName.text,
                            newGuardianName: gaurdianName.text,
                            newCustomerAddress: address.text,
                            newContactNumber: mobileNumber.text,
                            newCustomerPhoto: ref.read(updatedCustomerPhotoStringProvider),
                            newProofPhoto: ref.read(updatedCustomerProofStringProvider),
                            newCreatedDate: DateTime.now().toString(),
                          );

                      Routes.navigateToContactsView(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
