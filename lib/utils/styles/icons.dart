import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconData extends IconData {
  final String assetName;

  const CustomIconData(this.assetName) : super(0);
}

class CustomIcon {
  // SVG icons
  static const CustomIconData plusCircle = CustomIconData('plus_circle.svg');
  static const CustomIconData streetIcon = CustomIconData('street_icon.svg');
  static const CustomIconData homeParty = CustomIconData('home_party.svg');
  static const CustomIconData team = CustomIconData('team.svg');
  static const CustomIconData personCircle =
      CustomIconData('person_circle.svg');
  static const CustomIconData heart = CustomIconData('heart.svg');
  static const CustomIconData star = CustomIconData('star.svg');
  static const CustomIconData adress = CustomIconData('adress.svg');
  static const CustomIconData sunHorizon = CustomIconData('sun_horizon.svg');
  static const CustomIconData arrowRightCircle =
      CustomIconData('arrow_right_circle.svg');
  static const CustomIconData xmarkCircle = CustomIconData('xmark_circle.svg');
  static const CustomIconData disco = CustomIconData('disco.svg');
  static const CustomIconData forkKnife = CustomIconData('fork_knife.svg');
  static const CustomIconData beer = CustomIconData('beer.svg');
  static const CustomIconData partyPopper = CustomIconData('party_popper.svg');

  //Navigation
  static const arrowBack = Icons.arrow_back;
  static const arrowForward = Icons.arrow_forward_ios;
  static const close = Icons.close;

  //Auth
  static const visibilityOff = Icons.visibility_off;
  static const visibility = Icons.visibility;

  //General
  static const checkCircle = Icons.check_circle;
  static const add = Icons.add;
  static const search = Icons.search;

  //Image related
  static const addImage = Icons.add_a_photo;

  //Date related
  static const calendar = Icons.calendar_today;

  //Location related
  static const locationOn = Icons.location_on;

  //Nav Bar & Features
  static const CustomIconData home = CustomIconData('home.svg');
  static const map = Icons.location_on_outlined;
  static const profile = Icons.person_outlined;
  static const teams = Icons.groups_2_outlined;

  static const notifications = Icons.notifications;
  static const inbox = Icons.message;

  //User
  static const statusOff = Icons.nights_stay_outlined;
  static const statusOn = Icons.public;
  static const userLocation = Icons.location_on;
  static const privateProfile = Icons.lock;

  //Teams
  static const CustomIconData addMember = CustomIconData('add_member.svg');
  static const leaveTeam = Icons.exit_to_app;

  //Events Forms
  static const eventTitle = Icons.title;
  static const eventOrganizer = Icons.bolt;
  static const eventMood = Icons.mood;
  static const eventLocation = Icons.location_on;
  static const eventDescription = Icons.description;
  static const eventAddress = Icons.home;

  //Events Cards
  static const eventConversation = Icons.message;
  static const CustomIconData followUp = CustomIconData('bell.svg');
  static const share = Icons.share;

  //Moods

  //Parameters
  static const settings = Icons.settings;
  static const CustomIconData editProfile = CustomIconData('pencil.svg');
  static const confidentiality = Icons.lock;
  static const notificationsSettings = Icons.notifications;
  static const logOut = Icons.exit_to_app;

  //Methods
  static Widget getColoredIcon(String assetName, Color color) {
    // Method to get colorized icon
    return SvgPicture.asset(
      'assets/icons/$assetName.svg',
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  static Widget getSvgIcon(CustomIconData icon, {Color? color, double? size}) {
    // Method to get SvgPicture
    return SvgPicture.asset(
      'assets/icons/${icon.assetName}',
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      width: size,
      height: size,
    );
  }

  static Widget getIcon(IconData icon, {Color? color, double? size}) {
    // Method to get Icon (for use with IconData or CustomIconData)
    if (icon is CustomIconData) {
      return getSvgIcon(icon, color: color, size: size);
    } else {
      return Icon(icon, color: color, size: size);
    }
  }
}
