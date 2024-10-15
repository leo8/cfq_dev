import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'colors.dart';

class CustomIcon extends StatelessWidget {
  final String assetName;
  final Color? color;
  final double size;

  const CustomIcon(
    this.assetName, {
    super.key,
    this.color = CustomColor.customWhite,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$assetName',
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      width: size,
      height: size,
    );
  }

  CustomIcon copyWith({Color? color, double? size}) {
    return CustomIcon(
      assetName,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }

  //Navigation
  static const arrowBack = CustomIcon('arrow_left.svg');
  static const arrowForward = CustomIcon('arrow_right_circle.svg');
  static const close = CustomIcon('xmark.svg');

  //Auth
  static const visibilityOff = Icons.visibility_off;
  static const visibility = Icons.visibility;

  //General
  static const checkCircle = CustomIcon('xmark_circle.svg');
  static const add = CustomIcon('plus.svg');
  static const search = CustomIcon('magnifying_glass.svg');
  static const plusCircle = CustomIcon('plus_circle.svg');

  //Image related
  static const addImage = CustomIcon('photo.svg');

  //Date related
  static const calendar = CustomIcon('calendar.svg');

  //Nav Bar & Features
  static const home = CustomIcon('home.svg');
  static const map = CustomIcon('location.svg');
  static const profile = CustomIcon('person_circle.svg');
  static const team = CustomIcon('team.svg');

  static const notifications = CustomIcon('bell.svg');
  static const inbox = CustomIcon('message.svg');

  //User
  static const statusOff = CustomIcon('moon.svg');
  static const statusOn = CustomIcon('disco.svg');
  static const userLocation = CustomIcon('location.svg');
  static const privateProfile = Icons.lock;

  //Teams
  static const addMember = CustomIcon('add_member.svg');
  static const leaveTeam = CustomIcon('open_door.svg');

  //Events Forms
  static const eventTitle = CustomIcon('pencil.svg');
  static const eventOrganizer = CustomIcon('bolt.svg');
  static const eventMood = CustomIcon('moon2.svg');
  static const eventLocation = CustomIcon('location.svg');
  static const eventAddress = CustomIcon('address.svg');
  static const eventInvitees = CustomIcon('person.svg');

  //Events Cards
  static const eventConversation = CustomIcon('message.svg');
  static const followUp = CustomIcon('bell.svg');
  static const favorite = CustomIcon('heart.svg');

  //Moods
  static const streetIcon = CustomIcon('street_icon.svg');
  static const homeParty = CustomIcon('home_party.svg');
  static const sunHorizon = CustomIcon('sun_horizon.svg');
  static const forkKnife = CustomIcon('fork_knife.svg');
  static const beer = CustomIcon('beer.svg');
  static const partyPopper = CustomIcon('party_popper.svg');

  //Parameters
  static const settings = Icons.settings;
  static const editProfile = CustomIcon('pencil.svg');
  static const confidentiality = Icons.lock;
  static const logOut = Icons.exit_to_app;
}
