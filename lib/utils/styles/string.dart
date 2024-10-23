class CustomString {
  // Punctuation
  static const emptyString = "";
  static const space = " ";
  static const mark = ".";
  static const exclamationMark = "!";
  static const interrogationMark = "?";

  // General
  static const ok = "ok";
  static const cancel = "Annuler";
  static const add = "Ajouter";
  static const create = "Créer";
  static const done = "Terminé";
  static const success = "Succès";
  static const leave = "Quitter";
  static const orCapital = "OU";
  static const seeMore = "Voir plus";
  static const you = "Vous";
  static const newSingle = "nouveau";
  static const newPlural = "nouveaux";
  static const message = "message";
  static const messages = "messages";

  // Authentication
  static const logInCapital = "CONNEXION";
  static const signUpCapital = "INSCRIPTION";
  static const logIn = "Je me connecte";
  static const signUp = "Je m'inscris";
  static const alreadySignedUp = "Déjà inscrit(e) ?";
  static const noAccountYet = "T'as pas encore de compte ?";
  static const forgotPassword = "T'as oublié ton mot de passe ?";
  static const logOut = "Se déconnecter";

  // Authentication Form
  static const yourEmail = "Ton email";
  static const yourPassword = "Ton mot de passe";
  static const yourUsername = "Comment on t'appelle ?";
  static const yourLocation = "T'y es vers où le sang ?";
  static const yourBirthdate = "Ta date de naissance";

  // User Information
  static const username = "Nom d'utilisateur";
  static const noLocation = "Aucune localisation";

  // Messagerie
  static const messagerieCapital = "MESSAGERIE";
  static const addToMyMessages = "Ajouter à ma messagerie";
  static const removeFromMyMessages = "Retirer de ma messagerie";
  static const seeMembers = "Voir les membres";
  static const noConversationsYet = "Pas encore de conversations";

  // Search
  static const search = "Chercher..";
  static const searchUsers = "Chercher des utilisateurs..";
  static const searchFriends = "Chercher des amis..";
  static const noUsersFound = "Aucun utilisateur ne correspond à ta recherche.";
  static const userNotFound = "Utilisateur non trouvé";
  static const noResults = "Pas de résultats.";

  // Friends
  static const myFriends = "Mes amis";
  static const myFriendsCapital = "MES AMIS";
  static const noFriendsYet = "Vous n'avez pas encore d'amis";
  static const friendAdded = "Ami ajouté !";
  static const friendDeleted = "Ami supprimé !";
  static const addFriend = "Ajouter";
  static const removeFriend = "Retirer";

  // Teams
  static const team = "Team";
  static const myTeams = "Mes teams";
  static const myTeamsCapital = "MES TEAMS";
  static const noTeamsYet = "Vous n'avez pas encore de teams.";
  static const createTeam = "Créer une team";
  static const newTeamCapital = "NOUVELLE TEAM";
  static const teamName = "Donne-lui un nom";
  static const addFriends = "Ajoute tes amis";
  static const members = "Membres";
  static const addMembers = "Ajouter des membres";
  static const teamMembers = "Déjà membres..";
  static const otherFriends = "Ajouter..";
  static const leaveTeam = "Quitter l'équipe";
  static const sureToLeaveTeam =
      "Êtes-vous sûr de vouloir quitter cette team ?";

  // Events forms
  static const eventTitle = "Nom de l'évènement";
  static const organizedBy = "Organisé par";
  static const organizers = "Organisateurs";
  static const when = "Quand ?";
  static const date = "La date";
  static const where = "Où ? (un lieu, un nom, mets ce que tu veux)";
  static const who = "À qui ?";
  static const address = "L'adresse exacte";
  static const whatMood = "Quel(s) mood(s) ?";
  static const describeCfq = "Sois pertinent !";
  static const describeTurn = "Décris juste l'évent, raconte pas ta vie...";

  static const invitees = "T'invites qui ?";
  static const everybody = "Tout le monde";

  static const publier = "Publier";
  static const publicationReussie = "Publication réussie !";

  static const inviteesCapital = "INVITÉS";

  // Turns
  static const turnCapital = "TURN";
  static const createTurn = "Créer un Turn";
  static const turnName = "Nom du Turn";
  static const caTurn = "Ça turn";

  // CFQs
  static const cfqCapital = "CFQ";
  static const createCfq = "Créer un CFQ";
  static const cfqName = "Nom du CFQ";
  static const caFoutQuoi = "Ça fout quoi ?";

  // Feeds
  static const myPosts = "Mes posts";
  static const otherUserPosts = "Ses posts";
  static const myCalendar = "Mon calendrier";
  static const otherUserCalendar = "Son calendrier";

  // Parameters
  static const parameters = "Paramètres";
  static const parametersCapital = "PARAMÈTRES";
  static const editProfile = "Mon profil";
  static const myProfile = "Mon profil";
  static const myProfileCapital = "MON PROFIL";
  static const favorites = "Favoris";
  static const privacy = "Confidentialité";

  // Favorites
  static const favoritesCapital = "FAVORIS";
  static const noFavoriteEvents = "Pas encore de favoris";

  // Image Related
  static const noImage = "Aucune image";
  static const pickImageFromGallery = "Choisir une photo de la galerie";
  static const takePictureWithDevice = "Prendre une photo avec l'appareil";
  static const pleaseSelectAnImage = "Veuillez sélectionner une image";

  // Moods
  static const houseMood = "Maison";
  static const barMood = "Bar";
  static const clubMood = "Club";
  static const streetMood = "Street";
  static const turnMood = "Turn";
  static const chillMood = "Chill";
  static const dinerMood = "Dîner";
  static const beforeMood = "Before";
  static const afterMood = "After";

  // Success Messages
  static const successCreatingTeam = "Team créée avec succès !";
  static const successCreatingTurn = "Turn créé avec succès !";
  static const successCreatingCfq = "CFQ créé avec succès !";

  // Error Messages
  static const errorFetchingEvents =
      "Erreur lors de la récupération des évènements";
  static const failedToUpdateStatusPleaseTryAgain =
      "Erreur lors de la mise à jour du statut. Veuillez réessayer.";
  static const failedToPickImage =
      "Erreur lors du chargement de l'image. Veuillez réessayer.";
  static const failedToLoadMap = "Erreur lors du chargement de la map..";
  static const failedToUploadProfilePicture =
      "Erreur lors de l'upload de la photo de profil. Veuillez réessayer.";
  static const someErrorOccurred = "Une erreur s'est produite";
  static const veuillezRemplirTousLesChamps =
      "Veuillez remplir tous les champs";
  static const pleaseFillAllRequiredFields =
      "Veuillez remplir tous les champs requis";
  static const fetchingDataNoEventsYet =
      "Récupération des données, pas d'évènements pour le moment...";
  static const noEventsAvailable = "Aucun évènement disponible";
  static const errorLeavingTeam = "Erreur lors de la sortie de la team";
  static const errorCreatingTeam = "Erreur lors de la création de la Team..";
  static const errorCreatingTurn = "Erreur lors de la création du Turn..";
  static const errorCreatingCfq = "Erreur lors de la création du CFQ..";
  static const pleaseSelectAtLeastOneMood =
      "Veuillez sélectionner au moins un mood";
  static const failedToInitializeUserData =
      "Échec de l'initialisation des données utilisateur";
  static const failedToFetchUserTeams =
      "Échec de la récupération des teams de l'utilisateur";
  static const failedToPerformSearch = "Échec de la recherche";
  static const pleaseSelectDateAndTime =
      "Veuillez sélectionner une date et une heure";
  static const pleaseEnterTeamName = "Veuillez entrer un nom d'équipe";
  static const pleaseSelectAtLeastOneMember =
      "Veuillez sélectionner au moins un membre";
  static const failedToFetchFriends =
      "Échec de la récupération des amis. Veuillez réessayer.";
  static const failedToRemoveFriend =
      "Échec de la suppression de l'ami. Veuillez réessayer.";
  static const pleaseFillInAllRequiredFields =
      "Veuillez remplir tous les champs";

  // Utils
  static const thisIsWeb = "C'est web";

  // New strings for followers and attendees
  static const noFollowersYet = "Pas encore de followers";
  static const onePersonFollows = "personne suit";
  static const peopleFollow = "personnes suivent";
  static const noAttendeesYet = "Pas encore de participant";
  static const onePersonAttending = "personne participe";
  static const peopleAttending = "personnes participent";
}
