import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/favorites_view_model.dart';
import '../widgets/organisms/events_list.dart';
import '../utils/styles/colors.dart';
import '../utils/styles/string.dart';
import '../utils/styles/icons.dart';
import '../utils/styles/text_styles.dart';

class FavoritesScreen extends StatelessWidget {
  final String currentUserId;

  const FavoritesScreen({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritesViewModel(currentUserId: currentUserId),
      child: Scaffold(
        backgroundColor: CustomColor.customBlack,
        appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: CustomColor.customBlack,
          leading: IconButton(
            icon: CustomIcon.arrowBack,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 15),
            Center(
              child: Text(
                CustomString.favoritesCapital,
                style: CustomTextStyle.body1.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Consumer<FavoritesViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (viewModel.favoriteEvents.isEmpty) {
                    return Center(
                      child: Text(
                        CustomString.noFavoriteEvents,
                        style: CustomTextStyle.body1,
                      ),
                    );
                  } else {
                    return EventsList(
                      eventsStream: Stream.value(viewModel.favoriteEvents),
                      currentUser: viewModel.currentUser,
                      onFavoriteToggle: viewModel.toggleFavorite,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
