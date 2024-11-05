import 'package:flutter/material.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/text_styles.dart';
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
        backgroundColor: CustomColor.customBlack,
        title: Text(
          'Demandes',
          style: CustomTextStyle.body1Bold,
        ),
      ),
      body: StreamBuilder<List<model.Request>>(
        stream: viewModel.pendingRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur de chargement des demandes',
                style: CustomTextStyle.body1,
              ),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Text(
                'Pas de demandes en attente',
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
    );
  }
}
