import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/text_styles.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/string.dart';
import '../view_models/requests_view_model.dart';
import '../models/user.dart' as model;
import '../widgets/molecules/request_card.dart';

class RequestsScreen extends StatelessWidget {
  final RequestsViewModel viewModel;

  const RequestsScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.customBlack,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: CustomColor.customBlack,
        surfaceTintColor: CustomColor.customBlack,
        title: Text(
          CustomString.requestsCapital,
          style: CustomTextStyle.bigBody1,
        ),
        leading: IconButton(
          icon: CustomIcon.arrowBack,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Divider(
            color: CustomColor.customDarkGrey,
            height: 1,
          ),
          Expanded(
            child: StreamBuilder<List<model.Request>>(
              stream: viewModel.requestsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      CustomString.errorLoadingRequests,
                      style: CustomTextStyle.body1,
                    ),
                  );
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return Center(
                    child: Text(
                      CustomString.noPendingRequests,
                      style: CustomTextStyle.body1,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: requests.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: CustomColor.customDarkGrey,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return RequestCard(
                      request: request,
                      onAccept: () => viewModel.acceptRequest(request.id),
                      onDeny: () => viewModel.denyRequest(request.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
