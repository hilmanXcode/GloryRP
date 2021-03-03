/*
This file was generated by Nickk's TextDraw editor script
Nickk888 is the author of the NTD script
*/

//Variables
new Text:PublicTD[2];
new Text:Date;
new Text:speedo1;
new Text:Time;
new Text:HBEUANG;
new Text:HBESPEEDO;
new Text:Lapar;
new PlayerBar:Lapar[MAX_PLAYERS];
new PlayerBar:Haus[MAX_PLAYERS];

//Textdraws
Date = TextDrawCreate(107.000000, 425.000000, "30/Januari/2020");
TextDrawFont(Date, 1);
TextDrawLetterSize(Date, 0.275000, 1.649999);
TextDrawTextSize(Date, 400.000000, 17.000000);
TextDrawSetOutline(Date, 1);
TextDrawSetShadow(Date, 0);
TextDrawAlignment(Date, 3);
TextDrawColor(Date, -1);
TextDrawBackgroundColor(Date, 255);
TextDrawBoxColor(Date, 50);
TextDrawUseBox(Date, 0);
TextDrawSetProportional(Date, 1);
TextDrawSetSelectable(Date, 0);

speedo1 = TextDrawCreate(583.000000, 361.000000, "_");
TextDrawFont(speedo1, 1);
TextDrawLetterSize(speedo1, 0.600000, 9.599998);
TextDrawTextSize(speedo1, 654.000000, 264.500000);
TextDrawSetOutline(speedo1, 1);
TextDrawSetShadow(speedo1, 0);
TextDrawAlignment(speedo1, 2);
TextDrawColor(speedo1, -1);
TextDrawBackgroundColor(speedo1, 255);
TextDrawBoxColor(speedo1, 135);
TextDrawUseBox(speedo1, 1);
TextDrawSetProportional(speedo1, 1);
TextDrawSetSelectable(speedo1, 0);

Time = TextDrawCreate(606.000000, 32.000000, "20:20:20");
TextDrawFont(Time, 1);
TextDrawLetterSize(Time, 0.366665, 1.899999);
TextDrawTextSize(Time, 400.000000, 17.000000);
TextDrawSetOutline(Time, 1);
TextDrawSetShadow(Time, 0);
TextDrawAlignment(Time, 3);
TextDrawColor(Time, -1);
TextDrawBackgroundColor(Time, 255);
TextDrawBoxColor(Time, 50);
TextDrawUseBox(Time, 0);
TextDrawSetProportional(Time, 1);
TextDrawSetSelectable(Time, 0);

HBEUANG = TextDrawCreate(522.000000, 390.000000, "HUD:radar_burgershot");
TextDrawFont(HBEUANG, 4);
TextDrawLetterSize(HBEUANG, 0.600000, 2.000000);
TextDrawTextSize(HBEUANG, 17.000000, 17.000000);
TextDrawSetOutline(HBEUANG, 1);
TextDrawSetShadow(HBEUANG, 0);
TextDrawAlignment(HBEUANG, 1);
TextDrawColor(HBEUANG, -1);
TextDrawBackgroundColor(HBEUANG, 255);
TextDrawBoxColor(HBEUANG, 50);
TextDrawUseBox(HBEUANG, 1);
TextDrawSetProportional(HBEUANG, 1);
TextDrawSetSelectable(HBEUANG, 0);

HBESPEEDO = TextDrawCreate(522.000000, 418.000000, "HUD:radar_diner");
TextDrawFont(HBESPEEDO, 4);
TextDrawLetterSize(HBESPEEDO, 0.600000, 2.000000);
TextDrawTextSize(HBESPEEDO, 17.000000, 17.000000);
TextDrawSetOutline(HBESPEEDO, 1);
TextDrawSetShadow(HBESPEEDO, 0);
TextDrawAlignment(HBESPEEDO, 1);
TextDrawColor(HBESPEEDO, -1);
TextDrawBackgroundColor(HBESPEEDO, 255);
TextDrawBoxColor(HBESPEEDO, 50);
TextDrawUseBox(HBESPEEDO, 1);
TextDrawSetProportional(HBESPEEDO, 1);
TextDrawSetSelectable(HBESPEEDO, 0);

PublicTD[0] = TextDrawCreate(542.000000, 369.000000, "$20.00");
TextDrawFont(PublicTD[0], 1);
TextDrawLetterSize(PublicTD[0], 0.404166, 1.450000);
TextDrawTextSize(PublicTD[0], 400.000000, 17.000000);
TextDrawSetOutline(PublicTD[0], 1);
TextDrawSetShadow(PublicTD[0], 0);
TextDrawAlignment(PublicTD[0], 1);
TextDrawColor(PublicTD[0], 9109759);
TextDrawBackgroundColor(PublicTD[0], 255);
TextDrawBoxColor(PublicTD[0], 50);
TextDrawUseBox(PublicTD[0], 0);
TextDrawSetProportional(PublicTD[0], 1);
TextDrawSetSelectable(PublicTD[0], 0);

PublicTD[1] = TextDrawCreate(434.000000, 353.000000, "Preview_Model");
TextDrawFont(PublicTD[1], 5);
TextDrawLetterSize(PublicTD[1], 0.600000, 2.000000);
TextDrawTextSize(PublicTD[1], 112.500000, 99.000000);
TextDrawSetOutline(PublicTD[1], 0);
TextDrawSetShadow(PublicTD[1], 0);
TextDrawAlignment(PublicTD[1], 1);
TextDrawColor(PublicTD[1], -1);
TextDrawBackgroundColor(PublicTD[1], 0);
TextDrawBoxColor(PublicTD[1], 255);
TextDrawUseBox(PublicTD[1], 0);
TextDrawSetProportional(PublicTD[1], 1);
TextDrawSetSelectable(PublicTD[1], 0);
TextDrawSetPreviewModel(PublicTD[1], 0);
TextDrawSetPreviewRot(PublicTD[1], -10.000000, 0.000000, -20.000000, 1.000000);
TextDrawSetPreviewVehCol(PublicTD[1], 1, 1);

Lapar = TextDrawCreate(451.000000, 338.000000, "Nama_Player");
TextDrawFont(Lapar, 1);
TextDrawLetterSize(Lapar, 0.600000, 2.000000);
TextDrawTextSize(Lapar, 651.000000, -237.000000);
TextDrawSetOutline(Lapar, 1);
TextDrawSetShadow(Lapar, 0);
TextDrawAlignment(Lapar, 1);
TextDrawColor(Lapar, -1);
TextDrawBackgroundColor(Lapar, 255);
TextDrawBoxColor(Lapar, 139);
TextDrawUseBox(Lapar, 1);
TextDrawSetProportional(Lapar, 1);
TextDrawSetSelectable(Lapar, 0);


//Player Textdraws

/*Player Progress Bars
Requires "progress2" include by Southclaws
Download: https://github.com/Southclaws/progress2/releases */
Lapar[playerid] = CreatePlayerProgressBar(playerid, 546.000000, 394.000000, 89.000000, 11.500000, 9109759, 100.000000, 0);
SetPlayerProgressBarValue(playerid, Lapar[playerid], 50.000000);

Haus[playerid] = CreatePlayerProgressBar(playerid, 546.000000, 423.000000, 89.000000, 11.500000, 9109759, 100.000000, 0);
SetPlayerProgressBarValue(playerid, Haus[playerid], 50.000000);
