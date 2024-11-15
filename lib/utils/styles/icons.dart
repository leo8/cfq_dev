import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'colors.dart';

class CustomIcon extends StatelessWidget {
  final String assetName;
  final Color color;
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
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
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
  static const map = CustomIcon('map.svg');
  static const profile = CustomIcon('person_circle.svg');
  static const team = CustomIcon('team.svg');

  static const notifications = CustomIcon('bell.svg');
  static const inbox = CustomIcon('inbox.svg');

  //User
  static const statusOff = CustomIcon('moon.svg');
  static const statusOn = CustomIcon('disco.svg');
  static const userLocation = CustomIcon('location.svg');
  static const privateProfile = Icons.lock_outlined;

  //Teams
  static const addMember = CustomIcon('add_member.svg');
  static const leaveTeam = CustomIcon('leave_team.svg');
  static const heart = CustomIcon('heart.svg');

  //Events Forms
  static const eventTitle = CustomIcon('event_title.svg');
  static const eventOrganizer = CustomIcon('event_organizer.svg');
  static const eventMood = CustomIcon('event_mood.svg');
  static const eventLocation = CustomIcon('location_empty.svg');
  static const eventAddress = CustomIcon('address.svg');
  static const eventInvitees = CustomIcon('events_invitees.svg');

  //Events Cards
  static const eventConversation = CustomIcon('message.svg');
  static const followUp = CustomIcon('bell.svg');
  static const saveEmpty = CustomIcon('save_empty.svg');
  static const saveFull = CustomIcon('save_full.svg');
  static const attending = CustomIcon('turn_attending_icon_v2.svg');

  //Attending Status
  static const attendingStatusYes = CustomIcon('attending_status_yes.svg');
  static const attendingStatusMaybe = CustomIcon('attending_status_maybe.svg');
  static const attendingStatusNo = CustomIcon('attending_status_no.svg');

  //Moods
  static const streetMood = CustomIcon('street.svg');
  static const homeMood = CustomIcon('home_mood.svg');
  static const chillMood = CustomIcon('chill.svg');
  static const dinerMood = CustomIcon('diner.svg');
  static const barMood = CustomIcon('bar.svg');
  static const otherMood = CustomIcon('other.svg');
  static const clubMood = CustomIcon('club.svg');
  static const beforeMood = CustomIcon('before.svg');
  static const afterMood = CustomIcon('after.svg');
  static const concertMood = CustomIcon('concert.svg');

  //Parameters
  static const settings = Icons.settings;
  static const editProfile = CustomIcon('pencil.svg');
  static const confidentiality = Icons.lock;
  static const logOut = Icons.exit_to_app;
}
