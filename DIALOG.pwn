//----------------[ Dialog System ]--------------

//----------[ Dialog Login Register]----------
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	printf("[OnDialogResponse]: %s(%d) has used dialog id: %d Listitem: %d", pData[playerid][pName], playerid, dialogid, listitem);
	if(dialogid == DIALOG_LOGIN_TWEET) // Login Tweetter
	{
	    if(response)
	    {
	        for(new i = 1; i < MAX_TWEETS; i++)
	        {
		        if(strcmp(inputtext, pTweet[i][pNameAccountTwt]) == pTweet[i][pNameAccountTwt])
		        {
		            ShowPlayerDialog(playerid, 123, DIALOG_STYLE_PASSWORD, "Login Tweetter.", "Silahkan Masukkan Password Anda.", "Enter", "Cancel");
				}
			}
		}
	}
	if(dialogid == 123) // Login Tweetter
	{
	    if(response)
	    {
	        for(new i = 1; i < MAX_TWEETS; i++)
	        {
		        if(strcmp(inputtext, pTweet[i][pPasswordAccountTwt]) == pTweet[i][pPasswordAccountTwt])
		        {
		            pData[playerid][pLoggedAccountTwt] = 1;
				}
			}
		}
	}
	if(dialogid == DIALOG_MENU_TWEET) // Menu Tweetter
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
				{
				    ShowPlayerDialog(playerid, DIALOG_LOGIN_TWEET, DIALOG_STYLE_INPUT, "Login Tweetter.", "Silahkan Masukkan Nama Tweetter Anda.", "Submit", "Close");
				}
				case 1:
				{
				    ShowPlayerDialog(playerid, DIALOG_REGISTER_TWEET, DIALOG_STYLE_INPUT, "Register Tweetter.", "Silahkan Isi Nama Anda Disini", "Enter", "Cancel");
				}
				case 2:
				{
				    ShowPlayerDialog(playerid, DIALOG_RESET_PWTWEET, DIALOG_STYLE_INPUT, "Reset Password Tweetter.", "Silahkan Masukkan Nama Tweet Anda.", "Enter", "Cancel");
				}
			}
		}
	}
	if(dialogid == DIALOG_REGISTER_TWEET) // Register Tweetter
	{
	    if(response)
	    {
            for(new i = 1; i < MAX_TWEETS; i++)
            {
				format(pTweet[i][pNameAccountTwt], 50, inputtext);
			}
		    ShowPlayerDialog(playerid, 212, DIALOG_STYLE_PASSWORD, "Register Tweetter", "Masukkan Kata Sandi yang di inginkan.", "Enter", "Cancel");
		    SaveDataTweets();
		}
	}
	if(dialogid == 212) // Register Tweetter
	{
	    if(response)
	    {
	        new Account[250];
	        for(new i = 1; i < MAX_TWEETS; i++)
	        {
		        format(pTweet[i][pPasswordAccountTwt], 100, inputtext);
				format(Account, sizeof(Account), "Nama Tweetter Anda : %s\nPassword Tweetter Anda : %s", pTweet[i][pNameAccountTwt], pTweet[i][pPasswordAccountTwt]);
			}
			ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_MSGBOX, "Informasi Account Tweetter Anda", Account, "OKE", "");
			Info(playerid, "Silahkah /tweet lagi untuk login twetter");
			SaveDataTweets();
		}
	}
    if(dialogid == DIALOG_LOGIN)
    {
        if(!response) return Kick(playerid);

		new hashed_pass[65];
		SHA256_PassHash(inputtext, pData[playerid][pSalt], hashed_pass, 65);

		if (strcmp(hashed_pass, pData[playerid][pPassword]) == 0)
		{
			new query[512], query1[512];
			mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM `players` WHERE `username` = '%e' LIMIT 1", pData[playerid][pName]);
			mysql_pquery(g_SQL, query, "AssignPlayerData", "d", playerid);
			printf("[LOGIN] %s(%d) has successfully login with password(%s)", pData[playerid][pName], playerid, inputtext);
			
			
			mysql_format(g_SQL, query1, sizeof(query1), "INSERT INTO loglogin (username,reg_id,password,time) VALUES('%s','%d','%s',CURRENT_TIMESTAMP())", pData[playerid][pName], pData[playerid][pID], inputtext);
			mysql_tquery(g_SQL, query1);
			/*//ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Login", "You have been successfully logged in.", "Okay", "");
			printf("[LOGIN] %s(%d) telah sukses login dengan password(%s)", pData[playerid][pName], playerid, inputtext);
			cache_set_active(pData[playerid][Cache_ID]);

			AssignPlayerData(playerid);

			cache_delete(pData[playerid][Cache_ID]);
			pData[playerid][Cache_ID] = MYSQL_INVALID_CACHE;

			KillTimer(pData[playerid][LoginTimer]);
			pData[playerid][LoginTimer] = 0;
			pData[playerid][IsLoggedIn] = true;

			SetSpawnInfo(playerid, NO_TEAM, pData[playerid][pSkin], pData[playerid][pPosX], pData[playerid][pPosY], pData[playerid][pPosZ], pData[playerid][pPosA], 0, 0, 0, 0, 0, 0);
			SpawnPlayer(playerid);*/
		}
		else
		{
			pData[playerid][LoginAttempts]++;

			if (pData[playerid][LoginAttempts] >= 3)
			{
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Login", "You have mistyped your password too often (3 times).", "Okay", "");
				KickEx(playerid);
			}
			else ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Wrong password!\nPlease enter your password in the field below:", "Login", "Abort");
		}
        return 1;
    }
	if(dialogid == DIALOG_REGISTER)
    {
		if (!response) return Kick(playerid);
	
		if (strlen(inputtext) <= 5) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", "Your password must be longer than 5 characters!\nPlease enter your password in the field below:", "Register", "Abort");
		
		if(!IsValidPassword(inputtext))
		{
			Error(playerid, "Password can contain only A-Z, a-z, 0-9, _, [ ], ( )");
			ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", "Your password must be valid characters!\nPlease enter your password in the field below:", "Register", "Abort");
			return 1;
		}
		
		for (new i = 0; i < 16; i++) pData[playerid][pSalt][i] = random(94) + 33;
		SHA256_PassHash(inputtext, pData[playerid][pSalt], pData[playerid][pPassword], 65);

		new query[842], PlayerIP[16];
		GetPlayerIp(playerid, PlayerIP, sizeof(PlayerIP));
		mysql_format(g_SQL, query, sizeof query, "INSERT INTO `players` (`username`, `password`, `salt`, `ip`, `reg_date`, `last_login`) VALUES ('%e', '%s', '%e', '%s', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())", pData[playerid][pName], pData[playerid][pPassword], pData[playerid][pSalt], PlayerIP);
		mysql_tquery(g_SQL, query, "OnPlayerRegister", "i", playerid);
		return 1;
	}
	if(dialogid == DIALOG_AGE)
    {
		if(!response) return ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Tanggal Lahir", "Masukan tanggal lahir (Tgl/Bulan/Tahun): 15/04/1998", "Pilih", "Batal");
		if(response)
		{
			new
				iDay,
				iMonth,
				iYear,
				day,
				month,
				year;
				
			getdate(year, month, day);

			static const
					arrMonthDays[] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

			if(sscanf(inputtext, "p</>ddd", iDay, iMonth, iYear)) {
				ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Tanggal Lahir", "Error! Invalid Input\nMasukan tanggal lahir (Tgl/Bulan/Tahun): 15/04/1998", "Pilih", "Batal");
			}
			else if(iYear < 1900 || iYear > year) {
				ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Tahun Lahir", "Error! Invalid Input\nMasukan tanggal lahir (Tgl/Bulan/Tahun): 15/04/1998", "Pilih", "Batal");
			}
			else if(iMonth < 1 || iMonth > 12) {
				ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Bulan Lahir", "Error! Invalid Input\nMasukan tanggal lahir (Tgl/Bulan/Tahun): 15/04/1998", "Pilih", "Batal");
			}
			else if(iDay < 1 || iDay > arrMonthDays[iMonth - 1]) {
				ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Tanggal Lahir", "Error! Invalid Input\nMasukan tanggal lahir (Tgl/Bulan/Tahun): 15/04/1998", "Pilih", "Batal");
			}
			else 
			{
				format(pData[playerid][pAge], 50, inputtext);
				ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST, "Gender", "1. Male/Laki-Laki\n2. Female/Perempuan", "Pilih", "Batal");
			}
		}
		else ShowPlayerDialog(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Tanggal Lahir", "Masukan tanggal lahir (Tgl/Bulan/Tahun): 15/04/1998", "Pilih", "Batal");
		return 1;
	}
	if(dialogid == DIALOG_GENDER)
    {
		if(!response) return ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST, "Gender", "1. Male/Laki-Laki\n2. Female/Perempuan", "Pilih", "Batal");
		if(response)
		{
			pData[playerid][pGender] = listitem + 1;
			switch (listitem) 
			{
				case 0: 
				{
					SendClientMessageEx(playerid,COLOR_WHITE,"Server : Registrasi Berhasil! Terima kasih telah bergabung ke dalam server!");
					SendClientMessageEx(playerid,COLOR_WHITE,"Server : Tanggal Lahir : %s | Gender : Male/Laki-Laki", pData[playerid][pAge]);
					switch (pData[playerid][pGender])
					{
						case 1: ShowModelSelectionMenu(playerid, SpawnMale, "Choose your skin");
						case 2: ShowModelSelectionMenu(playerid, SpawnFemale, "Choose your skin");
					}
				}
				case 1: 
				{
					SendClientMessageEx(playerid,COLOR_WHITE,"Registrasi Berhasil! Terima kasih telah bergabung ke dalam server!");
					SendClientMessageEx(playerid,COLOR_WHITE,"Server : Tanggal Lahir : %s | Gender : Female/Perempuan", pData[playerid][pAge]);
					switch (pData[playerid][pGender])
					{
						case 1: ShowModelSelectionMenu(playerid, SpawnMale, "Choose your skin");
						case 2: ShowModelSelectionMenu(playerid, SpawnFemale, "Choose your skin");
					}
				}
			}
			pData[playerid][pSkin] = (listitem) ? (233) : (98);
			SetPlayerSkin(playerid,pData[playerid][pSkin]);
			SetSpawnInfo(playerid, 0, pData[playerid][pSkin], 1744.3411, -1862.8655, 13.3983, 270.0000, 0, 0, 0, 0, 0, 0);
			SpawnPlayer(playerid);
		}
		else ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST, "Gender", "1. Male/Laki-Laki\n2. Female/Perempuan", "Pilih", "Batal");
		return 1;
	}
	if(dialogid == DIALOG_EMAIL)
	{
		if(response)
		{
			if(isnull(inputtext))
			{
				Error(playerid, "This field cannot be left empty!");
				callcmd::email(playerid);
				return 1;
			}
			if(!(2 < strlen(inputtext) < 40))
			{
				Error(playerid, "Please insert a valid email! Must be between 3-40 characters.");
				callcmd::email(playerid);
				return 1;
			}
			if(!IsValidPassword(inputtext))
			{
				Error(playerid, "Email can contain only A-Z, a-z, 0-9, _, [ ], ( )  and @");
				callcmd::email(playerid);
				return 1;
			}
			new query[512];
			mysql_format(g_SQL, query, sizeof(query), "UPDATE players SET email='%e' WHERE reg_id='%d'", inputtext, pData[playerid][pID]);
			mysql_tquery(g_SQL, query);
			Servers(playerid, "Your e-mail has been set to "YELLOW_E"%s!"WHITE_E"(relogin for /stats update)", inputtext);
			return 1;
		}
	}
	if(dialogid == DIALOG_PASSWORD)
	{
		if(response)
		{
			if(!(3 < strlen(inputtext) < 20))
			{
				Error(playerid, "Please insert a valid password! Must be between 4-20 characters.");
				callcmd::changepass(playerid);
				return 1;
			}
			if(!IsValidPassword(inputtext))
			{
				Error(playerid, "Password can contain only A-Z, a-z, 0-9, _, [ ], ( )");
				callcmd::changepass(playerid);
				return 1;
			}
			new query[512];
			for (new i = 0; i < 16; i++) pData[playerid][pSalt][i] = random(94) + 33;
			SHA256_PassHash(inputtext, pData[playerid][pSalt], pData[playerid][pPassword], 65);

			mysql_format(g_SQL, query, sizeof(query), "UPDATE players SET password='%s', salt='%e' WHERE reg_id='%d'", pData[playerid][pPassword], pData[playerid][pSalt], pData[playerid][pID]);
			mysql_tquery(g_SQL, query);
			Servers(playerid, "Your password has been updated to "YELLOW_E"'%s'", inputtext);
		}
	}
	if(dialogid == DIALOG_STATS)
	{
		if(response)
		{
			return callcmd::settings(playerid);
		}
	}
	if(dialogid == DIALOG_SETTINGS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					return callcmd::email(playerid);
				}
				case 1:
				{
					return callcmd::changepass(playerid);
				}
				case 2:
				{	
					ShowPlayerDialog(playerid, DIALOG_HBEMODE, DIALOG_STYLE_LIST, "HBE Mode", ""LG_E"Simple\n"LG_E"Modern\n"RED_E"Disable", "Set", "Close");
				}
				case 3:
				{
					return callcmd::togpm(playerid);
				}
				case 4:
				{
					return callcmd::toglog(playerid);
				}
				case 5:
				{
					return callcmd::togads(playerid);
				}
				case 6:
				{
					return callcmd::togwt(playerid);
				}
			}
		}
	}
	if(dialogid == DIALOG_HBEMODE)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					HidePlayerProgressBar(playerid, pData[playerid][sphungrybar]);
					HidePlayerProgressBar(playerid, pData[playerid][spenergybar]);
					HidePlayerProgressBar(playerid, pData[playerid][spbladdybar]);
					for(new txd = 12; txd > 11 && txd < 16; txd++)
					{
						TextDrawHideForPlayer(playerid, TDEditor_TD[txd]);
					}
					
					HidePlayerProgressBar(playerid, pData[playerid][hungrybar]);
					HidePlayerProgressBar(playerid, pData[playerid][energybar]);
					HidePlayerProgressBar(playerid, pData[playerid][bladdybar]);
					for(new txd; txd < 5; txd++)
					{
						TextDrawHideForPlayer(playerid, TDEditor_TD[txd]);
					}
					
					PlayerTextDrawHide(playerid,  DPname[playerid]);
					PlayerTextDrawHide(playerid,  DPcoin[playerid]);
					PlayerTextDrawHide(playerid,  DPmoney[playerid]);
					
					pData[playerid][pHBEMode] = 1;
					
					ShowPlayerProgressBar(playerid, pData[playerid][sphungrybar]);
					ShowPlayerProgressBar(playerid, pData[playerid][spenergybar]);
					ShowPlayerProgressBar(playerid, pData[playerid][spbladdybar]);
					for(new txd = 12; txd > 11 && txd < 16; txd++)
					{
						TextDrawShowForPlayer(playerid, TDEditor_TD[txd]);
					}
				}
				case 1:
				{
					HidePlayerProgressBar(playerid, pData[playerid][sphungrybar]);
					HidePlayerProgressBar(playerid, pData[playerid][spenergybar]);
					HidePlayerProgressBar(playerid, pData[playerid][spbladdybar]);
					for(new txd = 12; txd > 11 && txd < 16; txd++)
					{
						TextDrawHideForPlayer(playerid, TDEditor_TD[txd]);
					}
					
					HidePlayerProgressBar(playerid, pData[playerid][hungrybar]);
					HidePlayerProgressBar(playerid, pData[playerid][energybar]);
					HidePlayerProgressBar(playerid, pData[playerid][bladdybar]);
					for(new txd; txd < 5; txd++)
					{
						TextDrawHideForPlayer(playerid, TDEditor_TD[txd]);
					}
					
					PlayerTextDrawHide(playerid,  DPname[playerid]);
					PlayerTextDrawHide(playerid,  DPcoin[playerid]);
					PlayerTextDrawHide(playerid,  DPmoney[playerid]);
					
					pData[playerid][pHBEMode] = 2;
					
					ShowPlayerProgressBar(playerid, pData[playerid][hungrybar]);
					ShowPlayerProgressBar(playerid, pData[playerid][energybar]);
					ShowPlayerProgressBar(playerid, pData[playerid][bladdybar]);
					for(new txd; txd < 5; txd++)
					{
						TextDrawShowForPlayer(playerid, TDEditor_TD[txd]);
					}
				}
				case 2:
				{
					pData[playerid][pHBEMode] = 0;
					
					HidePlayerProgressBar(playerid, pData[playerid][sphungrybar]);
					HidePlayerProgressBar(playerid, pData[playerid][spenergybar]);
					HidePlayerProgressBar(playerid, pData[playerid][spbladdybar]);
					for(new txd = 12; txd > 11 && txd < 16; txd++)
					{
						TextDrawHideForPlayer(playerid, TDEditor_TD[txd]);
					}
					
					HidePlayerProgressBar(playerid, pData[playerid][hungrybar]);
					HidePlayerProgressBar(playerid, pData[playerid][energybar]);
					HidePlayerProgressBar(playerid, pData[playerid][bladdybar]);
					for(new txd; txd < 5; txd++)
					{
						TextDrawHideForPlayer(playerid, TDEditor_TD[txd]);
					}
					
					PlayerTextDrawHide(playerid,  DPname[playerid]);
					PlayerTextDrawHide(playerid,  DPcoin[playerid]);
					PlayerTextDrawHide(playerid,  DPmoney[playerid]);
				}
			}
		}
	}
	if(dialogid == DIALOG_CHANGEAGE)
    {
		if(response)
		{
			new
				iDay,
				iMonth,
				iYear,
				day,
				month,
				year;
				
			getdate(year, month, day);

			static const
					arrMonthDays[] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

			if(sscanf(inputtext, "p</>ddd", iDay, iMonth, iYear)) {
				ShowPlayerDialog(playerid, DIALOG_CHANGEAGE, DIALOG_STYLE_INPUT, "Tanggal Lahir", "Error! Invalid Input\nMasukan tanggal lahir (Tgl/Bulan/Tahun): 15/04/1998", "Pilih", "Batal");
			}
			else if(iYear < 1900 || iYear > year) {
				ShowPlayerDialog(playerid, DIALOG_CHANGEAGE, DIALOG_STYLE_INPUT, "Tahun Lahir", "Error! Invalid Input\nMasukan tanggal lahir (Tgl/Bulan/Tahun): 15/04/1998", "Pilih", "Batal");
			}
			else if(iMonth < 1 || iMonth > 12) {
				ShowPlayerDialog(playerid, DIALOG_CHANGEAGE, DIALOG_STYLE_INPUT, "Bulan Lahir", "Error! Invalid Input\nMasukan tanggal lahir (Tgl/Bulan/Tahun): 15/04/1998", "Pilih", "Batal");
			}
			else if(iDay < 1 || iDay > arrMonthDays[iMonth - 1]) {
				ShowPlayerDialog(playerid, DIALOG_CHANGEAGE, DIALOG_STYLE_INPUT, "Tanggal Lahir", "Error! Invalid Input\nMasukan tanggal lahir (Tgl/Bulan/Tahun): 15/04/1998", "Pilih", "Batal");
			}
			else 
			{
				format(pData[playerid][pAge], 50, inputtext);
				Info(playerid, "New Age for your character is "YELLOW_E"%s.", pData[playerid][pAge]);
				GivePlayerMoneyEx(playerid, -300);
				Server_AddMoney(300);
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_GOLDSHOP)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(pData[playerid][pGold] < 500) return Error(playerid, "Not enough gold!");
					ShowPlayerDialog(playerid, DIALOG_GOLDNAME, DIALOG_STYLE_INPUT, "Change Name", "Input new nickname:\nExample: Charles_Sanders\n", "Change", "Cancel");
				}
				case 1:
				{
					if(pData[playerid][pGold] < 1000) return Error(playerid, "Not enough gold!");
					pData[playerid][pGold] -= 1000;
					pData[playerid][pWarn] = 0;
					Info(playerid, "Warning have been reseted for 1000 gold. Total Warning: 0");
				}
				case 2:
				{
					if(pData[playerid][pGold] < 150) return Error(playerid, "Not enough gold!");
					pData[playerid][pGold] -= 150;
					pData[playerid][pVip] = 1;
					pData[playerid][pVipTime] = gettime() + (7 * 86400);
					Info(playerid, "You has bought VIP level 1 for 150 gold(7 days).");
				}
				case 3:
				{
					if(pData[playerid][pGold] < 250) return Error(playerid, "Not enough gold!");
					pData[playerid][pGold] -= 250;
					pData[playerid][pVip] = 2;
					pData[playerid][pVipTime] = gettime() + (7 * 86400);
					Info(playerid, "You has bought VIP level 2 for 250 gold(7 days).");
				}
				case 4:
				{
					if(pData[playerid][pGold] < 500) return Error(playerid, "Not enough gold!");
					pData[playerid][pGold] -= 500;
					pData[playerid][pVip] = 3;
					pData[playerid][pVipTime] = gettime() + (7 * 86400);
					Info(playerid, "You has bought VIP level 3 for 500 gold(7 days).");
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_GOLDNAME)
	{
		if(response)
		{
			if(strlen(inputtext) < 4) return Error(playerid, "New name can't be shorter than 4 characters!"),  ShowPlayerDialog(playerid, DIALOG_GOLDNAME, DIALOG_STYLE_INPUT, ""WHITE_E"Change Name", "Enter your new name:", "Enter", "Exit");
			if(strlen(inputtext) > 20) return Error(playerid, "New name can't be longer than 20 characters!"),  ShowPlayerDialog(playerid, DIALOG_GOLDNAME, DIALOG_STYLE_INPUT, ""WHITE_E"Change Name", "Enter your new name:", "Enter", "Exit");
			if(!IsValidRoleplayName(inputtext))
			{
				Error(playerid, "Name contains invalid characters, please doublecheck!");
				ShowPlayerDialog(playerid, DIALOG_GOLDNAME, DIALOG_STYLE_INPUT, ""WHITE_E"Change Name", "Enter your new name:", "Enter", "Exit");
				return 1;
			}
			new query[512];
			mysql_format(g_SQL, query, sizeof(query), "SELECT username FROM players WHERE username='%s'", inputtext);
			mysql_tquery(g_SQL, query, "ChangeName", "is", playerid, inputtext);
		}
		return 1;
	}
	//-----------[ Bisnis Dialog ]------------
	if(dialogid == DIALOG_SELL_BISNISS)
	{
		if(!response) return 1;
		new str[248];
		SetPVarInt(playerid, "SellingBisnis", ReturnPlayerBisnisID(playerid, (listitem + 1)));
		format(str, sizeof(str), "Are you sure you will sell bisnis id: %d", GetPVarInt(playerid, "SellingBisnis"));
				
		ShowPlayerDialog(playerid, DIALOG_SELL_BISNIS, DIALOG_STYLE_MSGBOX, "Sell Bisnis", str, "Sell", "Cancel");
	}
	if(dialogid == DIALOG_SELL_BISNIS)
	{
		if(response)
		{
			new bid = GetPVarInt(playerid, "SellingBisnis"), price;
			price = bData[bid][bPrice] / 2;
			GivePlayerMoneyEx(playerid, price);
			Info(playerid, "Anda berhasil menjual bisnis id (%d) dengan setengah harga("LG_E"%s"WHITE_E") pada saat anda membelinya.", bid, FormatMoney(price));
			Bisnis_Reset(bid);
			Bisnis_Save(bid);
			Bisnis_Refresh(bid);
		}
		DeletePVar(playerid, "SellingBisnis");
		return 1;
	}
	if(dialogid == DIALOG_MY_BISNIS)
	{
		if(!response) return true;
		SetPVarInt(playerid, "ClickedBisnis", ReturnPlayerBisnisID(playerid, (listitem + 1)));
		ShowPlayerDialog(playerid, BISNIS_INFO, DIALOG_STYLE_LIST, "{FF0000}Glory:RP {0000FF}Bisnis", "Show Information\nTrack Bisnis", "Select", "Cancel");
		return 1;
	}
	if(dialogid == BISNIS_INFO)
	{
		if(!response) return true;
		new bid = GetPVarInt(playerid, "ClickedBisnis");
		switch(listitem)
		{
			case 0:
			{
				new line9[900];
				new lock[128], type[128];
				if(bData[bid][bLocked] == 1)
				{
					lock = "{FF0000}Locked";
			
				}
				else
				{
					lock = "{00FF00}Unlocked";
				}
				if(bData[bid][bType] == 1)
				{
					type = "Fast Food";
			
				}
				else if(bData[bid][bType] == 2)
				{
					type = "Market";
				}
				else if(bData[bid][bType] == 3)
				{
					type = "Clothes";
				}
				else if(bData[bid][bType] == 4)
				{
					type = "Equipment";
				}
				else
				{
					type = "Unknow";
				}
				format(line9, sizeof(line9), "Bisnis ID: %d\nBisnis Owner: %s\nBisnis Name: %s\nBisnis Price: %s\nBisnis Type: %s\nBisnis Status: %s\nBisnis Product: %d",
				bid, bData[bid][bOwner], bData[bid][bName], FormatMoney(bData[bid][bPrice]), type, lock, bData[bid][bProd]);

				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Bisnis Info", line9, "Close","");
			}
			case 1:
			{
				pData[playerid][pTrackBisnis] = 1;
				SetPlayerRaceCheckpoint(playerid,1, bData[bid][bExtposX], bData[bid][bExtposY], bData[bid][bExtposZ], 0.0, 0.0, 0.0, 3.5);
				//SetPlayerCheckpoint(playerid, bData[bid][bExtpos][0], bData[bid][bExtpos][1], bData[bid][bExtpos][2], 4.0);
				Info(playerid, "Ikuti checkpoint untuk menemukan bisnis anda!");
			}
		}
		return 1;
	}
	if(dialogid == BISNIS_MENU)
	{
		new bid = pData[playerid][pInBiz];
		new lock[128];
		if(bData[bid][bLocked] == 1)
		{
			lock = "Locked";
		}
		else
		{
			lock = "Unlocked";
		}
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{	
					new mstr[248], lstr[512];
					format(mstr,sizeof(mstr),"Bisnis ID %d", bid);
					format(lstr,sizeof(lstr),"Bisnis Name:\t%s\nBisnis Locked:\t%s\nBisnis Product:\t%d\nBisnis Vault:\t%s", bData[bid][bName], lock, bData[bid][bProd], FormatMoney(bData[bid][bMoney]));
					ShowPlayerDialog(playerid, BISNIS_INFO, DIALOG_STYLE_TABLIST, mstr, lstr,"Back","Close");
				}
				case 1:
				{
					new mstr[248];
					format(mstr,sizeof(mstr),"Nama sebelumnya: %s\n\nMasukkan nama bisnis yang kamu inginkan\nMaksimal 32 karakter untuk nama bisnis", bData[bid][bName]);
					ShowPlayerDialog(playerid, BISNIS_NAME, DIALOG_STYLE_INPUT,"Bisnis Name", mstr,"Done","Back");
				}
				case 2: ShowPlayerDialog(playerid, BISNIS_VAULT, DIALOG_STYLE_LIST,"Bisnis Vault","Deposit\nWithdraw","Next","Back");
				case 3:
				{
					Bisnis_ProductMenu(playerid, bid);
				}
				case 4:
				{
					if(bData[bid][bProd] > 100)
						return Error(playerid, "Bisnis ini masih memiliki cukup produck.");
					if(bData[bid][bMoney] < 1000)
						return Error(playerid, "Setidaknya anda mempunyai uang dalam bisnis anda senilai $1.000 untuk merestock product.");
					bData[bid][bRestock] = 1;
					Info(playerid, "Anda berhasil request untuk mengisi stock product kepada trucker, harap tunggu sampai pekerja trucker melayani.");
				}
			}
		}
		return 1;
	}
	if(dialogid == BISNIS_INFO)
	{
		if(response)
		{
			return callcmd::bm(playerid, "\0");
		}
		return 1;
	}
	if(dialogid == BISNIS_NAME)
	{
		if(response)
		{
			new bid = pData[playerid][pInBiz];

			if(!Player_OwnsBisnis(playerid, pData[playerid][pInBiz])) return Error(playerid, "You don't own this bisnis.");
			
			if (isnull(inputtext))
			{
				new mstr[512];
				format(mstr,sizeof(mstr),""RED_E"NOTE: "WHITE_E"Nama Bisnis tidak di perbolehkan kosong!\n\n"WHITE_E"Nama sebelumnya: %s\n\nMasukkan nama Bisnis yang kamu inginkan\nMaksimal 32 karakter untuk nama Bisnis", bData[bid][bName]);
				ShowPlayerDialog(playerid, BISNIS_NAME, DIALOG_STYLE_INPUT,"Bisnis Name", mstr,"Done","Back");
				return 1;
			}
			if(strlen(inputtext) > 32 || strlen(inputtext) < 5)
			{
				new mstr[512];
				format(mstr,sizeof(mstr),""RED_E"NOTE: "WHITE_E"Nama Bisnis harus 5 sampai 32 karakter.\n\n"WHITE_E"Nama sebelumnya: %s\n\nMasukkan nama Bisnis yang kamu inginkan\nMaksimal 32 karakter untuk nama Bisnis", bData[bid][bName]);
				ShowPlayerDialog(playerid, BISNIS_NAME, DIALOG_STYLE_INPUT,"Bisnis Name", mstr,"Done","Back");
				return 1;
			}
			format(bData[bid][bName], 32, ColouredText(inputtext));

			Bisnis_Refresh(bid);
			Bisnis_Save(bid);

			Servers(playerid, "Bisnis name set to: \"%s\".", bData[bid][bName]);
		}
		else return callcmd::bm(playerid, "\0");
		return 1;
	}
	if(dialogid == BISNIS_VAULT)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new mstr[512];
					format(mstr,sizeof(mstr),"Uang kamu: %s.\n\nMasukkan berapa banyak uang yang akan kamu simpan di dalam bisnis ini", FormatMoney(GetPlayerMoney(playerid)));
					ShowPlayerDialog(playerid, BISNIS_DEPOSIT, DIALOG_STYLE_INPUT, "Deposit", mstr, "Deposit", "Back");
				}
				case 1:
				{
					new mstr[512];
					format(mstr,sizeof(mstr),"Business Vault: %s\n\nMasukkan berapa banyak uang yang akan kamu ambil di dalam bisnis ini", FormatMoney(bData[pData[playerid][pInBiz]][bMoney]));
					ShowPlayerDialog(playerid, BISNIS_WITHDRAW, DIALOG_STYLE_INPUT,"Withdraw", mstr,"Withdraw","Back");
				}
			}
		}
		return 1;
	}
	if(dialogid == BISNIS_WITHDRAW)
	{
		if(response)
		{
			new bid = pData[playerid][pInBiz];
			new amount = floatround(strval(inputtext));
			if(amount < 1 || amount > bData[bid][bMoney])
				return Error(playerid, "Invalid amount specified!");

			bData[bid][bMoney] -= amount;
			Bisnis_Save(bid);

			GivePlayerMoneyEx(playerid, amount);

			SendClientMessageEx(playerid, COLOR_LBLUE,"BUSINESS: "WHITE_E"You have withdrawn "GREEN_E"%s "WHITE_E"from the business vault.", FormatMoney(strval(inputtext)));
		}
		else
			ShowPlayerDialog(playerid, BISNIS_VAULT, DIALOG_STYLE_LIST,"Business Vault","Deposit\nWithdraw","Next","Back");
		return 1;
	}
	if(dialogid == BISNIS_DEPOSIT)
	{
		if(response)
		{
			new bid = pData[playerid][pInBiz];
			new amount = floatround(strval(inputtext));
			if(amount < 1 || amount > GetPlayerMoney(playerid))
				return Error(playerid, "Invalid amount specified!");

			bData[bid][bMoney] += amount;
			Bisnis_Save(bid);

			GivePlayerMoneyEx(playerid, -amount);
			
			SendClientMessageEx(playerid, COLOR_LBLUE,"BUSINESS: "WHITE_E"You have deposit "GREEN_E"%s "WHITE_E"into the business vault.", FormatMoney(strval(inputtext)));
		}
		else
			ShowPlayerDialog(playerid, BISNIS_VAULT, DIALOG_STYLE_LIST,"Business Vault","Deposit\nWithdraw","Next","Back");
		return 1;
	}
	if(dialogid == BISNIS_BUYPROD)
	{
		static
        bizid = -1,
        price;

		if((bizid = pData[playerid][pInBiz]) != -1 && response)
		{
			price = bData[bizid][bP][listitem];

			if(GetPlayerMoney(playerid) < price)
				return Error(playerid, "Not enough money!");

			if(bData[bizid][bProd] < 1)
				return Error(playerid, "This business is out of stock product.");
				
			new Float:health;
			GetPlayerHealth(playerid,health);
			if(bData[bizid][bType] == 1)
			{
				switch(listitem)
				{
					case 0:
					{
						GivePlayerMoneyEx(playerid, -price);
						SetPlayerHealthEx(playerid, health+30);
						pData[playerid][pHunger] += 35;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli makanan seharga %s dan langsung memakannya.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 1:
					{
						GivePlayerMoneyEx(playerid, -price);
						SetPlayerHealthEx(playerid, health+45);
						pData[playerid][pHunger] += 50;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli makanan seharga %s dan langsung memakannya.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 2:
					{
						GivePlayerMoneyEx(playerid, -price);
						SetPlayerHealthEx(playerid, health+70);
						pData[playerid][pHunger] += 75;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli makanan seharga %s dan langsung memakannya.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 3:
					{
						GivePlayerMoneyEx(playerid, -price);
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
						pData[playerid][pEnergy] += 60;
						//SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DRINK_SPRUNK);
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli minuman seharga %s.", ReturnName(playerid), FormatMoney(price));
						//SetPVarInt(playerid, "UsingSprunk", 1);
					}
				}
			}
			else if(bData[bizid][bType] == 2)
			{
				switch(listitem)
				{
					case 0:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pSnack]++;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli snack seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 1:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pSprunk]++;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli Sprunk seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 2:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pGas]++;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli Gas Fuel seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 3:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pBandage]++;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli Perban seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 4:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pGPS] = 1;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli GPS seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 5:
					{
						GivePlayerMoneyEx(playerid, -price);
						new query[128], rand = RandomEx(1111, 9888);
						new phone = rand+pData[playerid][pID];
						mysql_format(g_SQL, query, sizeof(query), "SELECT phone FROM players WHERE phone='%d'", phone);
						mysql_tquery(g_SQL, query, "PhoneNumber", "id", playerid, phone);
						//pData[playerid][pPhone] = ;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli phone seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 6:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pPhoneCredit] += 5;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli 5 phone credit seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 7:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pPhoneBook] = 1;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli sebuah phone book seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 8:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pWT] = 1;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli sebuah walkie talkie seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
				}
			}
			else if(bData[bizid][bType] == 3)
			{
				switch(listitem)
				{
					case 0:
					{
						switch(pData[playerid][pGender])
						{
							case 1: ShowModelSelectionMenu(playerid, MaleSkins, "Choose your skin");
							case 2: ShowModelSelectionMenu(playerid, FemaleSkins, "Choose your skin");
						}
					}
					case 1:
					{
						new string[248];
						if(pToys[playerid][0][toy_model] == 0)
						{
							strcat(string, ""dot"Slot 1\n");
						}
						else strcat(string, ""dot"Slot 1 "RED_E"(Used)\n");

						if(pToys[playerid][1][toy_model] == 0)
						{
							strcat(string, ""dot"Slot 2\n");
						}
						else strcat(string, ""dot"Slot 2 "RED_E"(Used)\n");

						if(pToys[playerid][2][toy_model] == 0)
						{
							strcat(string, ""dot"Slot 3\n");
						}
						else strcat(string, ""dot"Slot 3 "RED_E"(Used)\n");

						if(pToys[playerid][3][toy_model] == 0)
						{
							strcat(string, ""dot"Slot 4\n");
						}
						else strcat(string, ""dot"Slot 4 "RED_E"(Used)\n");

						/*if(pToys[playerid][4][toy_model] == 0)
						{
							strcat(string, ""dot"Slot 5\n");
						}
						else strcat(string, ""dot"Slot 5 "RED_E"(Used)\n");

						if(pToys[playerid][5][toy_model] == 0)
						{
							strcat(string, ""dot"Slot 6\n");
						}
						else strcat(string, ""dot"Slot 6 "RED_E"(Used)\n");*/

						ShowPlayerDialog(playerid, DIALOG_TOYBUY, DIALOG_STYLE_LIST, ""RED_E"PWRP: "WHITE_E"Player Toys", string, "Select", "Cancel");
					}
					case 2:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pMask] = 1;
						pData[playerid][pMaskID] = random(90000) + 10000;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli mask seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 3:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pHelmet] = 1;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli Helmet seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
				}
			}
			else if(bData[bizid][bType] == 4)
			{
				switch(listitem)
				{
					case 0:
					{
						GivePlayerMoneyEx(playerid, -price);
						GivePlayerWeaponEx(playerid, 1, 1);
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli Brass Knuckles seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 1:
					{
						if(pData[playerid][pJob] == 7 || pData[playerid][pJob2] == 7)
						{
							GivePlayerMoneyEx(playerid, -price);
							GivePlayerWeaponEx(playerid, 4, 1);
							SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli Knife seharga %s.", ReturnName(playerid), FormatMoney(price));
							bData[bizid][bProd]--;
							bData[bizid][bMoney] += Server_Percent(price);
							Server_AddPercent(price);
							Bisnis_Save(bizid);
						}
						else return Error(playerid, "Job farmer only!");
					}
					case 2:
					{
						GivePlayerMoneyEx(playerid, -price);
						GivePlayerWeaponEx(playerid, 5, 1);
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli Baseball Bat seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 3:
					{
						if(pData[playerid][pJob] == 5 || pData[playerid][pJob2] == 5)
						{
							GivePlayerMoneyEx(playerid, -price);
							GivePlayerWeaponEx(playerid, 6, 1);
							SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli Shovel seharga %s.", ReturnName(playerid), FormatMoney(price));
							bData[bizid][bProd]--;
							bData[bizid][bMoney] += Server_Percent(price);
							Server_AddPercent(price);
							Bisnis_Save(bizid);
						}
						else return Error(playerid, "Job miner only!");
					}
					case 4:
					{
						if(pData[playerid][pJob] == 3 || pData[playerid][pJob2] == 3)
						{
							GivePlayerMoneyEx(playerid, -price);
							GivePlayerWeaponEx(playerid, 9, 1);
							SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli Chainsaw seharga %s.", ReturnName(playerid), FormatMoney(price));
							bData[bizid][bProd]--;
							bData[bizid][bMoney] += Server_Percent(price);
							Server_AddPercent(price);
							Bisnis_Save(bizid);
						}
						else return Error(playerid, "Job lumber jack only!");
					}
					case 5:
					{
						GivePlayerMoneyEx(playerid, -price);
						GivePlayerWeaponEx(playerid, 15, 1);
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli Cane seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 6:
					{
						if(pData[playerid][pFishTool] > 2) return Error(playerid, "You only can get 3 fish tool!");
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pFishTool]++;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli pancingan seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
					case 7:
					{
						GivePlayerMoneyEx(playerid, -price);
						pData[playerid][pWorm] += 2;
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s telah membeli 2 umpan cacing seharga %s.", ReturnName(playerid), FormatMoney(price));
						bData[bizid][bProd]--;
						bData[bizid][bMoney] += Server_Percent(price);
						Server_AddPercent(price);
						Bisnis_Save(bizid);
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == BISNIS_EDITPROD)
	{
		if(Player_OwnsBisnis(playerid, pData[playerid][pInBiz]))
		{
			if(response)
			{
				static
					item[40],
					str[128];

				strmid(item, inputtext, 0, strfind(inputtext, "-") - 1);
				strpack(pData[playerid][pEditingItem], item, 40 char);

				pData[playerid][pProductModify] = listitem;
				format(str,sizeof(str), "Please enter the new product price for %s:", item);
				ShowPlayerDialog(playerid, BISNIS_PRICESET, DIALOG_STYLE_INPUT, "Business: Set Price", str, "Modify", "Back");
			}
			else
				return callcmd::bm(playerid, "\0");
		}
		return 1;
	}
	if(dialogid == BISNIS_PRICESET)
	{
		static
        item[40];
		new bizid = pData[playerid][pInBiz];
		if(Player_OwnsBisnis(playerid, pData[playerid][pInBiz]))
		{
			if(response)
			{
				strunpack(item, pData[playerid][pEditingItem]);

				if(isnull(inputtext))
				{
					new str[128];
					format(str,sizeof(str), "Please enter the new product price for %s:", item);
					ShowPlayerDialog(playerid, BISNIS_PRICESET, DIALOG_STYLE_INPUT, "Business: Set Price", str, "Modify", "Back");
					return 1;
				}
				if(strval(inputtext) < 1 || strval(inputtext) > 5000)
				{
					new str[128];
					format(str,sizeof(str), "Please enter the new product price for %s ($1 to $5,000):", item);
					ShowPlayerDialog(playerid, BISNIS_PRICESET, DIALOG_STYLE_INPUT, "Business: Set Price", str, "Modify", "Back");
					return 1;
				}
				bData[bizid][bP][pData[playerid][pProductModify]] = strval(inputtext);
				Bisnis_Save(bizid);

				Servers(playerid, "You have adjusted the price of %s to: %s!", item, FormatMoney(strval(inputtext)));
				Bisnis_ProductMenu(playerid, bizid);
			}
			else
			{
				Bisnis_ProductMenu(playerid, bizid);
			}
		}
		return 1;
	}
	//-----------[ House Dialog ]------------------
	if(dialogid == DIALOG_SELL_HOUSES)
	{
		if(!response) return 1;
		new str[248];
		SetPVarInt(playerid, "SellingHouse", ReturnPlayerHousesID(playerid, (listitem + 1)));
		format(str, sizeof(str), "Are you sure you will sell house id: %d", GetPVarInt(playerid, "SellingHouse"));
				
		ShowPlayerDialog(playerid, DIALOG_SELL_HOUSE, DIALOG_STYLE_MSGBOX, "Sell House", str, "Sell", "Cancel");
	}
	if(dialogid == DIALOG_SELL_HOUSE)
	{
		if(response)
		{
			new hid = GetPVarInt(playerid, "SellingHouse"), price;
			price = hData[hid][hPrice] / 2;
			GivePlayerMoneyEx(playerid, price);
			Info(playerid, "Anda berhasil menjual rumah id (%d) dengan setengah harga("LG_E"%s"WHITE_E") pada saat anda membelinya.", hid, FormatMoney(price));
			HouseReset(hid);
			House_Save(hid);
			House_Refresh(hid);
		}
		DeletePVar(playerid, "SellingHouse");
		return 1;
	}
	if(dialogid == DIALOG_MY_HOUSES)
	{
		if(!response) return 1;
		SetPVarInt(playerid, "ClickedHouse", ReturnPlayerHousesID(playerid, (listitem + 1)));
		ShowPlayerDialog(playerid, HOUSE_INFO, DIALOG_STYLE_LIST, "{FF0000}SoI:RP {0000FF}Houses", "Show Information\nTrack House", "Select", "Cancel");
		return 1;
	}
	if(dialogid == HOUSE_INFO)
	{
		if(!response) return 1;
		new hid = GetPVarInt(playerid, "ClickedHouse");
		switch(listitem)
		{
			case 0:
			{
				new line9[900];
				new lock[128], type[128];
				if(hData[hid][hLocked] == 1)
				{
					lock = "{FF0000}Locked";
			
				}
				else
				{
					lock = "{00FF00}Unlocked";
				}
				if(hData[hid][hType] == 1)
				{
					type = "Small";
			
				}
				else if(hData[hid][hType] == 2)
				{
					type = "Medium";
				}
				else if(hData[hid][hType] == 3)
				{
					type = "Big";
				}
				else
				{
					type = "Unknow";
				}
				format(line9, sizeof(line9), "House ID: %d\nHouse Owner: %s\nHouse Address: %s\nHouse Price: %s\nHouse Type: %s\nHouse Status: %s",
				hid, hData[hid][hOwner], hData[hid][hAddress], FormatMoney(hData[hid][hPrice]), type, lock);

				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "House Info", line9, "Close","");
			}
			case 1:
			{
				pData[playerid][pTrackHouse] = 1;
				SetPlayerRaceCheckpoint(playerid,1, hData[hid][hExtposX], hData[hid][hExtposY], hData[hid][hExtposZ], 0.0, 0.0, 0.0, 3.5);
				//SetPlayerCheckpoint(playerid, hData[hid][hExtpos][0], hData[hid][hExtpos][1], hData[hid][hExtpos][2], 4.0);
				Info(playerid, "Ikuti checkpoint untuk menemukan rumah anda!");
			}
		}
		return 1;
	}
	if(dialogid == HOUSE_STORAGE)
	{
		new hid = pData[playerid][pInHouse];
		if(!Player_OwnsHouse(playerid, pData[playerid][pInHouse])) 
			if(pData[playerid][pFaction] != 1)
				return Error(playerid, "You don't own this house.");
		if(response)
		{
			if(listitem == 0) 
			{
				House_WeaponStorage(playerid, hid);
			}
			else if(listitem == 1) 
			{
				ShowPlayerDialog(playerid, HOUSE_MONEY, DIALOG_STYLE_LIST, "Money Safe", "Withdraw from safe\nDeposit into safe", "Select", "Back");
			}
		}
		return 1;
	}
	if(dialogid == HOUSE_WEAPONS)
	{
		new houseid = pData[playerid][pInHouse];
		if(!Player_OwnsHouse(playerid, pData[playerid][pInHouse])) 
			if(pData[playerid][pFaction] != 1)
				return Error(playerid, "You don't own this house.");
				
		if(response)
		{
			if(hData[houseid][hWeapon][listitem] != 0)
			{
				GivePlayerWeaponEx(playerid, hData[houseid][hWeapon][listitem], hData[houseid][hAmmo][listitem]);

				SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has taken a \"%s\" from their weapon storage.", ReturnName(playerid), ReturnWeaponName(hData[houseid][hWeapon][listitem]));

				hData[houseid][hWeapon][listitem] = 0;
				hData[houseid][hAmmo][listitem] = 0;

				House_Save(houseid);
				House_WeaponStorage(playerid, houseid);
			}
			else
			{
				new
					weaponid = GetPlayerWeaponEx(playerid),
					ammo = GetPlayerAmmoEx(playerid);

				if(!weaponid)
					return Error(playerid, "You are not holding any weapon!");

				/*if(weaponid == 23 && pData[playerid][pTazer])
					return Error(playerid, "You can't store a tazer into your safe.");

				if(weaponid == 25 && pData[playerid][pBeanBag])
					return Error(playerid, "You can't store a beanbag shotgun into your safe.");*/

				ResetWeapon(playerid, weaponid);
				SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has stored a \"%s\" into their weapon storage.", ReturnName(playerid), ReturnWeaponName(weaponid));

				hData[houseid][hWeapon][listitem] = weaponid;
				hData[houseid][hAmmo][listitem] = ammo;

				House_Save(houseid);
				House_WeaponStorage(playerid, houseid);
			}
		}
		else
		{
			House_OpenStorage(playerid, houseid);
		}
		return 1;
	}
	if(dialogid == HOUSE_MONEY)
	{
		new houseid = pData[playerid][pInHouse];
		if(!Player_OwnsHouse(playerid, pData[playerid][pInHouse])) return Error(playerid, "You don't own this house.");
		if(response)
		{
			switch (listitem)
			{
				case 0: 
				{
					new str[128];
					format(str, sizeof(str), "Safe Balance: %s\n\nPlease enter how much money you wish to withdraw from the safe:", FormatMoney(hData[houseid][hMoney]));
					ShowPlayerDialog(playerid, HOUSE_WITHDRAWMONEY, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				}
				case 1: 
				{
					new str[128];
					format(str, sizeof(str), "Safe Balance: %s\n\nPlease enter how much money you wish to deposit into the safe:", FormatMoney(hData[houseid][hMoney]));
					ShowPlayerDialog(playerid, HOUSE_DEPOSITMONEY, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				}
			}
		}
		else House_OpenStorage(playerid, houseid);
		return 1;
	}
	if(dialogid == HOUSE_WITHDRAWMONEY)
	{
		new houseid = pData[playerid][pInHouse];
		if(!Player_OwnsHouse(playerid, pData[playerid][pInHouse])) return Error(playerid, "You don't own this house.");
		
		if(response)
		{
			new amount = strval(inputtext);

			if(isnull(inputtext))
			{
				new str[128];
				format(str, sizeof(str), "Safe Balance: %s\n\nPlease enter how much money you wish to withdraw from the safe:", FormatMoney(hData[houseid][hMoney]));
				ShowPlayerDialog(playerid, HOUSE_WITHDRAWMONEY, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				return 1;
			}
			if(amount < 1 || amount > hData[houseid][hMoney])
			{
				new str[128];
				format(str, sizeof(str), "Error: Insufficient funds.\n\nSafe Balance: %s\n\nPlease enter how much money you wish to withdraw from the safe:", FormatMoney(hData[houseid][hMoney]));
				ShowPlayerDialog(playerid, HOUSE_WITHDRAWMONEY, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				return 1;
			}
			hData[houseid][hMoney] -= amount;
			GivePlayerMoneyEx(playerid, amount);

			House_Save(houseid);
			House_OpenStorage(playerid, houseid);

			SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has withdrawn %s from their house safe.", ReturnName(playerid), FormatMoney(amount));
		}
		else ShowPlayerDialog(playerid, HOUSE_MONEY, DIALOG_STYLE_LIST, "Money Safe", "Withdraw from safe\nDeposit into safe", "Select", "Back");
		return 1;
	}
	if(dialogid == HOUSE_DEPOSITMONEY)
	{
		new houseid = pData[playerid][pInHouse];
		if(!Player_OwnsHouse(playerid, pData[playerid][pInHouse])) return Error(playerid, "You don't own this house.");
		if(response)
		{
			new amount = strval(inputtext);

			if(isnull(inputtext))
			{
				new str[128];
				format(str, sizeof(str), "Safe Balance: %s\n\nPlease enter how much money you wish to deposit into the safe:", FormatMoney(hData[houseid][hMoney]));
				ShowPlayerDialog(playerid, HOUSE_DEPOSITMONEY, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				return 1;
			}
			if(amount < 1 || amount > GetPlayerMoney(playerid))
			{
				new str[128];
				format(str, sizeof(str), "Error: Insufficient funds.\n\nSafe Balance: %s\n\nPlease enter how much money you wish to deposit into the safe:", FormatMoney(hData[houseid][hMoney]));
				ShowPlayerDialog(playerid, HOUSE_DEPOSITMONEY, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				return 1;
			}
			hData[houseid][hMoney] += amount;
			GivePlayerMoneyEx(playerid, -amount);

			House_Save(houseid);
			House_OpenStorage(playerid, houseid);

			SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has deposited %s into their house safe.", ReturnName(playerid), FormatMoney(amount));
		}
		else ShowPlayerDialog(playerid, HOUSE_MONEY, DIALOG_STYLE_LIST, "Money Safe", "Withdraw from safe\nDeposit into safe", "Select", "Back");
		return 1;
	}
	//------------[ Private Player Vehicle Dialog ]--------
	if(dialogid == DIALOG_FINDVEH)
	{
		if(response) 
		{
			ShowPlayerDialog(playerid, DIALOG_TRACKVEH, DIALOG_STYLE_INPUT, "Find Veh", "Enter your own vehicle id:", "Find", "Close");
		}
		return 1;
	}
	if(dialogid == DIALOG_TRACKVEH)
	{
		if(response) 
		{	
			new Float:posisiX, Float:posisiY, Float:posisiZ,
				carid = strval(inputtext);
			
			foreach(new veh : PVehicles)
			{
				if(pvData[veh][cVeh] == carid)
				{
					if(IsValidVehicle(pvData[veh][cVeh]))
					{
						if(pvData[veh][cOwner] == pData[playerid][pID])
						{
							GetVehiclePos(carid, posisiX, posisiY, posisiZ);
							pData[playerid][pTrackCar] = 1;
							//SetPlayerCheckpoint(playerid, posisi[0], posisi[1], posisi[2], 4.0);
							SetPlayerRaceCheckpoint(playerid,1, posisiX, posisiY, posisiZ, 0.0, 0.0, 0.0, 3.5);
							Info(playerid, "Your car waypoint was set to \"%s\" (marked on radar).", GetLocation(posisiX, posisiY, posisiZ));
						}
						else return Error(playerid, "Id kendaraan ini bukan milik anda!");
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_GOTOVEH)
	{
		if(response) 
		{
			new Float:posisiX, Float:posisiY, Float:posisiZ,
				carid = strval(inputtext);
			
			GetVehiclePos(carid, posisiX, posisiY, posisiZ);
			Servers(playerid, "Your teleport to %s (vehicle id: %d).", GetLocation(posisiX, posisiY, posisiZ), carid);
			SetPlayerPosition(playerid, posisiX, posisiY, posisiZ+3.0, 4.0, 0);
		}
		return 1;
	}
	if(dialogid == DIALOG_GETVEH)
	{
		if(response) 
		{
			new Float:posisiX, Float:posisiY, Float:posisiZ,
				carid = strval(inputtext);
			
			GetPlayerPos(playerid, posisiX, posisiY, posisiZ);
			Servers(playerid, "Your get spawn vehicle to %s (vehicle id: %d).", GetLocation(posisiX, posisiY, posisiZ), carid);
			SetVehiclePos(carid, posisiX, posisiY, posisiZ+0.5);
		}
		return 1;
	}
	if(dialogid == DIALOG_DELETEVEH)
	{
		if(response) 
		{
			new carid = strval(inputtext);
			
			//for(new i = 0; i != MAX_PRIVATE_VEHICLE; i++) if(Iter_Contains(PVehicles, i))
			foreach(new i : PVehicles)			
			{
				if(carid == pvData[i][cVeh])
				{
					new query[128];
					mysql_format(g_SQL, query, sizeof(query), "DELETE FROM vehicle WHERE id = '%d'", pvData[i][cID]);
					mysql_tquery(g_SQL, query);
					DestroyVehicle(pvData[i][cVeh]);
					Iter_SafeRemove(PVehicles, i, i);
					Servers(playerid, "Your deleted private vehicle id %d (database id: %d).", pvData[i][cVeh], pvData[i][cID]);
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_BUYPLATE)
	{
		if(response) 
		{
			new carid = strval(inputtext);
			
			//for(new i = 0; i != MAX_PRIVATE_VEHICLE; i++) if(Iter_Contains(PVehicles, i))
			foreach(new i : PVehicles)
			{
				if(carid == pvData[i][cVeh])
				{
					if(GetPlayerMoney(playerid) < 500) return Error(playerid, "Anda butuh $500 untuk membeli Plate baru.");
					GivePlayerMoneyEx(playerid, -500);
					new rand = RandomEx(1111, 9999);
					format(pvData[i][cPlate], 32, "SOI-%d", rand);
					SetVehicleNumberPlate(pvData[i][cVeh], pvData[i][cPlate]);
					pvData[i][cPlateTime] = gettime() + (15 * 86400);
					Info(playerid, "Model: %s || New plate: %s || Plate Time: %s || Plate Price: $500", GetVehicleModelName(pvData[i][cModel]), pvData[i][cPlate], ReturnTimelapse(gettime(), pvData[i][cPlateTime]));
				}
			}
		}
		return 1;
	}
	//--------------[ Player Toy Dialog ]-------------
	if(dialogid == DIALOG_TOY)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //slot 1
				{
					pData[playerid][toySelected] = 0;
					if(pToys[playerid][0][toy_model] == 0)
					{
						//ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						new string[512];
						format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
						pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
						pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"G:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
					}
				}
				case 1: //slot 2
				{
					pData[playerid][toySelected] = 1;
					if(pToys[playerid][1][toy_model] == 0)
					{
						//ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						new string[512];
						format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
						pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
						pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"G:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
						//ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos", "Select", "Cancel");
					}
				}
				case 2: //slot 3
				{
					pData[playerid][toySelected] = 2;
					if(pToys[playerid][2][toy_model] == 0)
					{
						//ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						new string[512];
						format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
						pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
						pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"G:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
						//ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos", "Select", "Cancel");
					}
				}
				case 3: //slot 4
				{
					pData[playerid][toySelected] = 3;
					if(pToys[playerid][3][toy_model] == 0)
					{
						//ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						new string[512];
						format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
						pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
						pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"G:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
						//ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos", "Select", "Cancel");
					}
				}
				case 4:
				{
					if(pData[playerid][PurchasedToy] == true)
					{
						for(new i = 0; i < 4; i++)
						{
							pToys[playerid][i][toy_model] = 0;
							pToys[playerid][i][toy_bone] = 1;
							pToys[playerid][i][toy_x] = 0.0;
							pToys[playerid][i][toy_y] = 0.0;
							pToys[playerid][i][toy_z] = 0.0;
							pToys[playerid][i][toy_rx] = 0.0;
							pToys[playerid][i][toy_ry] = 0.0;
							pToys[playerid][i][toy_rz] = 0.0;
							pToys[playerid][i][toy_sx] = 1.0;
							pToys[playerid][i][toy_sy] = 1.0;
							pToys[playerid][i][toy_sz] = 1.0;
							
							if(IsPlayerAttachedObjectSlotUsed(playerid, i))
							{
								RemovePlayerAttachedObject(playerid, i);
							}
						}
						new string[128];
						mysql_format(g_SQL, string, sizeof(string), "DELETE FROM toys WHERE Owner = '%s'", pData[playerid][pName]);
						mysql_tquery(g_SQL, string);
						pData[playerid][PurchasedToy] = false;
						GameTextForPlayer(playerid, "~r~~h~All Toy Rested!~y~!", 3000, 4);
					}
				}
				/*case 4: //slot 5
				{
					pData[playerid][toySelected] = 4;
					if(pToys[playerid][4][toy_model] == 0)
					{
						//ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						new string[512];
						format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
						pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
						pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
						//ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos", "Select", "Cancel");
					}
				}
				case 5: //slot 6
				{
					pData[playerid][toySelected] = 5;
					if(pToys[playerid][5][toy_model] == 0)
					{
						//ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						new string[512];
						format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
						pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
						pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
						//ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos", "Select", "Cancel");
					}
				}*/
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_TOYEDIT)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: // edit
				{
					//if(IsPlayerAndroid(playerid))
					//	return Error(playerid, "You're connected from android. This feature only for PC users!");
						
					EditAttachedObject(playerid, pData[playerid][toySelected]);
					InfoTD_MSG(playerid, 4000, "~b~~h~You are now editing your toy.");
				}
				case 1: // change bone
				{
					new finstring[750];

					strcat(finstring, ""dot"Spine\n"dot"Head\n"dot"Left upper arm\n"dot"Right upper arm\n"dot"Left hand\n"dot"Right hand\n"dot"Left thigh\n"dot"Right tigh\n"dot"Left foot\n"dot"Right foot");
					strcat(finstring, "\n"dot"Right calf\n"dot"Left calf\n"dot"Left forearm\n"dot"Right forearm\n"dot"Left clavicle\n"dot"Right clavicle\n"dot"Neck\n"dot"Jaw");

					ShowPlayerDialog(playerid, DIALOG_TOYPOSISI, DIALOG_STYLE_LIST, ""RED_E"XGRP: "WHITE_E"Player Toys", finstring, "Select", "Cancel");
				}
				case 2: // remove toy
				{
					if(IsPlayerAttachedObjectSlotUsed(playerid, pData[playerid][toySelected]))
					{
						RemovePlayerAttachedObject(playerid, pData[playerid][toySelected]);
					}
					pToys[playerid][pData[playerid][toySelected]][toy_model] = 0;
					GameTextForPlayer(playerid, "~r~~h~Toy Removed~y~!", 3000, 4);
					SetPVarInt(playerid, "UpdatedToy", 1);
					TogglePlayerControllable(playerid, true);
				}
				case 3:	//share toy pos
				{
					SendNearbyMessage(playerid, 10.0, COLOR_GREEN, "[TOY BY %s] "WHITE_E"PosX: %.3f | PosY: %.3f | PosZ: %.3f | PosRX: %.3f | PosRY: %.3f | PosRZ: %.3f",
					ReturnName(playerid), pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
					pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
				}
				case 4: //Pos X
				{
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Current Toy PosX: %f\nInput new Toy PosX:(Float)", pToys[playerid][pData[playerid][toySelected]][toy_x]);
					ShowPlayerDialog(playerid, DIALOG_TOYPOSX, DIALOG_STYLE_INPUT, "Toy PosX", mstr, "Edit", "Cancel");
				}
				case 5: //Pos Y
				{
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Current Toy PosY: %f\nInput new Toy PosY:(Float)", pToys[playerid][pData[playerid][toySelected]][toy_y]);
					ShowPlayerDialog(playerid, DIALOG_TOYPOSY, DIALOG_STYLE_INPUT, "Toy PosY", mstr, "Edit", "Cancel");
				}
				case 6: //Pos Z
				{
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Current Toy PosZ: %f\nInput new Toy PosZ:(Float)", pToys[playerid][pData[playerid][toySelected]][toy_z]);
					ShowPlayerDialog(playerid, DIALOG_TOYPOSZ, DIALOG_STYLE_INPUT, "Toy PosZ", mstr, "Edit", "Cancel");
				}
				case 7: //Pos RX
				{
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Current Toy PosRX: %f\nInput new Toy PosRX:(Float)", pToys[playerid][pData[playerid][toySelected]][toy_rx]);
					ShowPlayerDialog(playerid, DIALOG_TOYPOSRX, DIALOG_STYLE_INPUT, "Toy PosRX", mstr, "Edit", "Cancel");
				}
				case 8: //Pos RY
				{
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Current Toy PosRY: %f\nInput new Toy PosRY:(Float)", pToys[playerid][pData[playerid][toySelected]][toy_ry]);
					ShowPlayerDialog(playerid, DIALOG_TOYPOSRY, DIALOG_STYLE_INPUT, "Toy PosRY", mstr, "Edit", "Cancel");
				}
				case 9: //Pos RZ
				{
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Current Toy PosRZ: %f\nInput new Toy PosRZ:(Float)", pToys[playerid][pData[playerid][toySelected]][toy_rz]);
					ShowPlayerDialog(playerid, DIALOG_TOYPOSRZ, DIALOG_STYLE_INPUT, "Toy PosRZ", mstr, "Edit", "Cancel");
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_TOYPOSISI)
	{
		if(response)
		{
			listitem++;
			pToys[playerid][pData[playerid][toySelected]][toy_bone] = listitem;
			if(IsPlayerAttachedObjectSlotUsed(playerid, pData[playerid][toySelected]))
			{
				RemovePlayerAttachedObject(playerid, pData[playerid][toySelected]);
			}
			listitem = pData[playerid][toySelected];
			SetPlayerAttachedObject(playerid,
					listitem,
					pToys[playerid][listitem][toy_model],
					pToys[playerid][listitem][toy_bone],
					pToys[playerid][listitem][toy_x],
					pToys[playerid][listitem][toy_y],
					pToys[playerid][listitem][toy_z],
					pToys[playerid][listitem][toy_rx],
					pToys[playerid][listitem][toy_ry],
					pToys[playerid][listitem][toy_rz],
					pToys[playerid][listitem][toy_sx],
					pToys[playerid][listitem][toy_sy],
					pToys[playerid][listitem][toy_sz]);
			GameTextForPlayer(playerid, "~g~~h~Bone Changed~y~!", 3000, 4);
			SetPVarInt(playerid, "UpdatedToy", 1);
		}
		return 1;
	}
	if(dialogid == DIALOG_TOYPOSISIBUY)
	{
		if(response)
		{
			listitem++;
			pToys[playerid][pData[playerid][toySelected]][toy_bone] = listitem;
			SetPlayerAttachedObject(playerid, pData[playerid][toySelected], pToys[playerid][pData[playerid][toySelected]][toy_model], listitem);
			//EditAttachedObject(playerid, pData[playerid][toySelected]);
			InfoTD_MSG(playerid, 5000, "~g~~h~Object Attached!~n~~w~Adjust the position than click on the save icon!");
		}
		return 1;
	}
	if(dialogid == DIALOG_TOYBUY)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //slot 1
				{
					pData[playerid][toySelected] = 0;
					if(pToys[playerid][0][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
				case 1: //slot 2
				{
					pData[playerid][toySelected] = 1;
					if(pToys[playerid][1][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
				case 2: //slot 3
				{
					pData[playerid][toySelected] = 2;
					if(pToys[playerid][2][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
				case 3: //slot 4
				{
					pData[playerid][toySelected] = 3;
					if(pToys[playerid][3][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
				case 4: //slot 5
				{
					pData[playerid][toySelected] = 4;
					if(pToys[playerid][4][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
				case 5: //slot 6
				{
					pData[playerid][toySelected] = 5;
					if(pToys[playerid][5][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, toyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_TOYVIP)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //slot 1
				{
					pData[playerid][toySelected] = 0;
					if(pToys[playerid][0][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, viptoyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
				case 1: //slot 2
				{
					pData[playerid][toySelected] = 1;
					if(pToys[playerid][1][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, viptoyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
				case 2: //slot 3
				{
					pData[playerid][toySelected] = 2;
					if(pToys[playerid][2][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, viptoyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
				case 3: //slot 4
				{
					pData[playerid][toySelected] = 3;
					if(pToys[playerid][3][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, viptoyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
				case 4: //slot 5
				{
					pData[playerid][toySelected] = 4;
					if(pToys[playerid][4][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, viptoyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
				case 5: //slot 6
				{
					pData[playerid][toySelected] = 5;
					if(pToys[playerid][5][toy_model] == 0)
					{
						ShowModelSelectionMenu(playerid, viptoyslist, "Select Toy", 0x4A5A6BBB, 0x282828FF, 0x4A5A6BBB);
					}
					else
					{
						ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", ""dot"Edit Toy Position\n"dot"Change Bone\n"dot""GREY_E"Remove Toy", "Select", "Cancel");
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_TOYPOSX)
	{
		if(response)
		{
			new Float:posisi = floatstr(inputtext);

			SetPlayerAttachedObject(playerid,
				pData[playerid][toySelected],
				pToys[playerid][pData[playerid][toySelected]][toy_model],
				pToys[playerid][pData[playerid][toySelected]][toy_bone],
				posisi,
				pToys[playerid][pData[playerid][toySelected]][toy_y],
				pToys[playerid][pData[playerid][toySelected]][toy_z],
				pToys[playerid][pData[playerid][toySelected]][toy_rx],
				pToys[playerid][pData[playerid][toySelected]][toy_ry],
				pToys[playerid][pData[playerid][toySelected]][toy_rz],
				pToys[playerid][pData[playerid][toySelected]][toy_sx],
				pToys[playerid][pData[playerid][toySelected]][toy_sy],
				pToys[playerid][pData[playerid][toySelected]][toy_sz]);
			
			pToys[playerid][pData[playerid][toySelected]][toy_x] = posisi;
			SetPVarInt(playerid, "UpdatedToy", 1);
			//MySQL_SavePlayerToys(playerid);
			
			new string[512];
			format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
			pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
			pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
			ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
		}
	}
	if(dialogid == DIALOG_TOYPOSY)
	{
		if(response)
		{
			new Float:posisi = floatstr(inputtext);
			
			SetPlayerAttachedObject(playerid,
				pData[playerid][toySelected],
				pToys[playerid][pData[playerid][toySelected]][toy_model],
				pToys[playerid][pData[playerid][toySelected]][toy_bone],
				pToys[playerid][pData[playerid][toySelected]][toy_x],
				posisi,
				pToys[playerid][pData[playerid][toySelected]][toy_z],
				pToys[playerid][pData[playerid][toySelected]][toy_rx],
				pToys[playerid][pData[playerid][toySelected]][toy_ry],
				pToys[playerid][pData[playerid][toySelected]][toy_rz],
				pToys[playerid][pData[playerid][toySelected]][toy_sx],
				pToys[playerid][pData[playerid][toySelected]][toy_sy],
				pToys[playerid][pData[playerid][toySelected]][toy_sz]);
			
			pToys[playerid][pData[playerid][toySelected]][toy_y] = posisi;
			SetPVarInt(playerid, "UpdatedToy", 1);
			//MySQL_SavePlayerToys(playerid);
			
			new string[512];
			format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
			pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
			pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
			ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
		}
	}
	if(dialogid == DIALOG_TOYPOSZ)
	{
		if(response)
		{
			new Float:posisi = floatstr(inputtext);
			
			SetPlayerAttachedObject(playerid,
				pData[playerid][toySelected],
				pToys[playerid][pData[playerid][toySelected]][toy_model],
				pToys[playerid][pData[playerid][toySelected]][toy_bone],
				pToys[playerid][pData[playerid][toySelected]][toy_x],
				pToys[playerid][pData[playerid][toySelected]][toy_y],
				posisi,
				pToys[playerid][pData[playerid][toySelected]][toy_rx],
				pToys[playerid][pData[playerid][toySelected]][toy_ry],
				pToys[playerid][pData[playerid][toySelected]][toy_rz],
				pToys[playerid][pData[playerid][toySelected]][toy_sx],
				pToys[playerid][pData[playerid][toySelected]][toy_sy],
				pToys[playerid][pData[playerid][toySelected]][toy_sz]);
			
			pToys[playerid][pData[playerid][toySelected]][toy_z] = posisi;
			SetPVarInt(playerid, "UpdatedToy", 1);
			//MySQL_SavePlayerToys(playerid);
			
			new string[512];
			format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
			pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
			pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
			ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
		}
	}
	if(dialogid == DIALOG_TOYPOSRX)
	{
		if(response)
		{
			new Float:posisi = floatstr(inputtext);
			
			SetPlayerAttachedObject(playerid,
				pData[playerid][toySelected],
				pToys[playerid][pData[playerid][toySelected]][toy_model],
				pToys[playerid][pData[playerid][toySelected]][toy_bone],
				pToys[playerid][pData[playerid][toySelected]][toy_x],
				pToys[playerid][pData[playerid][toySelected]][toy_y],
				pToys[playerid][pData[playerid][toySelected]][toy_z],
				posisi,
				pToys[playerid][pData[playerid][toySelected]][toy_ry],
				pToys[playerid][pData[playerid][toySelected]][toy_rz],
				pToys[playerid][pData[playerid][toySelected]][toy_sx],
				pToys[playerid][pData[playerid][toySelected]][toy_sy],
				pToys[playerid][pData[playerid][toySelected]][toy_sz]);
			
			pToys[playerid][pData[playerid][toySelected]][toy_rx] = posisi;
			SetPVarInt(playerid, "UpdatedToy", 1);
			//MySQL_SavePlayerToys(playerid);
			
			new string[512];
			format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
			pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
			pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
			ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
		}
	}
	if(dialogid == DIALOG_TOYPOSRY)
	{
		if(response)
		{
			new Float:posisi = floatstr(inputtext);
			
			SetPlayerAttachedObject(playerid,
				pData[playerid][toySelected],
				pToys[playerid][pData[playerid][toySelected]][toy_model],
				pToys[playerid][pData[playerid][toySelected]][toy_bone],
				pToys[playerid][pData[playerid][toySelected]][toy_x],
				pToys[playerid][pData[playerid][toySelected]][toy_y],
				pToys[playerid][pData[playerid][toySelected]][toy_z],
				pToys[playerid][pData[playerid][toySelected]][toy_rx],
				posisi,
				pToys[playerid][pData[playerid][toySelected]][toy_rz],
				pToys[playerid][pData[playerid][toySelected]][toy_sx],
				pToys[playerid][pData[playerid][toySelected]][toy_sy],
				pToys[playerid][pData[playerid][toySelected]][toy_sz]);
			
			pToys[playerid][pData[playerid][toySelected]][toy_ry] = posisi;
			SetPVarInt(playerid, "UpdatedToy", 1);
			//MySQL_SavePlayerToys(playerid);
			
			new string[512];
			format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
			pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
			pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
			ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
		}
	}
	if(dialogid == DIALOG_TOYPOSRZ)
	{
		if(response)
		{
			new Float:posisi = floatstr(inputtext);
			
			SetPlayerAttachedObject(playerid,
				pData[playerid][toySelected],
				pToys[playerid][pData[playerid][toySelected]][toy_model],
				pToys[playerid][pData[playerid][toySelected]][toy_bone],
				pToys[playerid][pData[playerid][toySelected]][toy_x],
				pToys[playerid][pData[playerid][toySelected]][toy_y],
				pToys[playerid][pData[playerid][toySelected]][toy_z],
				pToys[playerid][pData[playerid][toySelected]][toy_rx],
				pToys[playerid][pData[playerid][toySelected]][toy_ry],
				posisi,
				pToys[playerid][pData[playerid][toySelected]][toy_sx],
				pToys[playerid][pData[playerid][toySelected]][toy_sy],
				pToys[playerid][pData[playerid][toySelected]][toy_sz]);
			
			pToys[playerid][pData[playerid][toySelected]][toy_rz] = posisi;
			SetPVarInt(playerid, "UpdatedToy", 1);
			//MySQL_SavePlayerToys(playerid);
			
			new string[512];
			format(string, sizeof(string), ""dot"Edit Toy Position(PC Only)\n"dot"Change Bone\n"dot""GREY_E"Remove Toy\n"dot"Share Toy Pos\nPosX: %f\nPosY: %f\nPosZ: %f\nPosRX: %f\nPosRY: %f\nPosRZ: %f",
			pToys[playerid][pData[playerid][toySelected]][toy_x], pToys[playerid][pData[playerid][toySelected]][toy_y], pToys[playerid][pData[playerid][toySelected]][toy_z],
			pToys[playerid][pData[playerid][toySelected]][toy_rx], pToys[playerid][pData[playerid][toySelected]][toy_ry], pToys[playerid][pData[playerid][toySelected]][toy_rz]);
			ShowPlayerDialog(playerid, DIALOG_TOYEDIT, DIALOG_STYLE_LIST, ""RED_E"SOI:RP "WHITE_E"Player Toys", string, "Select", "Cancel");
		}
	}
	//-----------[ Player Commands Dialog ]----------
	if(dialogid == DIALOG_HELP)
    {
		if(!response) return 1;
		switch(listitem)
		{
			case 0:
			{
				new str[3500];
				strcat(str, ""LG_E"PLAYER: /help /afk /drag /undrag /pay /stats /items /frisk /use /give /ktp /sim\n");
				strcat(str, ""LB_E"PLAYER: /weapon /settings /mask /helmet /death /accept /deny /buy\n");
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""RED_E"Player", str, "Close", "");
			}
			case 1:
			{
				new str[3500];
				strcat(str, ""LG_E"CHAT: /b /l /s /pm /togpm /w /o /me /ame /do /ado /try\n");
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""RED_E"Chat", str, "Close", "");
			}
			case 2:
			{
				new str[3500];
				strcat(str, ""LG_E"VEHICLE: /v en - Toggle Engine || /v li - Toggle lights\n");
				strcat(str, ""LB_E"VEHICLE: /v hood - Toggle Hood || /v trunk - Toggle Trunk\n");
				strcat(str, ""LG_E"VEHICLE: /v lock - Toggle Lock || /v unlock - Toggle Unlock\n");
				strcat(str, ""LB_E"VEHICLE: /v tow - Tow Vehicle || /v untow - Untow Vehicle\n");
				strcat(str, ""LG_E"VEHICLE: /v park - Save Park || /v my(/mypv) - List Private Vehicle\n");
				strcat(str, ""LG_E"VEHICLE: /v insu - Vehicle Insurance || /claimpv - Claim Insurance\n");
				strcat(str, ""LG_E"VEHICLE: /buyplate - Buy Plate || /buyinsu - Buy Insurance\n");
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""RED_E"Vehicle", str, "Close", "");
			}
			case 3:
			{
				new line1[1200], line3[500];
				strcat(line3, ""LB_E"1. Taxi Driver\n");
				strcat(line3, ""WHITE_E"\t/taxiduty /fare\n");
				strcat(line3, ""WHITE_E"Setiap On Duty per menit, anda akan digaji pada saat paycheck.\n\n");
				strcat(line3, ""LB_E"2. Mechanic\n");
				strcat(line3, ""WHITE_E"\t/mechduty /service\n\n");
				strcat(line3, ""LB_E"3. Lumberjack\n");
				strcat(line3, ""WHITE_E"\t/(lum)ber\n\n");
				strcat(line3, ""LB_E"4. Trucker\n");
				strcat(line3, ""WHITE_E"\t/mission /storeproduct /hauling /storegas /gps\n\n");
				strcat(line3, ""LB_E"5. Miner\n");
				strcat(line3, ""WHITE_E"\t/ore\n\n");
				strcat(line3, ""LB_E"6. Production\n");
				strcat(line3, ""WHITE_E"\t/createproduct /sellproduct\n\n");
				strcat(line3, ""LB_E"7. Farmer\n");
				strcat(line3, ""WHITE_E"\t/plant /price /offer\n\n");
				format(line1, sizeof(line1), "%s", line3);
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Job Help", line1, "OK", "");
				return 1;
			}
			case 4:
			{
				return callcmd::factionhelp(playerid);
			}
			case 5:
			{
				
			}
			case 6:
			{
				new str[3500];
				strcat(str, ""LG_E"BISNIS: /buy /bm /lockbisnis /unlockbisnis /mybis\n");
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""RED_E"Chat", str, "Close", "");
			}
			case 7:
			{
				new str[3500];
				strcat(str, ""LG_E"HOUSE: /buy /storage /lockhouse /unlockhouse /myhouse\n");
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""RED_E"Chat", str, "Close", "");
			}
			case 8:
			{
				return callcmd::donate(playerid);
			}
			case 9:
			{
				return callcmd::credits(playerid);
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_GPS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					DisablePlayerCheckpoint(playerid);
					DisablePlayerRaceCheckpoint(playerid);
				}
				case 1:
				{
					return callcmd::myhouse(playerid);
				}
				case 2:
				{
					return callcmd::mybis(playerid);
				}
				case 3:
				{
					return callcmd::v(playerid, "my");
				}
				case 4:
				{
					if(pData[playerid][pMission] == -1) return Error(playerid, "You dont have mission.");
					new bid = pData[playerid][pMission];
					Info(playerid, "Follow the mission checkpoint to find your bisnis mission location.");
					//SetPlayerCheckpoint(playerid, bData[bid][bExtpos][0], bData[bid][bExtpos][1], bData[bid][bExtpos][2], 3.5);
					SetPlayerRaceCheckpoint(playerid,1, bData[bid][bExtposX], bData[bid][bExtposY], bData[bid][bExtposZ], 0.0, 0.0, 0.0, 3.5);
				}
				case 5:
				{
					if(pData[playerid][pHauling] == -1) return Error(playerid, "You dont have hauling.");
					new id = pData[playerid][pHauling];
					Info(playerid, "Follow the hauling checkpoint to find your gas station location.");
					//SetPlayerCheckpoint(playerid, bData[bid][bExtpos][0], bData[bid][bExtpos][1], bData[bid][bExtpos][2], 3.5);
					SetPlayerRaceCheckpoint(playerid,1, gsData[id][gsPosX], gsData[id][gsPosY], gsData[id][gsPosZ], 0.0, 0.0, 0.0, 3.5);
				}
				case 6:
				{
					SetPlayerRaceCheckpoint(playerid,1, 1481.16, -1771.32, 18.79, 0.0, 0.0, 0.0, 3.5);
					Info(playerid, "GPS active! follow the checkpoint.");
				}
				case 7:
				{
					SetPlayerRaceCheckpoint(playerid,1, 1464.98, -1011.79, 26.84, 0.0, 0.0, 0.0, 3.5);
					Info(playerid, "GPS active! follow the checkpoint.");
				}
				case 8:
				{
					SetPlayerRaceCheckpoint(playerid,1, 1786.53, -1784.83, 13.60, 0.0, 0.0, 0.0, 3.5);
					Info(playerid, "GPS active! follow the checkpoint.");
				}
				case 9:
				{
					ShowPlayerDialog(playerid, DIALOG_GPS_JOB, DIALOG_STYLE_LIST, "GPS JOB", "Taxi\nMechanic\nLumber Jack\nTrucker\nMiner\nProduction\nFarmer\nSweeper(Side Job)\nBus(Side Job)", "Select", "Close");
				}
				case 10:
				{
				    SetPlayerRaceCheckpoint(playerid, 1, 797.6823, -617.5379, 16.3359, 0.0, 0.0, 0.0, 3.5);
				    Info(playerid, "GPS active! follow the checkpoint.");
				}
			}
		}
	}
	if(dialogid == DIALOG_GPS_JOB)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					SetPlayerRaceCheckpoint(playerid,1, 1753.46, -1893.96, 13.55, 0.0,0.0,0.0, 3.5); //Taxi
					Info(playerid, "GPS active! follow the checkpoint.");
				}
				case 1:
				{
					SetPlayerRaceCheckpoint(playerid,1, 1627.54, -1785.21, 13.52, 0.0, 0.0, 0.0, 3.5); //Mechanic
					Info(playerid, "GPS active! follow the checkpoint.");
				}
				case 2:
				{
					SetPlayerRaceCheckpoint(playerid,1, -265.81, -2213.57, 29.04, 0.0, 0.0, 0.0, 3.5); //Lumber
					Info(playerid, "GPS active! follow the checkpoint.");
					
				}
				case 3:
				{
					SetPlayerRaceCheckpoint(playerid,1, -77.38, -1136.52, 1.07, 0.0, 0.0, 0.0, 3.5); //Trucker
					Info(playerid, "GPS active! follow the checkpoint.");
				}
				case 4:
				{
					SetPlayerRaceCheckpoint(playerid,1, 319.94, 874.77, 20.39, 0.0, 0.0, 0.0, 3.5); //Miner
					Info(playerid, "GPS active! follow the checkpoint.");
				}
				case 5:
				{
					SetPlayerRaceCheckpoint(playerid,1, -283.02, -2174.36, 28.66, 0.0, 0.0, 0.0, 3.5); //Production
					Info(playerid, "GPS active! follow the checkpoint.");
				}
				case 6:
				{
					SetPlayerRaceCheckpoint(playerid,1, -382.68, -1438.80, 26.13, 0.0, 0.0, 0.0, 3.5); //Farmer
					Info(playerid, "GPS active! follow the checkpoint.");
				}
				case 7:
				{
					SetPlayerRaceCheckpoint(playerid,1, 1296.80, -1870.97, 13.54, 0.0, 0.0, 0.0, 3.5); //Swpper
					Info(playerid, "GPS active! follow the checkpoint.");
					
				}
				case 8:
				{
					SetPlayerRaceCheckpoint(playerid,1, 1699.25, -1513.80, 13.38, 0.0, 0.0, 0.0, 3.5); //Bus
					Info(playerid, "GPS active! follow the checkpoint.");
					
				}
			}
		}
	}
	if(dialogid == DIALOG_PAY)
	{
		if(response)
		{
			new mstr[128];
			new otherid = GetPVarInt(playerid, "gcPlayer");
			new money = GetPVarInt(playerid, "gcAmount");

			if(otherid == INVALID_PLAYER_ID)
				return Error(playerid, "Player not connected!");
			GivePlayerMoneyEx(otherid, money);
			GivePlayerMoneyEx(playerid, -money);

			format(mstr, sizeof(mstr), "Server: "YELLOW_E"You have sent %s(%i) "GREEN_E"%s", ReturnName(otherid), otherid, FormatMoney(money));
			SendClientMessage(playerid, COLOR_GREY, mstr);
			format(mstr, sizeof(mstr), "Server: "YELLOW_E"%s(%i) has sent you "GREEN_E"%s", ReturnName(playerid), playerid, FormatMoney(money));
			SendClientMessage(otherid, COLOR_GREY, mstr);
			InfoTD_MSG(playerid, 3500, "~g~~h~Money Sent!");
			InfoTD_MSG(otherid, 3500, "~g~~h~Money received!");
			ApplyAnimation(playerid, "DEALER", "shop_pay", 4.0, 0, 0, 0, 0, 0);
			ApplyAnimation(otherid, "DEALER", "shop_pay", 4.0, 0, 0, 0, 0, 0);
			
			new query[512];
			mysql_format(g_SQL, query, sizeof(query), "INSERT INTO logpay (player,playerid,toplayer,toplayerid,ammount,time) VALUES('%s','%d','%s','%d','%d',UNIX_TIMESTAMP())", pData[playerid][pName], pData[playerid][pID], pData[otherid][pName], pData[otherid][pID], money);
			mysql_tquery(g_SQL, query);
		}
		return 1;
	}
	//-------------[ Player Weapons Atth ]-----------
	if(dialogid == DIALOG_EDITBONE)
	{
		if(response)
		{
			new weaponid = EditingWeapon[playerid], weaponname[18], string[150];
	 
			GetWeaponName(weaponid, weaponname, sizeof(weaponname));
		   
			WeaponSettings[playerid][weaponid - 22][Bone] = listitem + 1;

			Servers(playerid, "You have successfully changed the bone of your %s.", weaponname);
		   
			mysql_format(g_SQL, string, sizeof(string), "INSERT INTO weaponsettings (Owner, WeaponID, Bone) VALUES ('%d', %d, %d) ON DUPLICATE KEY UPDATE Bone = VALUES(Bone)", pData[playerid][pID], weaponid, listitem + 1);
			mysql_tquery(g_SQL, string);
		}
		EditingWeapon[playerid] = 0;
	}
	//------------[ Family Dialog ]------------
	if(dialogid == FAMILY_SAFE)
	{
		if(!response) return 1;
		new fid = pData[playerid][pFamily];
		switch(listitem) 
		{
			case 0: Family_OpenStorage(playerid, fid);
			case 1:
			{
				//Marijuana
				ShowPlayerDialog(playerid, FAMILY_MARIJUANA, DIALOG_STYLE_LIST, "Marijuana", "Withdraw from safe\nDeposit into safe", "Select", "Back");
			}
			case 2:
			{
				//Component
				ShowPlayerDialog(playerid, FAMILY_COMPONENT, DIALOG_STYLE_LIST, "Component", "Withdraw from safe\nDeposit into safe", "Select", "Back");
			}
			case 3:
			{
				//Material
				ShowPlayerDialog(playerid, FAMILY_MATERIAL, DIALOG_STYLE_LIST, "Material", "Withdraw from safe\nDeposit into safe", "Select", "Back");
			}
			case 4:
			{
				//Money
				ShowPlayerDialog(playerid, FAMILY_MONEY, DIALOG_STYLE_LIST, "Money", "Withdraw from safe\nDeposit into safe", "Select", "Back");
			}
		}
		return 1;
	}
	if(dialogid == FAMILY_STORAGE)
	{
		new fid = pData[playerid][pFamily];
		if(response)
		{
			if(listitem == 0) 
			{
				Family_WeaponStorage(playerid, fid);
			}
		}
		return 1;
	}
	if(dialogid == FAMILY_WEAPONS)
	{
		new fid = pData[playerid][pFamily];
		if(response)
		{
			if(fData[fid][fGun][listitem] != 0)
			{
				if(pData[playerid][pFamilyRank] < 5)
					return Error(playerid, "Only boss can taken the weapon!");
					
				GivePlayerWeaponEx(playerid, fData[fid][fGun][listitem], fData[fid][fAmmo][listitem]);

				SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has taken a \"%s\" from their weapon storage.", ReturnName(playerid), ReturnWeaponName(fData[fid][fGun][listitem]));

				fData[fid][fGun][listitem] = 0;
				fData[fid][fAmmo][listitem] = 0;

				Family_Save(fid);
				Family_WeaponStorage(playerid, fid);
			}
			else
			{
				new
					weaponid = GetPlayerWeaponEx(playerid),
					ammo = GetPlayerAmmoEx(playerid);

				if(!weaponid)
					return Error(playerid, "You are not holding any weapon!");

				/*if(weaponid == 23 && pData[playerid][pTazer])
					return Error(playerid, "You can't store a tazer into your safe.");

				if(weaponid == 25 && pData[playerid][pBeanBag])
					return Error(playerid, "You can't store a beanbag shotgun into your safe.");*/

				ResetWeapon(playerid, weaponid);
				SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has stored a \"%s\" into their weapon storage.", ReturnName(playerid), ReturnWeaponName(weaponid));

				fData[fid][fGun][listitem] = weaponid;
				fData[fid][fAmmo][listitem] = ammo;

				Family_Save(fid);
				Family_WeaponStorage(playerid, fid);
			}
		}
		else
		{
			Family_OpenStorage(playerid, fid);
		}
		return 1;
	}
	if(dialogid == FAMILY_MARIJUANA)
	{
		if(response)
		{
			new fid = pData[playerid][pFamily];
			if(fid == -1) return Error(playerid, "You don't have family.");
			if(response)
			{
				switch (listitem)
				{
					case 0: 
					{
						if(pData[playerid][pFamilyRank] < 5)
							return Error(playerid, "Only boss can withdraw marijuana!");
							
						new str[128];
						format(str, sizeof(str), "Marijuana Balance: %d\n\nPlease enter how much marijuana you wish to withdraw from the safe:", fData[fid][fMarijuana]);
						ShowPlayerDialog(playerid, FAMILY_WITHDRAWMARIJUANA, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
					}
					case 1: 
					{
						new str[128];
						format(str, sizeof(str), "Marijuana Balance: %d\n\nPlease enter how much marijuana you wish to deposit into the safe:", fData[fid][fMarijuana]);
						ShowPlayerDialog(playerid, FAMILY_DEPOSITMARIJUANA, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
					}
				}
			}
			else callcmd::fsafe(playerid);
		}
		return 1;
	}
	if(dialogid == FAMILY_WITHDRAWMARIJUANA)
	{
		new fid = pData[playerid][pFamily];
		if(fid == -1) return Error(playerid, "You don't have family.");
		
		if(response)
		{
			new amount = strval(inputtext);

			if(isnull(inputtext))
			{
				new str[128];
				format(str, sizeof(str), "Marijuana Balance: %d\n\nPlease enter how much marijuana you wish to withdraw from the safe:", fData[fid][fMarijuana]);
				ShowPlayerDialog(playerid, FAMILY_WITHDRAWMARIJUANA, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				return 1;
			}
			if(amount < 1 || amount > fData[fid][fMarijuana])
			{
				new str[128];
				format(str, sizeof(str), "Error: Insufficient funds.\n\nMarijuana Balance: %d\n\nPlease enter how much marijuana you wish to withdraw from the safe:", fData[fid][fMarijuana]);
				ShowPlayerDialog(playerid, FAMILY_WITHDRAWMARIJUANA, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				return 1;
			}
			fData[fid][fMarijuana] -= amount;
			pData[playerid][pMarijuana] += amount;

			Family_Save(fid);
			SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has withdrawn %d marijuana from their family safe.", ReturnName(playerid), amount);
			callcmd::fsafe(playerid);
			return 1;
		}
		else callcmd::fsafe(playerid);
		return 1;
	}
	if(dialogid == FAMILY_DEPOSITMARIJUANA)
	{
		new fid = pData[playerid][pFamily];
		if(fid == -1) return Error(playerid, "You don't have family.");
		if(response)
		{
			new amount = strval(inputtext);

			if(isnull(inputtext))
			{
				new str[128];
				format(str, sizeof(str), "Marijuana Balance: %d\n\nPlease enter how much marijuana you wish to deposit into the safe:", fData[fid][fMarijuana]);
				ShowPlayerDialog(playerid, FAMILY_DEPOSITMARIJUANA, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				return 1;
			}
			if(amount < 1 || amount > pData[playerid][pMarijuana])
			{
				new str[128];
				format(str, sizeof(str), "Error: Insufficient funds.\n\nMarijuana Balance: %d\n\nPlease enter how much marijuana you wish to deposit into the safe:", fData[fid][fMarijuana]);
				ShowPlayerDialog(playerid, FAMILY_DEPOSITMARIJUANA, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				return 1;
			}
			fData[fid][fMarijuana] += amount;
			pData[playerid][pMarijuana] -= amount;

			Family_Save(fid);
			SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has deposited %d marijuana into their family safe.", ReturnName(playerid), amount);
		}
		else callcmd::fsafe(playerid);
		return 1;
	}
	if(dialogid == FAMILY_COMPONENT)
	{
		if(response)
		{
			new fid = pData[playerid][pFamily];
			if(fid == -1) return Error(playerid, "You don't have family.");
			if(response)
			{
				switch (listitem)
				{
					case 0: 
					{
						if(pData[playerid][pFamilyRank] < 5)
							return Error(playerid, "Only boss can withdraw component!");
							
						new str[128];
						format(str, sizeof(str), "Component Balance: %d\n\nPlease enter how much component you wish to withdraw from the safe:", fData[fid][fComponent]);
						ShowPlayerDialog(playerid, FAMILY_WITHDRAWCOMPONENT, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
					}
					case 1: 
					{
						new str[128];
						format(str, sizeof(str), "Component Balance: %d\n\nPlease enter how much component you wish to deposit into the safe:", fData[fid][fComponent]);
						ShowPlayerDialog(playerid, FAMILY_DEPOSITCOMPONENT, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
					}
				}
			}
			else callcmd::fsafe(playerid);
		}
		return 1;
	}
	if(dialogid == FAMILY_WITHDRAWCOMPONENT)
	{
		new fid = pData[playerid][pFamily];
		if(fid == -1) return Error(playerid, "You don't have family.");
		
		if(response)
		{
			new amount = strval(inputtext);

			if(isnull(inputtext))
			{
				new str[128];
				format(str, sizeof(str), "Component Balance: %d\n\nPlease enter how much component you wish to withdraw from the safe:", fData[fid][fComponent]);
				ShowPlayerDialog(playerid, FAMILY_WITHDRAWCOMPONENT, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				return 1;
			}
			if(amount < 1 || amount > fData[fid][fComponent])
			{
				new str[128];
				format(str, sizeof(str), "Error: Insufficient funds.\n\nComponent Balance: %d\n\nPlease enter how much component you wish to withdraw from the safe:", fData[fid][fComponent]);
				ShowPlayerDialog(playerid, FAMILY_WITHDRAWCOMPONENT, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				return 1;
			}
			fData[fid][fComponent] -= amount;
			pData[playerid][pComponent] += amount;

			Family_Save(fid);
			SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has withdrawn %d component from their family safe.", ReturnName(playerid), amount);
			callcmd::fsafe(playerid);
			return 1;
		}
		else callcmd::fsafe(playerid);
		return 1;
	}
	if(dialogid == FAMILY_DEPOSITCOMPONENT)
	{
		new fid = pData[playerid][pFamily];
		if(fid == -1) return Error(playerid, "You don't have family.");
		if(response)
		{
			new amount = strval(inputtext);

			if(isnull(inputtext))
			{
				new str[128];
				format(str, sizeof(str), "Component Balance: %d\n\nPlease enter how much component you wish to deposit into the safe:", fData[fid][fComponent]);
				ShowPlayerDialog(playerid, FAMILY_DEPOSITCOMPONENT, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				return 1;
			}
			if(amount < 1 || amount > pData[playerid][pComponent])
			{
				new str[128];
				format(str, sizeof(str), "Error: Insufficient funds.\n\nComponent Balance: %d\n\nPlease enter how much component you wish to deposit into the safe:", fData[fid][fComponent]);
				ShowPlayerDialog(playerid, FAMILY_DEPOSITCOMPONENT, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				return 1;
			}
			fData[fid][fComponent] += amount;
			pData[playerid][pComponent] -= amount;

			Family_Save(fid);
			SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has deposited %d component into their family safe.", ReturnName(playerid), amount);
		}
		else callcmd::fsafe(playerid);
		return 1;
	}
	if(dialogid == FAMILY_MATERIAL)
	{
		if(response)
		{
			new fid = pData[playerid][pFamily];
			if(fid == -1) return Error(playerid, "You don't have family.");
			if(response)
			{
				switch (listitem)
				{
					case 0: 
					{
						if(pData[playerid][pFamilyRank] < 5)
							return Error(playerid, "Only boss can withdraw material!");
							
						new str[128];
						format(str, sizeof(str), "Material Balance: %d\n\nPlease enter how much material you wish to withdraw from the safe:", fData[fid][fMaterial]);
						ShowPlayerDialog(playerid, FAMILY_WITHDRAWMATERIAL, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
					}
					case 1: 
					{
						new str[128];
						format(str, sizeof(str), "Material Balance: %d\n\nPlease enter how much material you wish to deposit into the safe:", fData[fid][fMaterial]);
						ShowPlayerDialog(playerid, FAMILY_DEPOSITMATERIAL, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
					}
				}
			}
			else callcmd::fsafe(playerid);
		}
		return 1;
	}
	if(dialogid == FAMILY_WITHDRAWMATERIAL)
	{
		new fid = pData[playerid][pFamily];
		if(fid == -1) return Error(playerid, "You don't have family.");
		
		if(response)
		{
			new amount = strval(inputtext);

			if(isnull(inputtext))
			{
				new str[128];
				format(str, sizeof(str), "Material Balance: %d\n\nPlease enter how much material you wish to withdraw from the safe:", fData[fid][fMaterial]);
				ShowPlayerDialog(playerid, FAMILY_WITHDRAWMATERIAL, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				return 1;
			}
			if(amount < 1 || amount > fData[fid][fMaterial])
			{
				new str[128];
				format(str, sizeof(str), "Error: Insufficient funds.\n\nMaterial Balance: %d\n\nPlease enter how much material you wish to withdraw from the safe:", fData[fid][fMaterial]);
				ShowPlayerDialog(playerid, FAMILY_WITHDRAWMATERIAL, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				return 1;
			}
			fData[fid][fMaterial] -= amount;
			pData[playerid][pMaterial] += amount;

			Family_Save(fid);
			SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has withdrawn %d material from their family safe.", ReturnName(playerid), amount);
			callcmd::fsafe(playerid);
			return 1;
		}
		else callcmd::fsafe(playerid);
		return 1;
	}
	if(dialogid == FAMILY_DEPOSITMATERIAL)
	{
		new fid = pData[playerid][pFamily];
		if(fid == -1) return Error(playerid, "You don't have family.");
		if(response)
		{
			new amount = strval(inputtext);

			if(isnull(inputtext))
			{
				new str[128];
				format(str, sizeof(str), "Material Balance: %d\n\nPlease enter how much material you wish to deposit into the safe:", fData[fid][fMaterial]);
				ShowPlayerDialog(playerid, FAMILY_DEPOSITMATERIAL, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				return 1;
			}
			if(amount < 1 || amount > pData[playerid][pMaterial])
			{
				new str[128];
				format(str, sizeof(str), "Error: Insufficient funds.\n\nMaterial Balance: %d\n\nPlease enter how much material you wish to deposit into the safe:", fData[fid][fMaterial]);
				ShowPlayerDialog(playerid, FAMILY_DEPOSITMATERIAL, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				return 1;
			}
			fData[fid][fMaterial] += amount;
			pData[playerid][pMaterial] -= amount;

			Family_Save(fid);
			SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has deposited %d material into their family safe.", ReturnName(playerid), amount);
		}
		else callcmd::fsafe(playerid);
		return 1;
	}
	if(dialogid == FAMILY_MONEY)
	{
		if(response)
		{
			new fid = pData[playerid][pFamily];
			if(fid == -1) return Error(playerid, "You don't have family.");
			if(response)
			{
				switch (listitem)
				{
					case 0: 
					{
						if(pData[playerid][pFamilyRank] < 5)
							return Error(playerid, "Only boss can withdraw money!");
							
						new str[128];
						format(str, sizeof(str), "Money Balance: %s\n\nPlease enter how much money you wish to withdraw from the safe:", FormatMoney(fData[fid][fMoney]));
						ShowPlayerDialog(playerid, FAMILY_WITHDRAWMONEY, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
					}
					case 1: 
					{
						new str[128];
						format(str, sizeof(str), "Money Balance: %s\n\nPlease enter how much money you wish to deposit into the safe:", FormatMoney(fData[fid][fMoney]));
						ShowPlayerDialog(playerid, FAMILY_DEPOSITMONEY, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
					}
				}
			}
			else callcmd::fsafe(playerid);
		}
		return 1;
	}
	if(dialogid == FAMILY_WITHDRAWMONEY)
	{
		new fid = pData[playerid][pFamily];
		if(fid == -1) return Error(playerid, "You don't have family.");
		
		if(response)
		{
			new amount = strval(inputtext);

			if(isnull(inputtext))
			{
				new str[128];
				format(str, sizeof(str), "Money Balance: %s\n\nPlease enter how much money you wish to withdraw from the safe:", FormatMoney(fData[fid][fMoney]));
				ShowPlayerDialog(playerid, FAMILY_WITHDRAWMONEY, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				return 1;
			}
			if(amount < 1 || amount > fData[fid][fMoney])
			{
				new str[128];
				format(str, sizeof(str), "Error: Insufficient funds.\n\nMoney Balance: %s\n\nPlease enter how much money you wish to withdraw from the safe:", FormatMoney(fData[fid][fMoney]));
				ShowPlayerDialog(playerid, FAMILY_WITHDRAWMONEY, DIALOG_STYLE_INPUT, "Withdraw from safe", str, "Withdraw", "Back");
				return 1;
			}
			fData[fid][fMoney] -= amount;
			GivePlayerMoneyEx(playerid, amount);

			Family_Save(fid);
			SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has withdrawn %s money from their family safe.", ReturnName(playerid), FormatMoney(amount));
			callcmd::fsafe(playerid);
			return 1;
		}
		else callcmd::fsafe(playerid);
		return 1;
	}
	if(dialogid == FAMILY_DEPOSITMONEY)
	{
		new fid = pData[playerid][pFamily];
		if(fid == -1) return Error(playerid, "You don't have family.");
		if(response)
		{
			new amount = strval(inputtext);

			if(isnull(inputtext))
			{
				new str[128];
				format(str, sizeof(str), "Money Balance: %s\n\nPlease enter how much money you wish to deposit into the safe:", FormatMoney(fData[fid][fMoney]));
				ShowPlayerDialog(playerid, FAMILY_DEPOSITMATERIAL, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				return 1;
			}
			if(amount < 1 || amount > GetPlayerMoney(playerid))
			{
				new str[128];
				format(str, sizeof(str), "Error: Insufficient funds.\n\nMoney Balance: %s\n\nPlease enter how much money you wish to deposit into the safe:", FormatMoney(fData[fid][fMoney]));
				ShowPlayerDialog(playerid, FAMILY_DEPOSITMATERIAL, DIALOG_STYLE_INPUT, "Deposit into safe", str, "Deposit", "Back");
				return 1;
			}
			fData[fid][fMoney] += amount;
			GivePlayerMoneyEx(playerid, -amount);

			Family_Save(fid);
			SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s has deposited %s money into their family safe.", ReturnName(playerid), FormatMoney(amount));
		}
		else callcmd::fsafe(playerid);
		return 1;
	}
	if(dialogid == FAMILY_INFO)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(pData[playerid][pFamily] == -1)
						return Error(playerid, "You dont have family!");
					new query[512];
					mysql_format(g_SQL, query, sizeof(query), "SELECT name,leader,marijuana,component,material,money FROM familys WHERE ID = %d", pData[playerid][pFamily]);
					mysql_tquery(g_SQL, query, "ShowFamilyInfo", "i", playerid);
				}
				case 1:
				{
					if(pData[playerid][pFamily] == -1)
						return Error(playerid, "You dont have family!");
						
					new lstr[1024];
					format(lstr, sizeof(lstr), "Rank\tName\n");
					foreach(new i: Player)
					{
						if(pData[i][pFamily] == pData[playerid][pFamily])
						{
							format(lstr, sizeof(lstr), "%s%s\t%s(%d)", lstr, GetFamilyRank(i), pData[i][pName], i);
							format(lstr, sizeof(lstr), "%s\n", lstr);
						}
					}
					format(lstr, sizeof(lstr), "%s\n", lstr);
					ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_TABLIST_HEADERS, "Family Online", lstr, "Close", "");
					
				}
				case 2:
				{
					if(pData[playerid][pFamily] == -1)
						return Error(playerid, "You dont have family!");
					new query[512];
					mysql_format(g_SQL, query, sizeof(query), "SELECT username,familyrank FROM players WHERE family = %d", pData[playerid][pFamily]);
					mysql_tquery(g_SQL, query, "ShowFamilyMember", "i", playerid);
				}
			}
		}
		return 1;
	}
	//------------[ VIP Locker Dialog ]----------
	if(dialogid == DIALOG_LOCKERVIP)
	{
		if(response)
		{
			switch (listitem) 
			{
				case 0: 
				{
					SetPlayerHealthEx(playerid, 100);
				}
				case 1:
				{
					GivePlayerWeaponEx(playerid, 1, 1);
					GivePlayerWeaponEx(playerid, 7, 1);
					GivePlayerWeaponEx(playerid, 15, 1);
				}
				case 2:
				{
					switch (pData[playerid][pGender])
					{
						case 1: ShowModelSelectionMenu(playerid, VIPMaleSkins, "Choose your skin");
						case 2: ShowModelSelectionMenu(playerid, VIPFemaleSkins, "Choose your skin");
					}
				}
				case 3:
				{
					new string[248];
					if(pToys[playerid][0][toy_model] == 0)
					{
						strcat(string, ""dot"Slot 1\n");
					}
					else strcat(string, ""dot"Slot 1 "RED_E"(Used)\n");

					if(pToys[playerid][1][toy_model] == 0)
					{
						strcat(string, ""dot"Slot 2\n");
					}
					else strcat(string, ""dot"Slot 2 "RED_E"(Used)\n");

					if(pToys[playerid][2][toy_model] == 0)
					{
						strcat(string, ""dot"Slot 3\n");
					}
					else strcat(string, ""dot"Slot 3 "RED_E"(Used)\n");

					if(pToys[playerid][3][toy_model] == 0)
					{
						strcat(string, ""dot"Slot 4\n");
					}
					else strcat(string, ""dot"Slot 4 "RED_E"(Used)\n");

					/*if(pToys[playerid][4][toy_model] == 0)
					{
						strcat(string, ""dot"Slot 5\n");
					}
					else strcat(string, ""dot"Slot 5 "RED_E"(Used)\n");

					if(pToys[playerid][5][toy_model] == 0)
					{
						strcat(string, ""dot"Slot 6\n");
					}
					else strcat(string, ""dot"Slot 6 "RED_E"(Used)\n");*/

					ShowPlayerDialog(playerid, DIALOG_TOYVIP, DIALOG_STYLE_LIST, ""RED_E"SoI:RP "WHITE_E"VIP Toys", string, "Select", "Cancel");
				}
			}
		}
	}
	//-------------[ Faction Commands Dialog ]-----------
	if(dialogid == DIALOG_LOCKERSAPD)
	{
		if(response)
		{
			switch (listitem) 
			{
				case 0: 
				{
					if(pData[playerid][pOnDuty] == 1)
					{
						pData[playerid][pOnDuty] = 0;
						SetPlayerColor(playerid, COLOR_WHITE);
						SetPlayerSkin(playerid, pData[playerid][pSkin]);
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s places their badge and gun in their locker.", ReturnName(playerid));
						ResetWeapon(playerid, 25);
						ResetWeapon(playerid, 27);
						ResetWeapon(playerid, 29);
						ResetWeapon(playerid, 31);
						ResetWeapon(playerid, 33);
						ResetWeapon(playerid, 34);
					}
					else
					{
						pData[playerid][pOnDuty] = 1;
						SetFactionColor(playerid);
						if(pData[playerid][pGender] == 1)
						{
							SetPlayerSkin(playerid, 300);
							pData[playerid][pFacSkin] = 300;
						}
						else
						{
							SetPlayerSkin(playerid, 306);
							pData[playerid][pFacSkin] = 306;
						}
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s withdraws their badge and on duty from their locker", ReturnName(playerid));
					}
				}
				case 1: 
				{
					SetPlayerHealthEx(playerid, 100);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s telah mengambil medical kit dari locker", ReturnName(playerid));
				}
				case 2:
				{
					SetPlayerArmourEx(playerid, 97);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s telah mengambil armour pelindung dari locker", ReturnName(playerid));
				}
				case 3:
				{
					if(pData[playerid][pOnDuty] <= 0)
						return Error(playerid, "Kamu harus On duty untuk mengambil barang!");
						
					ShowPlayerDialog(playerid, DIALOG_WEAPONSAPD, DIALOG_STYLE_LIST, "SAPD Weapons", "SPRAYCAN\nPARACHUTE\nNITE STICK\nKNIFE\nCOLT45\nSILENCED\nDEAGLE\nSHOTGUN\nSHOTGSPA\nMP5\nM4\nRIFLE\nSNIPER", "Pilih", "Batal");
				}
				case 4:
				{
					if(pData[playerid][pOnDuty] <= 0)
						return Error(playerid, "Kamu harus On duty untuk mengambil barang!");
					
					switch (pData[playerid][pGender])
					{
						case 1: ShowModelSelectionMenu(playerid, SAPDMale, "Choose your skin");
						case 2: ShowModelSelectionMenu(playerid, SAPDFemale, "Choose your skin");
					}
				}
				case 5:
				{
					if(pData[playerid][pOnDuty] <= 0)
						return Error(playerid, "Kamu harus On duty untuk mengambil barang!");
					if(pData[playerid][pFactionRank] < 3)
						return Error(playerid, "You are not allowed!");
					
					switch (pData[playerid][pGender])
					{
						case 1: ShowModelSelectionMenu(playerid, SAPDWar, "Choose your skin");
						case 2: ShowModelSelectionMenu(playerid, SAPDFemale, "Choose your skin");
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_WEAPONSAPD)
	{
		if(response)
		{
			switch (listitem) 
			{
				case 0:
				{
					GivePlayerWeaponEx(playerid, 41, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(41));
				}
				case 1:
				{
					GivePlayerWeaponEx(playerid, 46, 1);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(46));
				}
				case 2:
				{
					GivePlayerWeaponEx(playerid, 3, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(3));
				}
				case 3:
				{
					GivePlayerWeaponEx(playerid, 4, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(4));
				}
				case 4:
				{
					GivePlayerWeaponEx(playerid, 22, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(22));
				}
				case 5:
				{
					if(pData[playerid][pFactionRank] < 2)
						return Error(playerid, "You are not allowed!");
						
					GivePlayerWeaponEx(playerid, 23, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(23));
				}
				case 6:
				{
					if(pData[playerid][pFactionRank] < 2)
						return Error(playerid, "You are not allowed!");
						
					GivePlayerWeaponEx(playerid, 24, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(24));
				}	
				case 7:
				{
					if(pData[playerid][pFactionRank] < 3)
						return Error(playerid, "You are not allowed!");
					GivePlayerWeaponEx(playerid, 25, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(25));
				}
				case 8:
				{
					if(pData[playerid][pFactionRank] < 3)
						return Error(playerid, "You are not allowed!");
					GivePlayerWeaponEx(playerid, 27, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(27));
				}
				case 9:
				{
					if(pData[playerid][pFactionRank] < 3)
						return Error(playerid, "You are not allowed!");
					GivePlayerWeaponEx(playerid, 29, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(29));
				}
				case 10:
				{
					if(pData[playerid][pFactionRank] < 4)
						return Error(playerid, "You are not allowed!");
					GivePlayerWeaponEx(playerid, 31, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(31));
				}
				case 11:
				{
					if(pData[playerid][pFactionRank] < 4)
						return Error(playerid, "You are not allowed!");
					GivePlayerWeaponEx(playerid, 33, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(33));
				}
				case 12:
				{
					if(pData[playerid][pFactionRank] < 4)
						return Error(playerid, "You are not allowed!");
					GivePlayerWeaponEx(playerid, 34, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(34));
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_LOCKERSAGS)
	{
		if(response)
		{
			switch (listitem) 
			{
				case 0: 
				{
					if(pData[playerid][pOnDuty] == 1)
					{
						pData[playerid][pOnDuty] = 0;
						SetPlayerColor(playerid, COLOR_WHITE);
						SetPlayerSkin(playerid, pData[playerid][pSkin]);
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s places their badge and gun in their locker.", ReturnName(playerid));
					}
					else
					{
						pData[playerid][pOnDuty] = 1;
						SetFactionColor(playerid);
						if(pData[playerid][pGender] == 1)
						{
							SetPlayerSkin(playerid, 295);
							pData[playerid][pFacSkin] = 295;
						}
						else
						{
							SetPlayerSkin(playerid, 141);
							pData[playerid][pFacSkin] = 141;
						}
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s withdraws their badge and on duty from their locker", ReturnName(playerid));
					}
				}
				case 1: 
				{
					SetPlayerHealthEx(playerid, 100);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s telah mengambil medical kit dari locker", ReturnName(playerid));
				}
				case 2:
				{
					SetPlayerArmourEx(playerid, 97);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s telah mengambil armour pelindung dari locker", ReturnName(playerid));
				}
				case 3:
				{
					if(pData[playerid][pOnDuty] <= 0)
						return Error(playerid, "Kamu harus On duty untuk mengambil barang!");
						
					ShowPlayerDialog(playerid, DIALOG_WEAPONSAGS, DIALOG_STYLE_LIST, "SAGS Weapons", "SPRAYCAN\nPARACHUTE\nNITE STICK\nKNIFE\nCOLT45\nSILENCED\nDEAGLE\nMP5", "Pilih", "Batal");
				}
				case 4:
				{
					if(pData[playerid][pOnDuty] <= 0)
						return Error(playerid, "Kamu harus On duty untuk mengambil barang!");
					switch (pData[playerid][pGender])
					{
						case 1: ShowModelSelectionMenu(playerid, SAGSMale, "Choose your skin");
						case 2: ShowModelSelectionMenu(playerid, SAGSFemale, "Choose your skin");
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_WEAPONSAGS)
	{
		if(response)
		{
			switch (listitem) 
			{
				case 0:
				{
					GivePlayerWeaponEx(playerid, 41, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(41));
				}
				case 1:
				{
					GivePlayerWeaponEx(playerid, 46, 1);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(46));
				}
				case 2:
				{
					GivePlayerWeaponEx(playerid, 3, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(3));
				}
				case 3:
				{
					GivePlayerWeaponEx(playerid, 4, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(4));
				}
				case 4:
				{
					GivePlayerWeaponEx(playerid, 22, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(22));
				}
				case 5:
				{
					if(pData[playerid][pFactionRank] < 2)
						return Error(playerid, "You are not allowed!");
						
					GivePlayerWeaponEx(playerid, 23, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(23));
				}
				case 6:
				{
					if(pData[playerid][pFactionRank] < 3)
						return Error(playerid, "You are not allowed!");
						
					GivePlayerWeaponEx(playerid, 24, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(24));
				}	
				case 7:
				{
					if(pData[playerid][pFactionRank] < 4)
						return Error(playerid, "You are not allowed!");
					GivePlayerWeaponEx(playerid, 29, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(29));
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_LOCKERSAMD)
	{
		if(response)
		{
			switch (listitem) 
			{
				case 0: 
				{
					if(pData[playerid][pOnDuty] == 1)
					{
						pData[playerid][pOnDuty] = 0;
						SetPlayerColor(playerid, COLOR_WHITE);
						SetPlayerSkin(playerid, pData[playerid][pSkin]);
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s places their badge and gun in their locker.", ReturnName(playerid));
					}
					else
					{
						pData[playerid][pOnDuty] = 1;
						SetFactionColor(playerid);
						if(pData[playerid][pGender] == 1)
						{
							SetPlayerSkin(playerid, 276);
							pData[playerid][pFacSkin] = 276;
						}
						else
						{
							SetPlayerSkin(playerid, 308);
							pData[playerid][pFacSkin] = 308;
						}
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s withdraws their badge and on duty from their locker", ReturnName(playerid));
					}
				}
				case 1: 
				{
					SetPlayerHealthEx(playerid, 100);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s telah mengambil medical kit dari locker", ReturnName(playerid));
				}
				case 2:
				{
					SetPlayerArmourEx(playerid, 97);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s telah mengambil armour pelindung dari locker", ReturnName(playerid));
				}
				case 3:
				{
					if(pData[playerid][pOnDuty] <= 0)
						return Error(playerid, "Kamu harus On duty untuk mengambil barang!");
					
					ShowPlayerDialog(playerid, DIALOG_WEAPONSAMD, DIALOG_STYLE_LIST, "SAMD Weapons", "FIREEXTINGUISHER\nSPRAYCAN\nPARACHUTE\nNITE STICK\nKNIFE\nCOLT45\nSILENCED\nDEAGLE", "Pilih", "Batal");
				}
				case 4:
				{
					if(pData[playerid][pOnDuty] <= 0)
						return Error(playerid, "Kamu harus On duty untuk mengambil barang!");
					switch (pData[playerid][pGender])
					{
						case 1: ShowModelSelectionMenu(playerid, SAMDMale, "Choose your skin");
						case 2: ShowModelSelectionMenu(playerid, SAMDFemale, "Choose your skin");
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_WEAPONSAMD)
	{
		if(response)
		{
			switch (listitem) 
			{
				case 0:
				{
					GivePlayerWeaponEx(playerid, 42, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(42));
				}
				case 1:
				{
					GivePlayerWeaponEx(playerid, 41, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(41));
				}
				case 2:
				{
					GivePlayerWeaponEx(playerid, 46, 1);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(46));
				}
				case 3:
				{
					//GivePlayerWeaponEx(playerid, 3, 200);
					//SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(3));
				}
				case 4:
				{
					//GivePlayerWeaponEx(playerid, 4, 200);
					//SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(4));
				}
				case 5:
				{
					if(pData[playerid][pFactionRank] < 3)
						return Error(playerid, "You are not allowed!");
						
					//GivePlayerWeaponEx(playerid, 22, 200);
					//SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(22));
				}
				case 6:
				{
					if(pData[playerid][pFactionRank] < 3)
						return Error(playerid, "You are not allowed!");
						
					//GivePlayerWeaponEx(playerid, 23, 200);
					//SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(23));
				}
				case 7:
				{
					if(pData[playerid][pFactionRank] < 3)
						return Error(playerid, "You are not allowed!");
						
					//GivePlayerWeaponEx(playerid, 24, 200);
					//SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(24));
				}	
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_LOCKERSANEW)
	{
		if(response)
		{
			switch (listitem) 
			{
				case 0: 
				{
					if(pData[playerid][pOnDuty] == 1)
					{
						pData[playerid][pOnDuty] = 0;
						SetPlayerColor(playerid, COLOR_WHITE);
						SetPlayerSkin(playerid, pData[playerid][pSkin]);
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s places their badge and gun in their locker.", ReturnName(playerid));
					}
					else
					{
						pData[playerid][pOnDuty] = 1;
						SetFactionColor(playerid);
						if(pData[playerid][pGender] == 1)
						{
							SetPlayerSkin(playerid, 189);
							pData[playerid][pFacSkin] = 189;
						}
						else
						{
							SetPlayerSkin(playerid, 150); //194
							pData[playerid][pFacSkin] = 150; //194
						}
						SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s withdraws their badge and on duty from their locker", ReturnName(playerid));
					}
				}
				case 1: 
				{
					SetPlayerHealthEx(playerid, 100);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s telah mengambil medical kit dari locker", ReturnName(playerid));
				}
				case 2:
				{
					SetPlayerArmourEx(playerid, 97);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "* %s telah mengambil armour pelindung dari locker", ReturnName(playerid));
				}
				case 3:
				{
					if(pData[playerid][pOnDuty] <= 0)
						return Error(playerid, "Kamu harus On duty untuk mengambil barang!");
						
					ShowPlayerDialog(playerid, DIALOG_WEAPONSANEW, DIALOG_STYLE_LIST, "SAPD Weapons", "CAMERA\nSPRAYCAN\nPARACHUTE\nNITE STICK\nKNIFE\nCOLT45", "Pilih", "Batal");
				}
				case 4:
				{
					if(pData[playerid][pOnDuty] <= 0)
						return Error(playerid, "Kamu harus On duty untuk mengambil barang!");
					switch (pData[playerid][pGender])
					{
						case 1: ShowModelSelectionMenu(playerid, SANEWMale, "Choose your skin");
						case 2: ShowModelSelectionMenu(playerid, SANEWFemale, "Choose your skin");
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_WEAPONSANEW)
	{
		if(response)
		{
			switch (listitem) 
			{
				case 0:
				{
					GivePlayerWeaponEx(playerid, 43, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(43));
				}
				case 1:
				{
					GivePlayerWeaponEx(playerid, 41, 200);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(41));
				}
				case 2:
				{
					GivePlayerWeaponEx(playerid, 46, 1);
					SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(46));
				}
				case 3:
				{
					//GivePlayerWeaponEx(playerid, 3, 200);
					//SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(3));
				}
				case 4:
				{
					//GivePlayerWeaponEx(playerid, 4, 200);
					//SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(4));
				}
				case 5:
				{
					if(pData[playerid][pFactionRank] < 3)
						return Error(playerid, "You are not allowed!");
						
					//GivePlayerWeaponEx(playerid, 22, 200);
					//SendNearbyMessage(playerid, 30.0, COLOR_PURPLE, "** %s reaches inside the locker and equips a %s.", ReturnName(playerid), ReturnWeaponName(22));
				}
			}
		}
		return 1;
	}
	//--------[ DIALOG JOB ]--------
	if(dialogid == DIALOG_SERVICE)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						new Float:health, comp;
						GetVehicleHealth(pData[playerid][pMechVeh], health);
						if(health > 1000.0) health = 1000.0;
						if(health > 0.0) health *= -1;
						comp = floatround(health, floatround_round) / 10 + 100;
						
						if(pData[playerid][pComponent] < comp) return Error(playerid, "Component anda kurang!");
						if(comp <= 0) return Error(playerid, "This vehicle can't be fixing.");
						pData[playerid][pComponent] -= comp;
						Info(playerid, "Anda memperbaiki mesin kendaraan dengan "RED_E"%d component.", comp);
						pData[playerid][pMechanic] = SetTimerEx("EngineFix", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Fixing Engine...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						new panels, doors, light, tires, comp;
						
						GetVehicleDamageStatus(pData[playerid][pMechVeh], panels, doors, light, tires);
						new cpanels = panels / 1000000;
						new lights = light / 2;
						new pintu;
						if(doors != 0) pintu = 5;
						if(doors == 0) pintu = 0;
						comp = cpanels + lights + pintu + 20;
						
						if(pData[playerid][pComponent] < comp) return Error(playerid, "Component anda kurang!");
						if(comp <= 0) return Error(playerid, "This vehicle can't be fixing.");
						pData[playerid][pComponent] -= comp;
						Info(playerid, "Anda memperbaiki body kendaraan dengan "RED_E"%d component.", comp);
						pData[playerid][pMechanic] = SetTimerEx("BodyFix", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Fixing Body...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 2213.9382, -2232.8840, 13.5469) || IsPlayerInRangeOfPoint(playerid, 15.0, 2185.9504, -2204.9905, 13.5469) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 40) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_COLOR, DIALOG_STYLE_INPUT, "Color ID 1", "Enter the color id 1:(0 - 255)", "Next", "Close");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 3:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_PAINTJOB, DIALOG_STYLE_INPUT, "Paintjob", "Enter the vehicle paintjob id:(0 - 2 | 3 - Remove paintJob)", "Paintjob", "Close");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 4:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 85) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_WHEELS, DIALOG_STYLE_LIST, "Wheels", "Offroad\nMega\nWires\nTwist\nGrove\nImport\nAtomic\nAhab\nVirtual\nAccess\nTrance\nShadow\nRimshine\nClassic\nCutter\nSwitch\nDollar", "Confirm", "back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 5:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_SPOILER,DIALOG_STYLE_LIST,"Choose below","Wheel Arc. Alien Spoiler\nWheel Arc. X-Flow Spoiler\nTransfender Win Spoiler\nTransfender Fury Spoiler\nTransfender Alpha Spoiler\nTransfender Pro Spoiler\nTransfender Champ Spoiler\nTransfender Race Spoiler\nTransfender Drag Spoiler\n","Choose","back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 6:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_HOODS, DIALOG_STYLE_LIST, "Hoods", "Fury\nChamp\nRace\nWorx\n", "Confirm", "back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 7:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_VENTS, DIALOG_STYLE_LIST, "Vents", "Oval\nSquare\n", "Confirm", "back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 8:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 50) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_LIGHTS, DIALOG_STYLE_LIST, "Lights", "Round\nSquare\n", "Confirm", "back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 9:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 80) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_EXHAUSTS, DIALOG_STYLE_LIST, "Exhausts", "Wheel Arc. Alien exhaust\nWheel Arc. X-Flow exhaust\nLow Co. Chromer exhaust\nLow Co. Slamin exhaust\nTransfender Large exhaust\nTransfender Medium exhaust\nTransfender Small exhaust\nTransfender Twin exhaust\nTransfender Upswept exhaust", "Confirm", "back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 10:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_FRONT_BUMPERS, DIALOG_STYLE_LIST, "Front bumpers", "Wheel Arc. Alien Bumper\nWheel Arc. X-Flow Bumper\nLow co. Chromer Bumper\nLow co. Slamin Bumper", "Confirm", "back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 11:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_REAR_BUMPERS, DIALOG_STYLE_LIST, "Rear bumpers", "Wheel Arc. Alien Bumper\nWheel Arc. X-Flow Bumper\nLow co. Chromer Bumper\nLow co. Slamin Bumper", "Confirm", "back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 12:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_ROOFS, DIALOG_STYLE_LIST, "Roofs", "Wheel Arc. Alien\nWheel Arc. X-Flow\nLow Co. Hardtop Roof\nLow Co. Softtop Roof\nTransfender Roof Scoop", "Confirm", "back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 13:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 90) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_SIDE_SKIRTS, DIALOG_STYLE_LIST, "Side skirts", "Wheel Arc. Alien Side Skirt\nWheel Arc. X-Flow Side Skirt\nLocos Chrome Strip\nLocos Chrome Flames\nLocos Chrome Arches \nLocos Chrome Trim\nLocos Wheelcovers\nTransfender Side Skirt", "Confirm", "back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
					Info(playerid, "Side blm ada.");
				}
				case 14:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 50) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_BULLBARS, DIALOG_STYLE_LIST, "Bull bars", "Locos Chrome Grill\nLocos Chrome Bars\nLocos Chrome Lights \nLocos Chrome Bullbar", "Confirm", "back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 15:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						pData[playerid][pMechColor1] = 1086;
						pData[playerid][pMechColor2] = 0;
				
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{	
							if(pData[playerid][pComponent] < 150) return Error(playerid, "Component anda kurang!");
							pData[playerid][pComponent] -= 150;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"150 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pMechColor1] = 0;
							pData[playerid][pMechColor2] = 0;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 16:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						pData[playerid][pMechColor1] = 1087;
						pData[playerid][pMechColor2] = 0;
				
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{	
							if(pData[playerid][pComponent] < 150) return Error(playerid, "Component anda kurang!");
							pData[playerid][pComponent] -= 150;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"150 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pMechColor1] = 0;
							pData[playerid][pMechColor2] = 0;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 17:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
						pData[playerid][pMechColor1] = 1009;
						pData[playerid][pMechColor2] = 0;
				
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{	
							if(pData[playerid][pComponent] < 250) return Error(playerid, "Component anda kurang!");
							pData[playerid][pComponent] -= 250;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"250 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pMechColor1] = 0;
							pData[playerid][pMechColor2] = 0;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 18:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
					
						pData[playerid][pMechColor1] = 1008;
						pData[playerid][pMechColor2] = 0;
				
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{	
							if(pData[playerid][pComponent] < 375) return Error(playerid, "Component anda kurang!");
							pData[playerid][pComponent] -= 375;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"375 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pMechColor1] = 0;
							pData[playerid][pMechColor2] = 0;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 19:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
						pData[playerid][pMechColor1] = 1010;
						pData[playerid][pMechColor2] = 0;
				
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{	
							if(pData[playerid][pComponent] < 500) return Error(playerid, "Component anda kurang!");
							pData[playerid][pComponent] -= 500;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"500 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pMechColor1] = 0;
							pData[playerid][pMechColor2] = 0;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
				case 20:
				{
					if(IsPlayerInRangeOfPoint(playerid, 15.0, 1607.16, -1831.15, 13.70) || IsPlayerInRangeOfPoint(playerid, 15.0, 1604.71, -1814.39, 13.45) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 1634.59, -1841.24, 13.54) || IsPlayerInRangeOfPoint(playerid, 15.0, 1651.04, -1835.13, 13.54) ||
					IsPlayerInRangeOfPoint(playerid, 15.0, 298.59, -248.54, 1.60) || IsPlayerInRangeOfPoint(playerid, 10.0, 266.20, -253.32, 1.59))
					{
						if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
						if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
						{
							if(pData[playerid][pComponent] < 450) return Error(playerid, "Component anda kurang!");
							ShowPlayerDialog(playerid, DIALOG_SERVICE_NEON,DIALOG_STYLE_LIST,"Neon","RED\nBLUE\nGREEN\nYELLOW\nPINK\nWHITE\nREMOVE","Choose","back");
						}
						else
						{
							KillTimer(pData[playerid][pMechanic]);
							HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
							PlayerTextDrawHide(playerid, ActiveTD[playerid]);
							pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
							pData[playerid][pActivityTime] = 0;
							Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
							return 1;
						}
					}
					else return Error(playerid, "You must in Mechanic Center Area!");
				}
			}
		}
	}
	if(dialogid == DIALOG_SERVICE_COLOR)
	{
		if(response)
		{
			pData[playerid][pMechColor1] = floatround(strval(inputtext));
			
			if(pData[playerid][pMechColor1] < 0 || pData[playerid][pMechColor1] > 255)
				return ShowPlayerDialog(playerid, DIALOG_SERVICE_COLOR, DIALOG_STYLE_INPUT, "Color ID 1", "Enter the color id 1:(0 - 255)", "Next", "Close");
			
			ShowPlayerDialog(playerid, DIALOG_SERVICE_COLOR2, DIALOG_STYLE_INPUT, "Color ID 2", "Enter the color id 2:(0 - 255)", "Next", "Close");
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_COLOR2)
	{
		if(response)
		{
			pData[playerid][pMechColor2] = floatround(strval(inputtext));
			
			if(pData[playerid][pMechColor2] < 0 || pData[playerid][pMechColor2] > 255)
				return ShowPlayerDialog(playerid, DIALOG_SERVICE_COLOR2, DIALOG_STYLE_INPUT, "Color ID 2", "Enter the color id 2:(0 - 255)", "Next", "Close");
			
			if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
			if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
			{	
				if(pData[playerid][pComponent] < 40) return Error(playerid, "Component anda kurang!");
				pData[playerid][pComponent] -= 40;
				Info(playerid, "Anda mengganti warna kendaraan dengan "RED_E"30 component.");
				pData[playerid][pMechanic] = SetTimerEx("SprayCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
				PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Spraying Car...");
				PlayerTextDrawShow(playerid, ActiveTD[playerid]);
				ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
			}
			else
			{
				KillTimer(pData[playerid][pMechanic]);
				HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
				PlayerTextDrawHide(playerid, ActiveTD[playerid]);
				pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
				pData[playerid][pMechColor1] = 0;
				pData[playerid][pMechColor2] = 0;
				pData[playerid][pActivityTime] = 0;
				Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
				return 1;
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_PAINTJOB)
	{
		if(response)
		{
			pData[playerid][pMechColor1] = floatround(strval(inputtext));
			
			if(pData[playerid][pMechColor1] < 0 || pData[playerid][pMechColor1] > 3)
				return ShowPlayerDialog(playerid, DIALOG_SERVICE_PAINTJOB, DIALOG_STYLE_INPUT, "Paintjob", "Enter the vehicle paintjob id:(0 - 2 | 3 - Remove paintJob)", "Paintjob", "Close");
			
			if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
			if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
			{	
				if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
				pData[playerid][pComponent] -= 100;
				Info(playerid, "Anda mengganti paintjob kendaraan dengan "RED_E"50 component.");
				pData[playerid][pMechanic] = SetTimerEx("PaintjobCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
				PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Painting Car...");
				PlayerTextDrawShow(playerid, ActiveTD[playerid]);
				ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
			}
			else
			{
				KillTimer(pData[playerid][pMechanic]);
				HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
				PlayerTextDrawHide(playerid, ActiveTD[playerid]);
				pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
				pData[playerid][pMechColor1] = 0;
				pData[playerid][pMechColor2] = 0;
				pData[playerid][pActivityTime] = 0;
				Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
				return 1;
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_WHEELS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					pData[playerid][pMechColor1] = 1025;
					pData[playerid][pMechColor2] = 0;

					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 85) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 85;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					pData[playerid][pMechColor1] = 1074;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					pData[playerid][pMechColor1] = 1076;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 3:
				{
					pData[playerid][pMechColor1] = 1078;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 4:
				{
					pData[playerid][pMechColor1] = 1081;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 5:
				{
					pData[playerid][pMechColor1] = 1082;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 6:
				{
					pData[playerid][pMechColor1] = 1085;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 7:
				{
					pData[playerid][pMechColor1] = 1096;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 8:
				{
					pData[playerid][pMechColor1] = 1097;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 9:
				{
					pData[playerid][pMechColor1] = 1098;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 10:
				{
					pData[playerid][pMechColor1] = 1084;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 11:
				{
					pData[playerid][pMechColor1] = 1073;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 12:
				{
					pData[playerid][pMechColor1] = 1075;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 13:
				{
					pData[playerid][pMechColor1] = 1077;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 14:
				{
					pData[playerid][pMechColor1] = 1079;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 15:
				{
					pData[playerid][pMechColor1] = 1080;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 16:
				{
					pData[playerid][pMechColor1] = 1083;
					pData[playerid][pMechColor2] = 0;
			
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{	
						if(pData[playerid][pComponent] < 60) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 60;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"60 component.");
						pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_SPOILER)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 561 ||
						VehicleModel == 558 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1147;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1049;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1162;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1058;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1164;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1138;
								pData[playerid][pMechColor2] = 0;
							}
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 561 ||
						VehicleModel == 558 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1146;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1050;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1158;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1060;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1163;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1139;
								pData[playerid][pMechColor2] = 0;
							}
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 401 ||
						VehicleModel == 518 ||
						VehicleModel == 527 ||
						VehicleModel == 415 ||
						VehicleModel == 546 ||
						VehicleModel == 603 ||
						VehicleModel == 426 ||
						VehicleModel == 436 ||
						VehicleModel == 405 ||
						VehicleModel == 477 ||
						VehicleModel == 580 ||
						VehicleModel == 550 ||
						VehicleModel == 549)
						{
				
							pData[playerid][pMechColor1] = 1001;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 3:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 518 ||
						VehicleModel == 415 ||
						VehicleModel == 546 ||
						VehicleModel == 517 ||
						VehicleModel == 603 ||
						VehicleModel == 405 ||
						VehicleModel == 477 ||
						VehicleModel == 580 ||
						VehicleModel == 550 ||
						VehicleModel == 549)
						{
				
							pData[playerid][pMechColor1] = 1023;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 4:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 518 ||
						VehicleModel == 415 ||
						VehicleModel == 401 ||
						VehicleModel == 517 ||
						VehicleModel == 426 ||
						VehicleModel == 436 ||
						VehicleModel == 477 ||
						VehicleModel == 547 ||
						VehicleModel == 550 ||
						VehicleModel == 549)
						{
				
							pData[playerid][pMechColor1] = 1003;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 5:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 589 ||
						VehicleModel == 492 ||
						VehicleModel == 547 ||
						VehicleModel == 405)
						{
				
							pData[playerid][pMechColor1] = 1000;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 6:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 527 ||
						VehicleModel == 542 ||
						VehicleModel == 405)
						{
				
							pData[playerid][pMechColor1] = 1014;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 7:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 527 ||
						VehicleModel == 542)
						{
				
							pData[playerid][pMechColor1] = 1015;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 8:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 546 ||
						VehicleModel == 517)
						{
				
							pData[playerid][pMechColor1] = 1002;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
	}
	if(dialogid == DIALOG_SERVICE_HOODS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(
						VehicleModel == 401 ||
						VehicleModel == 518 ||
						VehicleModel == 589 ||
						VehicleModel == 492 ||
						VehicleModel == 426 ||
						VehicleModel == 550)
						{
				
							pData[playerid][pMechColor1] = 1005;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(
						VehicleModel == 401 ||
						VehicleModel == 402 ||
						VehicleModel == 546 ||
						VehicleModel == 426 ||
						VehicleModel == 550)
						{
				
							pData[playerid][pMechColor1] = 1004;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 401)
						{
				
							pData[playerid][pMechColor1] = 1011;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 3:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 549)
						{
				
							pData[playerid][pMechColor1] = 1012;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_VENTS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 401 ||
						VehicleModel == 518 ||
						VehicleModel == 546 ||
						VehicleModel == 517 ||
						VehicleModel == 603 ||
						VehicleModel == 547 ||
						VehicleModel == 439 ||
						VehicleModel == 550 ||
						VehicleModel == 549)
						{
				
							pData[playerid][pMechColor1] = 1142;
							pData[playerid][pMechColor2] = 1143;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 401 ||
						VehicleModel == 518 ||
						VehicleModel == 589 ||
						VehicleModel == 546 ||
						VehicleModel == 517 ||
						VehicleModel == 603 ||
						VehicleModel == 439 ||
						VehicleModel == 550 ||
						VehicleModel == 549)
						{
				
							pData[playerid][pMechColor1] = 1144;
							pData[playerid][pMechColor2] = 1145;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
	}
	if(dialogid == DIALOG_SERVICE_LIGHTS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 401 ||
						VehicleModel == 518 ||
						VehicleModel == 589 ||
						VehicleModel == 400 ||
						VehicleModel == 436 ||
						VehicleModel == 439)
						{
				
							pData[playerid][pMechColor1] = 1013;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 589 ||
						VehicleModel == 603 ||
						VehicleModel == 400)
						{
				
							pData[playerid][pMechColor1] = 1024;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_EXHAUSTS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 80) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 558 ||
						VehicleModel == 561 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1034;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1046;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1065;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1064;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1028;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1089;
								pData[playerid][pMechColor2] = 0;
							}
							pData[playerid][pComponent] -= 80;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"80 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 80) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 558 ||
						VehicleModel == 561 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1037;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1045;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1066;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1059;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1029;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1092;
								pData[playerid][pMechColor2] = 0;
							}
							pData[playerid][pComponent] -= 80;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"80 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 80) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 575 ||
						VehicleModel == 534 ||
						VehicleModel == 567 ||
						VehicleModel == 536 ||
						VehicleModel == 576 ||
						VehicleModel == 535)
						{
							if(VehicleModel == 575)
							{
								pData[playerid][pMechColor1] = 1044;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 534)
							{
								pData[playerid][pMechColor1] = 1126;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 567)
							{
								pData[playerid][pMechColor1] = 1129;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 536)
							{
								pData[playerid][pMechColor1] = 1104;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 576)
							{
								pData[playerid][pMechColor1] = 1113;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 535)
							{
								pData[playerid][pMechColor1] = 1136;
								pData[playerid][pMechColor2] = 0;
							}
							pData[playerid][pComponent] -= 80;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"80 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 3:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 80) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 575 ||
						VehicleModel == 534 ||
						VehicleModel == 567 ||
						VehicleModel == 536 ||
						VehicleModel == 576 ||
						VehicleModel == 535)
						{
							if(VehicleModel == 575)
							{
								pData[playerid][pMechColor1] = 1043;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 534)
							{
								pData[playerid][pMechColor1] = 1127;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 567)
							{
								pData[playerid][pMechColor1] = 1132;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 536)
							{
								pData[playerid][pMechColor1] = 1105;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 576)
							{
								pData[playerid][pMechColor1] = 1135;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 535)
							{
								pData[playerid][pMechColor1] = 1114;
								pData[playerid][pMechColor2] = 0;
							}
							pData[playerid][pComponent] -= 80;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"80 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 4:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 80) return Error(playerid, "Component anda kurang!");
						if(
						VehicleModel == 401 ||
						VehicleModel == 518 ||
						VehicleModel == 527 ||
						VehicleModel == 542 ||
						VehicleModel == 589 ||
						VehicleModel == 400 ||
						VehicleModel == 517 ||
						VehicleModel == 603 ||
						VehicleModel == 426 ||
						VehicleModel == 547 ||
						VehicleModel == 405 ||
						VehicleModel == 580 ||
						VehicleModel == 550 ||
						VehicleModel == 549 ||
						VehicleModel == 477)
						{
							
							pData[playerid][pMechColor1] = 1020;
							pData[playerid][pMechColor2] = 0;
								
							pData[playerid][pComponent] -= 80;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"80 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 5:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 80) return Error(playerid, "Component anda kurang!");
						if(
						VehicleModel == 527 ||
						VehicleModel == 542 ||
						VehicleModel == 400 ||
						VehicleModel == 426 ||
						VehicleModel == 436 ||
						VehicleModel == 547 ||
						VehicleModel == 405 ||
						VehicleModel == 477)
						{
							
							pData[playerid][pMechColor1] = 1021;
							pData[playerid][pMechColor2] = 0;
								
							pData[playerid][pComponent] -= 80;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"80 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 6:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 80) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 436)
						{
							
							pData[playerid][pMechColor1] = 1022;
							pData[playerid][pMechColor2] = 0;
								
							pData[playerid][pComponent] -= 80;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"80 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 7:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 80) return Error(playerid, "Component anda kurang!");
						if(
						VehicleModel == 518 ||
						VehicleModel == 415 ||
						VehicleModel == 542 ||
						VehicleModel == 546 ||
						VehicleModel == 400 ||
						VehicleModel == 517 ||
						VehicleModel == 603 ||
						VehicleModel == 426 ||
						VehicleModel == 436 ||
						VehicleModel == 547 ||
						VehicleModel == 405 ||
						VehicleModel == 550 ||
						VehicleModel == 549 ||
						VehicleModel == 477)
						{
							
							pData[playerid][pMechColor1] = 1019;
							pData[playerid][pMechColor2] = 0;
								
							pData[playerid][pComponent] -= 80;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"80 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 8:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 80) return Error(playerid, "Component anda kurang!");
						if(
						VehicleModel == 401 ||
						VehicleModel == 518 ||
						VehicleModel == 415 ||
						VehicleModel == 542 ||
						VehicleModel == 546 ||
						VehicleModel == 400 ||
						VehicleModel == 517 ||
						VehicleModel == 603 ||
						VehicleModel == 426 ||
						VehicleModel == 415 ||
						VehicleModel == 547 ||
						VehicleModel == 405 ||
						VehicleModel == 550 ||
						VehicleModel == 549 ||
						VehicleModel == 477)
						{
							
							pData[playerid][pMechColor1] = 1018;
							pData[playerid][pMechColor2] = 0;
								
							pData[playerid][pComponent] -= 80;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"80 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_FRONT_BUMPERS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 561 ||
						VehicleModel == 558 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1171;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1153;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1160;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1155;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1166;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1169;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 100;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"100 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 561 ||
						VehicleModel == 558 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1172;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1152;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1173;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1157;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1165;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1170;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 100;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"100 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 575 ||
						VehicleModel == 534 ||
						VehicleModel == 567 ||
						VehicleModel == 536 ||
						VehicleModel == 576 ||
						VehicleModel == 535)
						{
							if(VehicleModel == 575)
							{
								pData[playerid][pMechColor1] = 1174;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 534)
							{
								pData[playerid][pMechColor1] = 1179;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 567)
							{
								pData[playerid][pMechColor1] = 1189;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 536)
							{
								pData[playerid][pMechColor1] = 1182;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 576)
							{
								pData[playerid][pMechColor1] = 1191;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 535)
							{
								pData[playerid][pMechColor1] = 1115;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 100;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"100 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 3:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 575 ||
						VehicleModel == 534 ||
						VehicleModel == 567 ||
						VehicleModel == 536 ||
						VehicleModel == 576 ||
						VehicleModel == 535)
						{
							if(VehicleModel == 575)
							{
								pData[playerid][pMechColor1] = 1175;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 534)
							{
								pData[playerid][pMechColor1] = 1185;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 567)
							{
								pData[playerid][pMechColor1] = 1188;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 536)
							{
								pData[playerid][pMechColor1] = 1181;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 576)
							{
								pData[playerid][pMechColor1] = 1190;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 535)
							{
								pData[playerid][pMechColor1] = 1116;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 100;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"100 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_REAR_BUMPERS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 561 ||
						VehicleModel == 558 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1149;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1150;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1159;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1154;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1168;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1141;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 100;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"100 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 561 ||
						VehicleModel == 558 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1148;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1151;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1161;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1156;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1167;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1140;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 100;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"100 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 575 ||
						VehicleModel == 534 ||
						VehicleModel == 567 ||
						VehicleModel == 536 ||
						VehicleModel == 576 ||
						VehicleModel == 535)
						{
							if(VehicleModel == 575)
							{
								pData[playerid][pMechColor1] = 1176;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 534)
							{
								pData[playerid][pMechColor1] = 1180;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 567)
							{
								pData[playerid][pMechColor1] = 1187;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 536)
							{
								pData[playerid][pMechColor1] = 1184;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 576)
							{
								pData[playerid][pMechColor1] = 1192;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 535)
							{
								pData[playerid][pMechColor1] = 1109;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 100;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"100 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 3:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 100) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 575 ||
						VehicleModel == 534 ||
						VehicleModel == 567 ||
						VehicleModel == 536 ||
						VehicleModel == 576 ||
						VehicleModel == 535)
						{
							if(VehicleModel == 575)
							{
								pData[playerid][pMechColor1] = 1177;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 534)
							{
								pData[playerid][pMechColor1] = 1178;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 567)
							{
								pData[playerid][pMechColor1] = 1186;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 536)
							{
								pData[playerid][pMechColor1] = 1183;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 576)
							{
								pData[playerid][pMechColor1] = 1193;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 535)
							{
								pData[playerid][pMechColor1] = 1110;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 100;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"100 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_ROOFS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 561 ||
						VehicleModel == 558 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1038;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1054;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1067;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1055;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1088;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1032;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 561 ||
						VehicleModel == 558 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1038;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1053;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1068;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1061;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1091;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1033;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 567 ||
						VehicleModel == 536)
						{
							if(VehicleModel == 567)
							{
								pData[playerid][pMechColor1] = 1130;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 536)
							{
								pData[playerid][pMechColor1] = 1128;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 3:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 567 ||
						VehicleModel == 536)
						{
							if(VehicleModel == 567)
							{
								pData[playerid][pMechColor1] = 1131;
								pData[playerid][pMechColor2] = 0;
							}
							if(VehicleModel == 536)
							{
								pData[playerid][pMechColor1] = 1103;
								pData[playerid][pMechColor2] = 0;
							}
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 4:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 70) return Error(playerid, "Component anda kurang!");
						if(
						VehicleModel == 401 ||
						VehicleModel == 518 ||
						VehicleModel == 589 ||
						VehicleModel == 492 ||
						VehicleModel == 546 ||
						VehicleModel == 603 ||
						VehicleModel == 426 ||
						VehicleModel == 436 ||
						VehicleModel == 580 ||
						VehicleModel == 550 ||
						VehicleModel == 477)
						{

							pData[playerid][pMechColor1] = 1006;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 70;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"70 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_SIDE_SKIRTS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 90) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 561 ||
						VehicleModel == 558 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1036;
								pData[playerid][pMechColor2] = 1040;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1047;
								pData[playerid][pMechColor2] = 1051;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1069;
								pData[playerid][pMechColor2] = 1071;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1056;
								pData[playerid][pMechColor2] = 1062;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1090;
								pData[playerid][pMechColor2] = 1094;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1026;
								pData[playerid][pMechColor2] = 1027;
							}
							
							pData[playerid][pComponent] -= 90;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"90 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 90) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 562 ||
						VehicleModel == 565 ||
						VehicleModel == 559 ||
						VehicleModel == 561 ||
						VehicleModel == 558 ||
						VehicleModel == 560)
						{
							if(VehicleModel == 562)
							{
								pData[playerid][pMechColor1] = 1039;
								pData[playerid][pMechColor2] = 1041;
							}
							if(VehicleModel == 565)
							{
								pData[playerid][pMechColor1] = 1048;
								pData[playerid][pMechColor2] = 1052;
							}
							if(VehicleModel == 559)
							{
								pData[playerid][pMechColor1] = 1070;
								pData[playerid][pMechColor2] = 1072;
							}
							if(VehicleModel == 561)
							{
								pData[playerid][pMechColor1] = 1057;
								pData[playerid][pMechColor2] = 1063;
							}
							if(VehicleModel == 558)
							{
								pData[playerid][pMechColor1] = 1093;
								pData[playerid][pMechColor2] = 1095;
							}
							if(VehicleModel == 560)
							{
								pData[playerid][pMechColor1] = 1031;
								pData[playerid][pMechColor2] = 1030;
							}
							
							pData[playerid][pComponent] -= 90;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"90 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 90) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 575 ||
						VehicleModel == 536 ||
						VehicleModel == 576 ||
						VehicleModel == 567)
						{
							if(VehicleModel == 575)
							{
								pData[playerid][pMechColor1] = 1042;
								pData[playerid][pMechColor2] = 1099;
							}
							if(VehicleModel == 536)
							{
								pData[playerid][pMechColor1] = 1108;
								pData[playerid][pMechColor2] = 1107;
							}
							if(VehicleModel == 576)
							{
								pData[playerid][pMechColor1] = 1134;
								pData[playerid][pMechColor2] = 1137;
							}
							if(VehicleModel == 567)
							{
								pData[playerid][pMechColor1] = 1102;
								pData[playerid][pMechColor2] = 1133;
							}
							
							pData[playerid][pComponent] -= 90;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"90 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 3:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 90) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 534)
						{
				
							pData[playerid][pMechColor1] = 1102;
							pData[playerid][pMechColor2] = 1101;
							
							pData[playerid][pComponent] -= 90;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"90 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 4:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 90) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 534)
						{
				
							pData[playerid][pMechColor1] = 1106;
							pData[playerid][pMechColor2] = 1124;
							
							pData[playerid][pComponent] -= 90;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"90 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 5:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 90) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 535)
						{
				
							pData[playerid][pMechColor1] = 1118;
							pData[playerid][pMechColor2] = 1120;
							
							pData[playerid][pComponent] -= 90;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"90 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 6:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 90) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 535)
						{
				
							pData[playerid][pMechColor1] = 1119;
							pData[playerid][pMechColor2] = 1121;
							
							pData[playerid][pComponent] -= 90;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"90 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 7:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 90) return Error(playerid, "Component anda kurang!");
						if(
						VehicleModel == 401 ||
						VehicleModel == 518 ||
						VehicleModel == 527 ||
						VehicleModel == 415 ||
						VehicleModel == 589 ||
						VehicleModel == 546 ||
						VehicleModel == 517 ||
						VehicleModel == 603 ||
						VehicleModel == 436 ||
						VehicleModel == 439 ||
						VehicleModel == 580 ||
						VehicleModel == 549 ||
						VehicleModel == 477)
						{
				
							pData[playerid][pMechColor1] = 1007;
							pData[playerid][pMechColor2] = 1017;
							
							pData[playerid][pComponent] -= 90;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"90 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_BULLBARS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 50) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 534)
						{
				
							pData[playerid][pMechColor1] = 1100;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 50;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"50 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 50) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 534)
						{
				
							pData[playerid][pMechColor1] = 1123;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 50;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"50 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 50) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 534)
						{
				
							pData[playerid][pMechColor1] = 1125;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 50;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"50 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 3:
				{
					new VehicleModel = GetVehicleModel(pData[playerid][pMechVeh]);
					
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 50) return Error(playerid, "Component anda kurang!");
						if(VehicleModel == 534)
						{
				
							pData[playerid][pMechColor1] = 1117;
							pData[playerid][pMechColor2] = 0;
							
							pData[playerid][pComponent] -= 50;
							Info(playerid, "Anda memodif kendaraan dengan "RED_E"50 component.");
							pData[playerid][pMechanic] = SetTimerEx("ModifCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
							PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Modif Car...");
							PlayerTextDrawShow(playerid, ActiveTD[playerid]);
							ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
						}
						else return Error(playerid, "This vehicle is not supported!");
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_SERVICE_NEON)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					pData[playerid][pMechColor1] = RED_NEON;

					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 450) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 450;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"450 component.");
						pData[playerid][pMechanic] = SetTimerEx("NeonCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Neon Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 1:
				{
					pData[playerid][pMechColor1] = BLUE_NEON;

					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 450) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 450;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"450 component.");
						pData[playerid][pMechanic] = SetTimerEx("NeonCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Neon Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 2:
				{
					pData[playerid][pMechColor1] = GREEN_NEON;

					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 450) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 450;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"450 component.");
						pData[playerid][pMechanic] = SetTimerEx("NeonCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Neon Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 3:
				{
					pData[playerid][pMechColor1] = YELLOW_NEON;

					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 450) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 450;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"450 component.");
						pData[playerid][pMechanic] = SetTimerEx("NeonCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Neon Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 4:
				{
					pData[playerid][pMechColor1] = PINK_NEON;

					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 450) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 450;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"450 component.");
						pData[playerid][pMechanic] = SetTimerEx("NeonCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Neon Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 5:
				{
					pData[playerid][pMechColor1] = WHITE_NEON;

					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 450) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 450;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"450 component.");
						pData[playerid][pMechanic] = SetTimerEx("NeonCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Neon Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
				case 6:
				{
					pData[playerid][pMechColor1] = 0;

					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "You already checking vehicle!");
					if(GetNearestVehicleToPlayer(playerid, 3.8, false) == pData[playerid][pMechVeh])
					{
						if(pData[playerid][pComponent] < 450) return Error(playerid, "Component anda kurang!");
						pData[playerid][pComponent] -= 450;
						Info(playerid, "Anda memodif kendaraan dengan "RED_E"450 component.");
						pData[playerid][pMechanic] = SetTimerEx("NeonCar", 1000, true, "id", playerid, pData[playerid][pMechVeh]);
						PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Neon Car...");
						PlayerTextDrawShow(playerid, ActiveTD[playerid]);
						ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
					}
					else
					{
						KillTimer(pData[playerid][pMechanic]);
						HidePlayerProgressBar(playerid, pData[playerid][activitybar]);
						PlayerTextDrawHide(playerid, ActiveTD[playerid]);
						pData[playerid][pMechVeh] = INVALID_VEHICLE_ID;
						pData[playerid][pMechColor1] = 0;
						pData[playerid][pMechColor2] = 0;
						pData[playerid][pActivityTime] = 0;
						Info(playerid, "Kendaraan pelanggan anda yang sebelumnya sudah terlalu jauh.");
						return 1;
					}
				}
			}
		}
		return 1;
	}
	//ARMS Dealer
	if(dialogid == DIALOG_ARMS_GUN)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: //slc pistol
				{
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "Anda masih memiliki activity progress!");
					if(pData[playerid][pMaterial] < 500) return Error(playerid, "Material tidak cukup!(Butuh: 500).");
					if(pData[playerid][pComponent] < 500) return Error(playerid, "Component tidak cukup!(Butuh: 500).");
					if(GetPlayerMoney(playerid) < 1000) return Error(playerid, "Not enough money!");
					
					pData[playerid][pMaterial] -= 500;
					pData[playerid][pComponent] -= 500;
					GivePlayerMoneyEx(playerid, -1000);
					
					TogglePlayerControllable(playerid, 0);
					Info(playerid, "Anda membuat senjata ilegal dengan 500 material dan 500 component dengan harga $1.000!");
					ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 0, 0, 1);
					pData[playerid][pArmsDealer] = SetTimerEx("CreateGun", 1000, true, "idd", playerid, WEAPON_SILENCED, 70);
					PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Creating...");
					PlayerTextDrawShow(playerid, ActiveTD[playerid]);
					ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
				}
				case 1: //colt45 9mm
				{
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "Anda masih memiliki activity progress!");
					if(pData[playerid][pMaterial] < 500) return Error(playerid, "Material tidak cukup!(Butuh: 500).");
					if(pData[playerid][pComponent] < 500) return Error(playerid, "Component tidak cukup!(Butuh: 500).");
					if(GetPlayerMoney(playerid) < 300) return Error(playerid, "Not enough money!");
					
					pData[playerid][pMaterial] -= 500;
					pData[playerid][pComponent] -= 500;
					GivePlayerMoneyEx(playerid, -300);
					
					TogglePlayerControllable(playerid, 0);
					Info(playerid, "Anda membuat senjata ilegal dengan 500 material dan 500 component dengan harga $300!");
					ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 0, 0, 1);
					pData[playerid][pArmsDealer] = SetTimerEx("CreateGun", 1000, true, "idd", playerid, WEAPON_COLT45, 70);
					PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Creating...");
					PlayerTextDrawShow(playerid, ActiveTD[playerid]);
					ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
				}
				case 2: //deagle
				{
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "Anda masih memiliki activity progress!");
					if(pData[playerid][pMaterial] < 500) return Error(playerid, "Material tidak cukup!(Butuh: 500).");
					if(pData[playerid][pComponent] < 500) return Error(playerid, "Component tidak cukup!(Butuh: 500).");
					if(GetPlayerMoney(playerid) < 6000) return Error(playerid, "Not enough money!");
					
					pData[playerid][pMaterial] -= 500;
					pData[playerid][pComponent] -= 500;
					GivePlayerMoneyEx(playerid, -6000);
					
					TogglePlayerControllable(playerid, 0);
					Info(playerid, "Anda membuat senjata ilegal dengan 500 material dan 500 component dengan harga $6.000!");
					ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 0, 0, 1);
					pData[playerid][pArmsDealer] = SetTimerEx("CreateGun", 1000, true, "idd", playerid, WEAPON_DEAGLE, 70);
					PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Creating...");
					PlayerTextDrawShow(playerid, ActiveTD[playerid]);
					ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
				}
				case 3: //shotgun
				{
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "Anda masih memiliki activity progress!");
					if(pData[playerid][pMaterial] < 500) return Error(playerid, "Material tidak cukup!(Butuh: 500).");
					if(pData[playerid][pComponent] < 500) return Error(playerid, "Component tidak cukup!(Butuh: 500).");
					if(GetPlayerMoney(playerid) < 4000) return Error(playerid, "Not enough money!");
					
					pData[playerid][pMaterial] -= 500;
					pData[playerid][pComponent] -= 500;
					GivePlayerMoneyEx(playerid, -4000);
					
					TogglePlayerControllable(playerid, 0);
					Info(playerid, "Anda membuat senjata ilegal dengan 500 material dan 500 component dengan harga $4.000!");
					ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 0, 0, 1);
					pData[playerid][pArmsDealer] = SetTimerEx("CreateGun", 1000, true, "idd", playerid, WEAPON_SHOTGUN, 50);
					PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Creating...");
					PlayerTextDrawShow(playerid, ActiveTD[playerid]);
					ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
				}
				case 4: //rifle
				{
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "Anda masih memiliki activity progress!");
					if(pData[playerid][pMaterial] < 500) return Error(playerid, "Material tidak cukup!(Butuh: 500).");
					if(pData[playerid][pComponent] < 500) return Error(playerid, "Component tidak cukup!(Butuh: 500).");
					if(GetPlayerMoney(playerid) < 8000) return Error(playerid, "Not enough money!");
					
					pData[playerid][pMaterial] -= 500;
					pData[playerid][pComponent] -= 500;
					GivePlayerMoneyEx(playerid, -8000);
					
					TogglePlayerControllable(playerid, 0);
					Info(playerid, "Anda membuat senjata ilegal dengan 500 material dan 500 component dengan harga $8.000!");
					ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 0, 0, 1);
					pData[playerid][pArmsDealer] = SetTimerEx("CreateGun", 1000, true, "idd", playerid, WEAPON_RIFLE, 35);
					PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Creating...");
					PlayerTextDrawShow(playerid, ActiveTD[playerid]);
					ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
				}
				case 5: //ak-47
				{
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "Anda masih memiliki activity progress!");
					if(pData[playerid][pMaterial] < 500) return Error(playerid, "Material tidak cukup!(Butuh: 500).");
					if(pData[playerid][pComponent] < 500) return Error(playerid, "Component tidak cukup!(Butuh: 500).");
					if(GetPlayerMoney(playerid) < 12000) return Error(playerid, "Not enough money!");
					
					pData[playerid][pMaterial] -= 500;
					pData[playerid][pComponent] -= 500;
					GivePlayerMoneyEx(playerid, -12000);
					
					TogglePlayerControllable(playerid, 0);
					Info(playerid, "Anda membuat senjata ilegal dengan 500 material dan 500 component dengan harga $12.000!");
					ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 0, 0, 1);
					pData[playerid][pArmsDealer] = SetTimerEx("CreateGun", 1000, true, "idd", playerid, WEAPON_AK47, 100);
					PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Creating...");
					PlayerTextDrawShow(playerid, ActiveTD[playerid]);
					ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
				}
				case 6: //Micro smg uzi
				{
					if(pData[playerid][pActivityTime] > 5) return Error(playerid, "Anda masih memiliki activity progress!");
					if(pData[playerid][pMaterial] < 500) return Error(playerid, "Material tidak cukup!(Butuh: 500).");
					if(pData[playerid][pComponent] < 500) return Error(playerid, "Component tidak cukup!(Butuh: 500).");
					if(GetPlayerMoney(playerid) < 10000) return Error(playerid, "Not enough money!");
					
					pData[playerid][pMaterial] -= 500;
					pData[playerid][pComponent] -= 500;
					GivePlayerMoneyEx(playerid, -10000);
					
					TogglePlayerControllable(playerid, 0);
					Info(playerid, "Anda membuat senjata ilegal dengan 500 material dan 500 component dengan harga $10.000!");
					ApplyAnimation(playerid, "BD_FIRE", "wash_up", 4.1, 0, 0, 0, 0, 0, 1);
					pData[playerid][pArmsDealer] = SetTimerEx("CreateGun", 1000, true, "idd", playerid, WEAPON_UZI, 200);
					PlayerTextDrawSetString(playerid, ActiveTD[playerid], "Creating...");
					PlayerTextDrawShow(playerid, ActiveTD[playerid]);
					ShowPlayerProgressBar(playerid, pData[playerid][activitybar]);
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_PLANT)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(pData[playerid][pSeed] < 5) return Error(playerid, "Not enough seed!");
					new pid = GetNearPlant(playerid);
					if(pid != -1) return Error(playerid, "You too closes with other plant!");
					
					new id = Iter_Free(Plants);
					if(id == -1) return Error(playerid, "Cant plant any more plant!");
					
					if(pData[playerid][pPlantTime] > 0) return Error(playerid, "You must wait 10 minutes for plant again!");
					
					if(IsPlayerInRangeOfPoint(playerid, 80.0, -237.43, -1357.56, 8.52) || IsPlayerInRangeOfPoint(playerid, 100.0, -475.43, -1343.56, 28.14)
					|| IsPlayerInRangeOfPoint(playerid, 50.0, -265.43, -1511.56, 5.49) || IsPlayerInRangeOfPoint(playerid, 30.0, -419.43, -1623.56, 18.87))
					{
					
						pData[playerid][pSeed] -= 5;
						new Float:x, Float:y, Float:z, query[512];
						GetPlayerPos(playerid, x, y, z);
						
						PlantData[id][PlantType] = 1;
						PlantData[id][PlantTime] = 180;
						PlantData[id][PlantX] = x;
						PlantData[id][PlantY] = y;
						PlantData[id][PlantZ] = z;
						PlantData[id][PlantHarvest] = false;
						PlantData[id][PlantTimer] = SetTimerEx("PlantGrowup", 1000, true, "i", id);
						Iter_Add(Plants, id);
						mysql_format(g_SQL, query, sizeof(query), "INSERT INTO plants SET id='%d', type='%d', time='%d', posx='%f', posy='%f', posz='%f'", id, PlantData[id][PlantType], PlantData[id][PlantTime], x, y, z);
						mysql_tquery(g_SQL, query, "OnPlantCreated", "di", playerid, id);
						pData[playerid][pPlant]++;
						Info(playerid, "Planting Potato.");
					}
					else return Error(playerid, "You must in farmer flint area!");
				}
				case 1:
				{
					if(pData[playerid][pSeed] < 18) return Error(playerid, "Not enough seed!");
					new pid = GetNearPlant(playerid);
					if(pid != -1) return Error(playerid, "You too closes with other plant!");
					
					new id = Iter_Free(Plants);
					if(id == -1) return Error(playerid, "Cant plant any more plant!");
					
					if(pData[playerid][pPlantTime] > 0) return Error(playerid, "You must wait 10 minutes for plant again!");
					
					if(IsPlayerInRangeOfPoint(playerid, 80.0, -237.43, -1357.56, 8.52) || IsPlayerInRangeOfPoint(playerid, 100.0, -475.43, -1343.56, 28.14)
					|| IsPlayerInRangeOfPoint(playerid, 50.0, -265.43, -1511.56, 5.49) || IsPlayerInRangeOfPoint(playerid, 30.0, -419.43, -1623.56, 18.87))
					{
					
						pData[playerid][pSeed] -= 18;
						new Float:x, Float:y, Float:z, query[512];
						GetPlayerPos(playerid, x, y, z);
						
						PlantData[id][PlantType] = 2;
						PlantData[id][PlantTime] = 180;
						PlantData[id][PlantX] = x;
						PlantData[id][PlantY] = y;
						PlantData[id][PlantZ] = z;
						PlantData[id][PlantHarvest] = false;
						PlantData[id][PlantTimer] = SetTimerEx("PlantGrowup", 1000, true, "i", id);
						Iter_Add(Plants, id);
						mysql_format(g_SQL, query, sizeof(query), "INSERT INTO plants SET id='%d', type='%d', time='%d', posx='%f', posy='%f', posz='%f'", id, PlantData[id][PlantType], PlantData[id][PlantTime], x, y, z);
						mysql_tquery(g_SQL, query, "OnPlantCreated", "di", playerid, id);
						pData[playerid][pPlant]++;
						Info(playerid, "Planting Wheat.");
					}
					else return Error(playerid, "You must in farmer flint area!");
				}
				case 2:
				{
					if(pData[playerid][pSeed] < 11) return Error(playerid, "Not enough seed!");
					new pid = GetNearPlant(playerid);
					if(pid != -1) return Error(playerid, "You too closes with other plant!");
					
					new id = Iter_Free(Plants);
					if(id == -1) return Error(playerid, "Cant plant any more plant!");
					
					if(pData[playerid][pPlantTime] > 0) return Error(playerid, "You must wait 10 minutes for plant again!");
					
					if(IsPlayerInRangeOfPoint(playerid, 80.0, -237.43, -1357.56, 8.52) || IsPlayerInRangeOfPoint(playerid, 100.0, -475.43, -1343.56, 28.14)
					|| IsPlayerInRangeOfPoint(playerid, 50.0, -265.43, -1511.56, 5.49) || IsPlayerInRangeOfPoint(playerid, 30.0, -419.43, -1623.56, 18.87))
					{
					
						pData[playerid][pSeed] -= 11;
						new Float:x, Float:y, Float:z, query[512];
						GetPlayerPos(playerid, x, y, z);
						
						PlantData[id][PlantType] = 3;
						PlantData[id][PlantTime] = 180;
						PlantData[id][PlantX] = x;
						PlantData[id][PlantY] = y;
						PlantData[id][PlantZ] = z;
						PlantData[id][PlantHarvest] = false;
						PlantData[id][PlantTimer] = SetTimerEx("PlantGrowup", 1000, true, "i", id);
						Iter_Add(Plants, id);
						mysql_format(g_SQL, query, sizeof(query), "INSERT INTO plants SET id='%d', type='%d', time='%d', posx='%f', posy='%f', posz='%f'", id, PlantData[id][PlantType], PlantData[id][PlantTime], x, y, z);
						mysql_tquery(g_SQL, query, "OnPlantCreated", "di", playerid, id);
						pData[playerid][pPlant]++;
						Info(playerid, "Planting Orange.");
					}
					else return Error(playerid, "You must in farmer flint area!");
				}
				case 3:
				{
					if(pData[playerid][pSeed] < 50) return Error(playerid, "Not enough seed!");
					new pid = GetNearPlant(playerid);
					if(pid != -1) return Error(playerid, "You too closes with other plant!");
					
					new id = Iter_Free(Plants);
					if(id == -1) return Error(playerid, "Cant plant any more plant!");
					
					if(pData[playerid][pPlantTime] > 0) return Error(playerid, "You must wait 10 minutes for plant again!");
					
					if(IsPlayerInRangeOfPoint(playerid, 80.0, -237.43, -1357.56, 8.52) || IsPlayerInRangeOfPoint(playerid, 100.0, -475.43, -1343.56, 28.14)
					|| IsPlayerInRangeOfPoint(playerid, 50.0, -265.43, -1511.56, 5.49) || IsPlayerInRangeOfPoint(playerid, 30.0, -419.43, -1623.56, 18.87))
					{
					
						pData[playerid][pSeed] -= 50;
						new Float:x, Float:y, Float:z, query[512];
						GetPlayerPos(playerid, x, y, z);
						
						PlantData[id][PlantType] = 4;
						PlantData[id][PlantTime] = 180;
						PlantData[id][PlantX] = x;
						PlantData[id][PlantY] = y;
						PlantData[id][PlantZ] = z;
						PlantData[id][PlantHarvest] = false;
						PlantData[id][PlantTimer] = SetTimerEx("PlantGrowup", 1000, true, "i", id);
						Iter_Add(Plants, id);
						mysql_format(g_SQL, query, sizeof(query), "INSERT INTO plants SET id='%d', type='%d', time='%d', posx='%f', posy='%f', posz='%f'", id, PlantData[id][PlantType], PlantData[id][PlantTime], x, y, z);
						mysql_tquery(g_SQL, query, "OnPlantCreated", "di", playerid, id);
						pData[playerid][pPlant]++;
						Info(playerid, "Planting Marijuana.");
					}
					else return Error(playerid, "You must in farmer flint area!");
				}
			}
		}
	}
	if(dialogid == DIALOG_HAULING)
	{
		if(response)
		{
			new id = ReturnRestockGStationID((listitem + 1)), vehicleid = GetPlayerVehicleID(playerid);
			
			if(pData[playerid][pHauling] > -1 || pData[playerid][pMission] > -1)
				return Error(playerid, "Anda sudah sedang melakukan Mission/hauling!");
			
			if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER && !IsATruck(vehicleid)) return Error(playerid, "Anda harus mengendarai truck.");
				
			pData[playerid][pHauling] = id;
			
			new line9[900];

			format(line9, sizeof(line9), "Silahkan anda membeli stock gasoil di gudang miner!\n\nGas Station ID: %d\nLocation: %s\n\nSetelah itu ikuti checkpoint dan antarkan ke Gas Station tujuan hauling anda!",
			id, GetLocation(gsData[id][gsPosX], gsData[id][gsPosY], gsData[id][gsPosZ]));
			SetPlayerRaceCheckpoint(playerid, 1, 336.70, 895.54, 20.40, 0.0, 0.0, 0.0, 3.5);
			//SetPlayerCheckpoint(playerid, -279.67, -2148.42, 28.54, 3.5);
			ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Hauling Info", line9, "Close","");
		}
		return 1;
	}
	if(dialogid == DIALOG_RESTOCK)
	{
		if(response)
		{
			new id = ReturnRestockBisnisID((listitem + 1)), vehicleid = GetPlayerVehicleID(playerid);
			if(bData[id][bMoney] < 1000)
				return Error(playerid, "Maaf, Bisnis ini kehabisan uang product.");
			
			if(pData[playerid][pMission] > -1 || pData[playerid][pHauling] > -1)
				return Error(playerid, "Anda sudah sedang melakukan mission/hauling!");
			
			if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER && !IsATruck(vehicleid)) return Error(playerid, "Anda harus mengendarai truck.");
				
			pData[playerid][pMission] = id;
			bData[id][bRestock] = 0;
			
			new line9[900];
			new type[128];
			if(bData[id][bType] == 1)
			{
				type = "Fast Food";

			}
			else if(bData[id][bType] == 2)
			{
				type = "Market";
			}
			else if(bData[id][bType] == 3)
			{
				type = "Clothes";
			}
			else if(bData[id][bType] == 4)
			{
				type = "Equipment";
			}
			else
			{
				type = "Unknow";
			}
			format(line9, sizeof(line9), "Silahkan anda membeli stock product di gudang!\n\nBisnis ID: %d\nBisnis Owner: %s\nBisnis Name: %s\nBisnis Type: %s\n\nSetelah itu ikuti checkpoint dan antarkan ke bisnis mission anda!",
			id, bData[id][bOwner], bData[id][bName], type);
			SetPlayerRaceCheckpoint(playerid,1, -279.67, -2148.42, 28.54, 0.0, 0.0, 0.0, 3.5);
			//SetPlayerCheckpoint(playerid, -279.67, -2148.42, 28.54, 3.5);
			ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Mission Info", line9, "Close","");
		}
	}
	if(dialogid == DIALOG_PRODUCT)
	{
		if(response)
		{
			new amount = floatround(strval(inputtext));
			new value = amount * ProductPrice;
			new vehicleid = GetPlayerVehicleID(playerid), carid = -1;
			new total = VehProduct[vehicleid] + amount;
			if(amount < 0 || amount > 150) return Error(playerid, "amount maximal 0 - 150.");
			if(GetPlayerMoney(playerid) < value) return Error(playerid, "Uang anda kurang.");
			if(Product < amount) return Error(playerid, "Product stock tidak mencukupi.");
			if(total > 150) return Error(playerid, "Product Maximal 150 in your vehicle tank!");
			GivePlayerMoneyEx(playerid, -value);
			VehProduct[vehicleid] += amount;
			if((carid = Vehicle_Nearest2(playerid)) != -1)
			{
				pvData[carid][cProduct] += amount;
			}
			
			Product -= amount;
			Server_AddMoney(value);
			Info(playerid, "Anda berhasil membeli "GREEN_E"%d "WHITE_E"product seharga "RED_E"%s.", amount, FormatMoney(value));
		}
	}
	if(dialogid == DIALOG_GASOIL)
	{
		if(response)
		{
			new amount = floatround(strval(inputtext));
			new value = amount * GasOilPrice;
			new vehicleid = GetPlayerVehicleID(playerid), carid = -1;
			new total = VehGasOil[vehicleid] + amount;
			
			if(amount < 0 || amount > 1000) return Error(playerid, "amount maximal 0 - 1000.");
			if(GetPlayerMoney(playerid) < value) return Error(playerid, "Uang anda kurang.");
			if(GasOil < amount) return Error(playerid, "Gasoil stock tidak mencukupi.");
			if(total > 1000) return Error(playerid, "Gas Oil Maximal 1000 liter in your vehicle tank!");
			GivePlayerMoneyEx(playerid, -value);
			VehGasOil[vehicleid] += amount;
			if((carid = Vehicle_Nearest2(playerid)) != -1)
			{
				pvData[carid][cGasOil] += amount;
			}
			
			GasOil -= amount;
			Server_AddMoney(value);
			Info(playerid, "Anda berhasil membeli "GREEN_E"%d "WHITE_E"liter gas oil seharga "RED_E"%s.", amount, FormatMoney(value));
		}
	}
	if(dialogid == DIALOG_MATERIAL)
	{
		if(response)
		{
			new amount = floatround(strval(inputtext));
			new total = pData[playerid][pMaterial] + amount;
			new value = amount * MaterialPrice;
			if(amount < 0 || amount > 500) return Error(playerid, "amount maximal 0 - 500.");
			if(total > 500) return Error(playerid, "Material too full in your inventory! Maximal 500.");
			if(GetPlayerMoney(playerid) < value) return Error(playerid, "Uang anda kurang.");
			if(Material < amount) return Error(playerid, "Material stock tidak mencukupi.");
			GivePlayerMoneyEx(playerid, -value);
			pData[playerid][pMaterial] += amount;
			Material -= amount;
			Server_AddMoney(value);
			Info(playerid, "Anda berhasil membeli "GREEN_E"%d "WHITE_E"material seharga "RED_E"%s.", amount, FormatMoney(value));
		}
	}
	if(dialogid == DIALOG_COMPONENT)
	{
		if(response)
		{
//		    new updatestock[500];
			new amount = floatround(strval(inputtext));
			new total = pData[playerid][pComponent] + amount;
			new value = amount * 5;
			if(amount < 0 || amount > 500) return Error(playerid, "amount maximal 0 - 500.");
			if(total > 500) return Error(playerid, "Component too full in your inventory! Maximal 500.");
			if(GetPlayerMoney(playerid) < value) return Error(playerid, "Uang anda kurang.");
			if(StockComp < amount) return Error(playerid, "Component stock tidak mencukupi.");
			GivePlayerMoneyEx(playerid, -value);
			pData[playerid][pComponent] += amount;
			StockComp -= amount;
//   			format(updatestock, sizeof(updatestock), "[Component Storage]\nComponent Available : %d\nComponent Price : $5\n/buy untuk membeli Komponen",StockComp);
//			UpdateDynamic3DTextLabelText(PickupComponent, COLOR_YELLOW, updatestock);
			SaveStockComp();
			Server_AddMoney(value);
			Info(playerid, "Anda berhasil membeli "GREEN_E"%d "WHITE_E"component seharga "RED_E"%s.", amount, FormatMoney(value));
		}
	}
	if(dialogid == DIALOG_DRUGS)
	{
		if(response)
		{
			new amount = floatround(strval(inputtext));
			new total = pData[playerid][pMarijuana] + amount;
			new value = amount * MarijuanaPrice;
			if(amount < 0 || amount > 100) return Error(playerid, "amount maximal 0 - 100.");
			if(total > 100) return Error(playerid, "Marijuana full in your inventory! max: 100 kg.");
			if(GetPlayerMoney(playerid) < value) return Error(playerid, "Uang anda kurang.");
			if(Marijuana < amount) return Error(playerid, "Marijuana stock tidak mencukupi.");
			GivePlayerMoneyEx(playerid, -value);
			pData[playerid][pComponent] += amount;
			Marijuana -= amount;
			Server_AddMoney(value);
			Info(playerid, "Anda berhasil membeli "GREEN_E"%d "WHITE_E"Marijuana seharga "RED_E"%s.", amount, FormatMoney(value));
		}
	}
	if(dialogid == DIALOG_FOOD)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					//buy food
					if(pData[playerid][pFood] > 500) return Error(playerid, "Anda sudah membawa 500 Food!");
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Masukan jumlah Food:\nFood Stock: "GREEN_E"%d\n"WHITE_E"Food Price"GREEN_E"%s /item", Food, FormatMoney(FoodPrice));
					ShowPlayerDialog(playerid, DIALOG_FOOD_BUY, DIALOG_STYLE_INPUT, "Buy Food", mstr, "Buy", "Cancel");
				}
				case 1:
				{
					//buy seed
					if(pData[playerid][pSeed] > 100) return Error(playerid, "Anda sudah membawa 100 Seed!");
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Masukan jumlah Seed:\nFood Stock: "GREEN_E"%d\n"WHITE_E"Seed Price"GREEN_E"%s /item", Food, FormatMoney(SeedPrice));
					ShowPlayerDialog(playerid, DIALOG_SEED_BUY, DIALOG_STYLE_INPUT, "Buy Seed", mstr, "Buy", "Cancel");
				}
			}
		}
	}
	if(dialogid == DIALOG_FOOD_BUY)
	{
		if(response)
		{
			new amount = floatround(strval(inputtext));
			new total = pData[playerid][pFood] + amount;
			new value = amount * FoodPrice;
			if(amount < 0 || amount > 500) return Error(playerid, "amount maximal 0 - 500.");
			if(total > 500) return Error(playerid, "Food too full in your inventory! Maximal 500.");
			if(GetPlayerMoney(playerid) < value) return Error(playerid, "Uang anda kurang.");
			if(Food < amount) return Error(playerid, "Food stock tidak mencukupi.");
			GivePlayerMoneyEx(playerid, -value);
			pData[playerid][pFood] += amount;
			Food -= amount;
			Server_AddMoney(value);
			Info(playerid, "Anda berhasil membeli "GREEN_E"%d "WHITE_E"Food seharga "RED_E"%s.", amount, FormatMoney(value));
		}
	}
	if(dialogid == DIALOG_SEED_BUY)
	{
		if(response)
		{
			new amount = floatround(strval(inputtext));
			new total = pData[playerid][pSeed] + amount;
			new value = amount * SeedPrice;
			if(amount < 0 || amount > 100) return Error(playerid, "amount maximal 0 - 100.");
			if(total > 100) return Error(playerid, "Seed too full in your inventory! Maximal 100.");
			if(GetPlayerMoney(playerid) < value) return Error(playerid, "Uang anda kurang.");
			if(Food < amount) return Error(playerid, "Food stock tidak mencukupi.");
			GivePlayerMoneyEx(playerid, -value);
			pData[playerid][pSeed] += amount;
			Food -= amount;
			Server_AddMoney(value);
			Info(playerid, "Anda berhasil membeli "GREEN_E"%d "WHITE_E"Seed seharga "RED_E"%s.", amount, FormatMoney(value));
		}
	}
	if(dialogid == DIALOG_EDIT_PRICE)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Masukan harga Sprunk(1 - 500):\nPrice 1(Sprunk): "GREEN_E"%s", FormatMoney(pData[playerid][pPrice1]));
					ShowPlayerDialog(playerid, DIALOG_EDIT_PRICE1, DIALOG_STYLE_INPUT, "Price 1", mstr, "Edit", "Cancel");
				}
				case 1:
				{
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Masukan harga Snack(1 - 500):\nPrice 2(Snack): "GREEN_E"%s", FormatMoney(pData[playerid][pPrice2]));
					ShowPlayerDialog(playerid, DIALOG_EDIT_PRICE2, DIALOG_STYLE_INPUT, "Price 2", mstr, "Edit", "Cancel");
				}
				case 2:
				{
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Masukan harga Ice Cream Orange(1 - 500):\nPrice 3(Ice Cream Orange): "GREEN_E"%s", FormatMoney(pData[playerid][pPrice3]));
					ShowPlayerDialog(playerid, DIALOG_EDIT_PRICE3, DIALOG_STYLE_INPUT, "Price 3", mstr, "Edit", "Cancel");
				}
				case 3:
				{
					new mstr[128];
					format(mstr, sizeof(mstr), ""WHITE_E"Masukan harga Hotdog(1 - 500):\nPrice 4(Hotdog): "GREEN_E"%s", FormatMoney(pData[playerid][pPrice4]));
					ShowPlayerDialog(playerid, DIALOG_EDIT_PRICE4, DIALOG_STYLE_INPUT, "Price 4", mstr, "Edit", "Cancel");
				}
			}
		}
	}
	if(dialogid == DIALOG_EDIT_PRICE1)
	{
		if(response)
		{
			new amount = floatround(strval(inputtext));
			
			if(amount < 0 || amount > 500) return Error(playerid, "Invalid price! 1 - 500.");
			pData[playerid][pPrice1] = amount;
			Info(playerid, "Anda berhasil mengedit price 1(Sprunk) ke "GREEN_E"%s.", FormatMoney(amount));
			return 1;
		}
	}
	if(dialogid == DIALOG_EDIT_PRICE2)
	{
		if(response)
		{
			new amount = floatround(strval(inputtext));
			
			if(amount < 0 || amount > 500) return Error(playerid, "Invalid price! 1 - 500.");
			pData[playerid][pPrice2] = amount;
			Info(playerid, "Anda berhasil mengedit price 2(Snack) ke "GREEN_E"%s.", FormatMoney(amount));
			return 1;
		}
	}
	if(dialogid == DIALOG_EDIT_PRICE3)
	{
		if(response)
		{
			new amount = floatround(strval(inputtext));
			
			if(amount < 0 || amount > 500) return Error(playerid, "Invalid price! 1 - 500.");
			pData[playerid][pPrice3] = amount;
			Info(playerid, "Anda berhasil mengedit price 3(Ice Cream Orange) ke "GREEN_E"%s.", FormatMoney(amount));
			return 1;
		}
	}
	if(dialogid == DIALOG_EDIT_PRICE4)
	{
		if(response)
		{
			new amount = floatround(strval(inputtext));
			
			if(amount < 0 || amount > 500) return Error(playerid, "Invalid price! 1 - 500.");
			pData[playerid][pPrice4] = amount;
			Info(playerid, "Anda berhasil mengedit price 4(Hotdog) ke "GREEN_E"%s.", FormatMoney(amount));
			return 1;
		}
	}
	if(dialogid == DIALOG_OFFER)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new id = pData[playerid][pOffer];
					if(!IsPlayerConnected(id) || !NearPlayer(playerid, id, 4.0))
						return Error(playerid, "You not near with offer player!");
					
					if(GetPlayerMoney(playerid) < pData[id][pPrice1])
						return Error(playerid, "Not enough money!");
						
					if(pData[id][pFood] < 5)
						return Error(playerid, "Food stock empty!");
					
					GivePlayerMoneyEx(id, pData[id][pPrice1]);
					pData[id][pFood] -= 5;
					
					GivePlayerMoneyEx(playerid, -pData[id][pPrice1]);
					pData[playerid][pSprunk] += 1;
					
					SendNearbyMessage(playerid, 10.0, COLOR_PURPLE, "** %s telah membeli sprunk seharga %s.", ReturnName(playerid), FormatMoney(pData[id][pPrice1]));
				}
				case 1:
				{
					new id = pData[playerid][pOffer];
					if(!IsPlayerConnected(id) || !NearPlayer(playerid, id, 4.0))
						return Error(playerid, "You not near with offer player!");
					
					if(GetPlayerMoney(playerid) < pData[id][pPrice2])
						return Error(playerid, "Not enough money!");
					
					if(pData[id][pFood] < 5)
						return Error(playerid, "Food stock empty!");
						
					GivePlayerMoneyEx(id, pData[id][pPrice2]);
					pData[id][pFood] -= 5;
					
					GivePlayerMoneyEx(playerid, -pData[id][pPrice2]);
					pData[playerid][pSnack] += 1;
					
					SendNearbyMessage(playerid, 10.0, COLOR_PURPLE, "** %s telah membeli snack seharga %s.", ReturnName(playerid), FormatMoney(pData[id][pPrice2]));	
				}
				case 2:
				{
					new id = pData[playerid][pOffer];
					if(!IsPlayerConnected(id) || !NearPlayer(playerid, id, 4.0))
						return Error(playerid, "You not near with offer player!");
					
					if(GetPlayerMoney(playerid) < pData[id][pPrice3])
						return Error(playerid, "Not enough money!");
					
					if(pData[id][pFood] < 10)
						return Error(playerid, "Food stock empty!");
						
					GivePlayerMoneyEx(id, pData[id][pPrice3]);
					pData[id][pFood] -= 10;
					
					GivePlayerMoneyEx(playerid, -pData[id][pPrice3]);
					pData[playerid][pEnergy] += 30;
					
					SendNearbyMessage(playerid, 10.0, COLOR_PURPLE, "** %s telah membeli ice cream orange seharga %s.", ReturnName(playerid), FormatMoney(pData[id][pPrice3]));
				}
				case 3:
				{
					new id = pData[playerid][pOffer];
					if(!IsPlayerConnected(id) || !NearPlayer(playerid, id, 4.0))
						return Error(playerid, "You not near with offer player!");
					
					if(GetPlayerMoney(playerid) < pData[id][pPrice4])
						return Error(playerid, "Not enough money!");
						
					if(pData[id][pFood] < 10)
						return Error(playerid, "Food stock empty!");
					
					GivePlayerMoneyEx(id, pData[id][pPrice4]);
					pData[id][pFood] -= 10;
					
					GivePlayerMoneyEx(playerid, -pData[id][pPrice4]);
					pData[playerid][pHunger] += 30;
					
					SendNearbyMessage(playerid, 10.0, COLOR_PURPLE, "** %s telah membeli hotdog seharga %s.", ReturnName(playerid), FormatMoney(pData[id][pPrice4]));
				}
			}
		}
		pData[playerid][pOffer] = -1;
	}
	if(dialogid == DIALOG_APOTEK)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					if(Apotek < 1) return Error(playerid, "Product out of stock!");
					if(GetPlayerMoney(playerid) < 10) return Error(playerid, "Not enough money.");
					pData[playerid][pMedicine]++;
					Apotek--;
					GivePlayerMoneyEx(playerid, -10);
					Server_AddMoney(10);
					Info(playerid, "Anda membeli medicine seharga "RED_E"$10,"WHITE_E" /use untuk menggunakannya.", FormatMoney(MedicinePrice));
				}
				case 1:
				{
					if(Apotek < 1) return Error(playerid, "Product out of stock!");
					if(pData[playerid][pFaction] != 3) return Error(playerid, "You are not a medical member.");
					if(GetPlayerMoney(playerid) < 10) return Error(playerid, "Not enough money.");
					pData[playerid][pMedkit]++;
					Apotek--;
					GivePlayerMoneyEx(playerid, -10);
					Server_AddMoney(10);
					Info(playerid, "Anda membeli medkit seharga "RED_E"$10", FormatMoney(MedkitPrice));
				}
				case 2:
				{
					if(Apotek < 1) return Error(playerid, "Product out of stock!");
					if(pData[playerid][pFaction] != 3) return Error(playerid, "You are not a medical member.");
					if(GetPlayerMoney(playerid) < 10) return Error(playerid, "Not enough money.");
					pData[playerid][pBandage]++;
					Apotek--;
					GivePlayerMoneyEx(playerid, -10);
					Server_AddMoney(10);
					Info(playerid, "Anda membeli bandage seharga "RED_E"$10");
				}
			}
		}
	}
	if(dialogid == DIALOG_ATM)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0: // Check Balance
			{
				new mstr[512];
				format(mstr, sizeof(mstr), "{F6F6F6}You have "LB_E"%s {F6F6F6}in your bank account.", FormatMoney(pData[playerid][pBankMoney]));
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""LB_E"Bank", mstr, "Close", "");
			}
			case 1: // Withdraw
			{
				new mstr[128];
				format(mstr, sizeof(mstr), ""WHITE_E"My Balance: "LB_E"%s", FormatMoney(pData[playerid][pBankMoney]));
				ShowPlayerDialog(playerid, DIALOG_ATMWITHDRAW, DIALOG_STYLE_LIST, mstr, "$50\n$200\n$500\n$1.000\n$5.000", "Withdraw", "Cancel");
			}
			case 2: // Transfer Money
			{
				ShowPlayerDialog(playerid, DIALOG_BANKREKENING, DIALOG_STYLE_INPUT, ""LB_E"Bank", "Masukan jumlah uang:", "Transfer", "Cancel");
			}
			case 3: //Paycheck
			{
				DisplayPaycheck(playerid);
			}
		}
	}
	if(dialogid == DIALOG_ATMWITHDRAW)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new id = Iter_Free(ATMS);
					if(AtmData[id][atmStockMoney] < 50) return Info(playerid, "Uang Di Atm Ini Kurang.");
					if(pData[playerid][pBankMoney] < 50)
						return Error(playerid, "Uang Di Bank Mu Kurang.");
					
					GivePlayerMoneyEx(playerid, 50);
					pData[playerid][pBankMoney] -= 50;
					AtmData[id][atmStockMoney] -= 50;
					Info(playerid, "ATM withdraw "LG_E"$50");
				}
				case 1:
				{
					new id = Iter_Free(ATMS);
					if(AtmData[id][atmStockMoney] < 200) return Info(playerid, "Uang Di Atm Ini Kurang.");
					if(pData[playerid][pBankMoney] < 200)
						return Error(playerid, "Uang Di Bank Mu Kurang.");
					
					GivePlayerMoneyEx(playerid, 200);
					pData[playerid][pBankMoney] -= 200;
					AtmData[id][atmStockMoney] -= 200;
					Info(playerid, "ATM withdraw "LG_E"$200");
				}
				case 2:
				{
					new id = Iter_Free(ATMS);
					if(AtmData[id][atmStockMoney] < 500) return Info(playerid, "Uang Di Atm Ini Kurang.");
					if(pData[playerid][pBankMoney] < 500)
						return Error(playerid, "Uang Di Bank Mu Kurang.");
					
					GivePlayerMoneyEx(playerid, 500);
					pData[playerid][pBankMoney] -= 500;
					AtmData[id][atmStockMoney] -= 500;
					Info(playerid, "ATM withdraw "LG_E"$500");
				}
				case 3:
				{
					new id = Iter_Free(ATMS);
					if(AtmData[id][atmStockMoney] < 1000) return Info(playerid, "Uang Di Atm Ini Kurang.");
					if(pData[playerid][pBankMoney] < 1000)
						return Error(playerid, "Uang Di Bank Mu Kurang.");
					
					GivePlayerMoneyEx(playerid, 1000);
					pData[playerid][pBankMoney] -= 1000;
					AtmData[id][atmStockMoney] -= 1000;
					Info(playerid, "ATM withdraw "LG_E"$1.000");
				}
				case 4:
				{
					new id = Iter_Free(ATMS);
					if(AtmData[id][atmStockMoney] < 5000) return Info(playerid, "Uang Di Atm Ini Kurang.");
					if(pData[playerid][pBankMoney] < 5000)
						return Error(playerid, "Uang Di Bank Mu Kurang.");
					
					GivePlayerMoneyEx(playerid, 5000);
					pData[playerid][pBankMoney] -= 5000;
					AtmData[id][atmStockMoney] -= 5000;
					Info(playerid, "ATM withdraw "LG_E"$5.000");
				}
			}
		}
	}
	if(dialogid == DIALOG_BANK)
	{
		if(!response) return true;
		switch(listitem)
		{
			case 0: // Deposit
			{
				new mstr[512];
				format(mstr, sizeof(mstr), "{F6F6F6}You have "LB_E"%s {F6F6F6}in bank account.\n\nType in the amount you want to deposit below:", FormatMoney(pData[playerid][pBankMoney]));
				ShowPlayerDialog(playerid, DIALOG_BANKDEPOSIT, DIALOG_STYLE_INPUT, ""LB_E"Bank", mstr, "Deposit", "Cancel");
			}
			case 1: // Withdraw
			{
				new mstr[512];
				format(mstr, sizeof(mstr), "{F6F6F6}You have "LB_E"%s {F6F6F6}in your bank account.\n\nType in the amount you want to withdraw below:", FormatMoney(pData[playerid][pBankMoney]));
				ShowPlayerDialog(playerid, DIALOG_BANKWITHDRAW, DIALOG_STYLE_INPUT, ""LB_E"Bank", mstr, "Withdraw", "Cancel");
			}
			case 2: // Check Balance
			{
				new mstr[512];
				format(mstr, sizeof(mstr), "{F6F6F6}You have "LB_E"%s {F6F6F6}in your bank account.", FormatMoney(pData[playerid][pBankMoney]));
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""LB_E"Bank", mstr, "Close", "");
			}
			case 3: //Transfer Money
			{
				ShowPlayerDialog(playerid, DIALOG_BANKREKENING, DIALOG_STYLE_INPUT, ""LB_E"Bank", "Masukan jumlah uang:", "Transfer", "Cancel");
			}
			case 4:
			{
				DisplayPaycheck(playerid);
			}
		}
	}
	if(dialogid == DIALOG_BANKDEPOSIT)
	{
		if(!response) return true;
		new amount = floatround(strval(inputtext));
		if(amount > pData[playerid][pMoney]) return Error(playerid, "You do not have the sufficient funds to make this transaction.");
		if(amount < 1) return Error(playerid, "You have entered an invalid amount!");

		else
		{
			new query[512], lstr[512];
			pData[playerid][pBankMoney] = (pData[playerid][pBankMoney] + amount);
			GivePlayerMoneyEx(playerid, -amount);
			mysql_format(g_SQL, query, sizeof(query), "UPDATE players SET bmoney=%d,money=%d WHERE reg_id=%d", pData[playerid][pBankMoney], pData[playerid][pMoney], pData[playerid][pID]);
			mysql_tquery(g_SQL, query);
			format(lstr, sizeof(lstr), "{F6F6F6}You have successfully deposited "LB_E"%s {F6F6F6}into your bank account.\n"LB_E"Current Balance: {F6F6F6}%s", FormatMoney(amount), FormatMoney(pData[playerid][pBankMoney]));
			ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""ORANGE_E"XGRP: "LB_E"Bank", lstr, "Close", "");
		}
	}
	if(dialogid == DIALOG_BANKWITHDRAW)
	{
		if(!response) return true;
		new amount = floatround(strval(inputtext));
		if(amount > pData[playerid][pBankMoney]) return Error(playerid, "You do not have the sufficient funds to make this transaction.");
		if(amount < 1) return Error(playerid, "You have entered an invalid amount!");
		else
		{
			new query[128], lstr[512];
			pData[playerid][pBankMoney] = (pData[playerid][pBankMoney] - amount);
			GivePlayerMoneyEx(playerid, amount);
			mysql_format(g_SQL, query, sizeof(query), "UPDATE players SET bmoney=%d,money=%d WHERE reg_id=%d", pData[playerid][pBankMoney], pData[playerid][pMoney], pData[playerid][pID]);
			mysql_tquery(g_SQL, query);
			format(lstr, sizeof(lstr), "{F6F6F6}You have successfully withdrawed "LB_E"%s {F6F6F6}from your bank account.\n"LB_E"Current Balance: {F6F6F6}%s", FormatMoney(amount), FormatMoney(pData[playerid][pBankMoney]));
			ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, ""ORANGE_E"XGRP: "LB_E"Bank", lstr, "Close", "");
		}
	}
	if(dialogid == DIALOG_BANKREKENING)
	{
		if(!response) return true;
		new amount = floatround(strval(inputtext));
		if(amount > pData[playerid][pBankMoney]) return Error(playerid, "Uang dalam rekening anda kurang.");
		if(amount < 1) return Error(playerid, "You have entered an invalid amount!");

		else
		{
			pData[playerid][pTransfer] = amount;
			ShowPlayerDialog(playerid, DIALOG_BANKTRANSFER, DIALOG_STYLE_INPUT, ""LB_E"Bank", "Masukan nomor rekening target:", "Transfer", "Cancel");
		}
	}
	if(dialogid == DIALOG_BANKTRANSFER)
	{
		if(!response) return true;
		new rek = floatround(strval(inputtext)), query[128];
		
		mysql_format(g_SQL, query, sizeof(query), "SELECT brek FROM players WHERE brek='%d'", rek);
		mysql_tquery(g_SQL, query, "SearchRek", "id", playerid, rek);
		return 1;
	}
	if(dialogid == DIALOG_BANKCONFIRM)
	{
		if(response)
		{
			new query[128], mstr[248];
			mysql_format(g_SQL, query, sizeof(query), "UPDATE players SET bmoney=bmoney+%d WHERE brek=%d", pData[playerid][pTransfer], pData[playerid][pTransferRek]);
			mysql_tquery(g_SQL, query);
			
			foreach(new ii : Player)
			{
				if(pData[ii][pBankRek] == pData[playerid][pTransferRek])
				{
					pData[ii][pBankMoney] += pData[playerid][pTransfer];
				}
			}
			
			pData[playerid][pBankMoney] -= pData[playerid][pTransfer];
			
			format(mstr, sizeof(mstr), ""WHITE_E"No Rek Target: "YELLOW_E"%d\n"WHITE_E"Nama Target: "YELLOW_E"%s\n"WHITE_E"Jumlah: "GREEN_E"%s\n\n"WHITE_E"Anda telah berhasil mentransfer!", pData[playerid][pTransferRek], pData[playerid][pTransferName], FormatMoney(pData[playerid][pTransfer]));
			ShowPlayerDialog(playerid, DIALOG_BANKSUKSES, DIALOG_STYLE_MSGBOX, ""LB_E"Transfer Sukses", mstr, "Sukses", "");
		}
	}
	if(dialogid == DIALOG_BANKSUKSES)
	{
		if(response)
		{
			pData[playerid][pTransfer] = 0;
			pData[playerid][pTransferRek] = 0;
		}
	}
	if(dialogid == DIALOG_REPORTS)
	{
		if(response) 
		{
			//new i = strval(inputtext);
			new i = listitem;
			new tstr[64], mstr[128], lstr[512];

			strunpack(mstr, ReportData[i][rText]);
			format(tstr, sizeof(tstr), ""GREEN_E"Report Id: #%d", i);
			format(lstr,sizeof(lstr),""WHITE_E"Reported: "GREEN_E"%s\n"WHITE_E"Reason: "RED_E"%s.", pData[ReportData[i][rPlayer]][pName], mstr);
			ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX,tstr,lstr,"Close","");
		}
	}
	if(dialogid == DIALOG_BUYPV)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		if(response)
		{
			if(!IsPlayerInAnyVehicle(playerid))
			{
				TogglePlayerControllable(playerid, 1);
				Error(playerid,"Anda harus berada di dalam kendaraan untuk membelinya.");
				return 1;
			}
			new cost = GetVehicleCost(GetVehicleModel(vehicleid));
			if(pData[playerid][pMoney] < cost)
			{
				Error(playerid, "Uang anda tidak mencukupi.!");
				RemovePlayerFromVehicle(playerid);
				//new Float:slx, Float:sly, Float:slz;
				//GetPlayerPos(playerid, slx, sly, slz);
				//SetPlayerPos(playerid, slx, sly+1.2, slz+1.3);
				//TogglePlayerControllable(playerid, 1);
				//SetVehicleToRespawn(vehicleid);
				SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
				return 1;
			}
			//if(playerid == INVALID_PLAYER_ID) return Error(playerid, "Invalid player ID!");
			new count = 0, limit = MAX_PLAYER_VEHICLE + pData[playerid][pVip];
			foreach(new ii : PVehicles)
			{
				if(pvData[ii][cOwner] == pData[playerid][pID])
					count++;
			}
			if(count >= limit)
			{
				Error(playerid, "Slot kendaraan anda sudah penuh, silahkan jual beberapa kendaraan anda terlebih dahulu!");
				RemovePlayerFromVehicle(playerid);
				//new Float:slx, Float:sly, Float:slz;
				//GetPlayerPos(playerid, slx, sly, slz);
				//SetPlayerPos(playerid, slx, sly, slz+1.3);
				//TogglePlayerControllable(playerid, 1);
				//SetVehicleToRespawn(vehicleid);
				SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
				return 1;
			}
			GivePlayerMoneyEx(playerid, -cost);
			new cQuery[1024];
			new Float:x,Float:y,Float:z, Float:a;
			new model, color1, color2;
			color1 = 0;
			color2 = 0;
			model = GetVehicleModel(GetPlayerVehicleID(playerid));
			x = 1805.93;
			y = -1791.19;
			z = 13.54;
			a = 2.22;
			mysql_format(g_SQL, cQuery, sizeof(cQuery), "INSERT INTO `vehicle` (`owner`, `model`, `color1`, `color2`, `price`, `x`, `y`, `z`, `a`) VALUES (%d, %d, %d, %d, %d, '%f', '%f', '%f', '%f')", pData[playerid][pID], model, color1, color2, cost, x, y, z, a);
			mysql_tquery(g_SQL, cQuery, "OnVehBuyPV", "ddddddffff", playerid, pData[playerid][pID], model, color1, color2, cost, x, y, z, a);
			/*new cQuery[1024], model = GetVehicleModel(GetPlayerVehicleID(playerid)), color1 = 0, color2 = 0,
			Float:x = 1805.13, Float:y = -1708.09, Float:z = 13.54, Float:a = 179.23, price = GetVehicleCost(GetVehicleModel(GetPlayerVehicleID(playerid)));
			format(cQuery, sizeof(cQuery), "INSERT INTO `vehicle` (`owner`, `model`, `color1`, `color2`, `price`, `x`, `y`, `z`, `a`) VALUES (%d, %d, %d, %d, '%f', '%f', '%f', '%f')", pData[playerid][pID], model, color1, color2, price, x, y, z, a);
			MySQL_query(cQuery, false, "OnVehBuyed", "ddddddffff", playerid, pData[playerid][pID], model, color1, color2, price, x, y, z, a);
			Servers(playerid, "harusnya bisaa");*/
			return 1;
		}
		else
		{
			RemovePlayerFromVehicle(playerid);
			//new Float:slx, Float:sly, Float:slz;
			//GetPlayerPos(playerid, slx, sly, slz);
			//SetPlayerPos(playerid, slx, sly, slz+1.3);
			//TogglePlayerControllable(playerid, 1);
			//SetVehicleToRespawn(vehicleid);
			SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
			return 1;
		}
	}
	if(dialogid == DIALOG_BUYVIPPV)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		if(response)
		{
			if(!IsPlayerInAnyVehicle(playerid))
			{
				TogglePlayerControllable(playerid, 1);
				Error(playerid,"Anda harus berada di dalam kendaraan untuk membelinya.");
				return 1;
			}
			new gold = GetVipVehicleCost(GetVehicleModel(vehicleid));
			new cost = GetVehicleCost(GetVehicleModel(vehicleid));
			if(pData[playerid][pGold] < gold)
			{
				Error(playerid, "gold anda tidak mencukupi!");
				RemovePlayerFromVehicle(playerid);
				//new Float:slx, Float:sly, Float:slz;
				//GetPlayerPos(playerid, slx, sly, slz);
				//SetPlayerPos(playerid, slx, sly, slz+1.3);
				//TogglePlayerControllable(playerid, 1);
				//SetVehicleToRespawn(vehicleid);
				SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
				return 1;
			}
			//if(playerid == INVALID_PLAYER_ID) return Error(playerid, "Invalid player ID!");
			new count = 0, limit = MAX_PLAYER_VEHICLE + pData[playerid][pVip];
			foreach(new ii : PVehicles)
			{
				if(pvData[ii][cOwner] == pData[playerid][pID])
					count++;
			}
			if(count >= limit)
			{
				Error(playerid, "Slot kendaraan anda sudah penuh, silahkan jual beberapa kendaraan anda terlebih dahulu!");
				RemovePlayerFromVehicle(playerid);
				//new Float:slx, Float:sly, Float:slz;
				//GetPlayerPos(playerid, slx, sly, slz);
				//SetPlayerPos(playerid, slx, sly, slz+1.3);
				//TogglePlayerControllable(playerid, 1);
				//SetVehicleToRespawn(vehicleid);
				SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
				return 1;
			}
			pData[playerid][pGold] -= gold;
			new cQuery[1024];
			new Float:x,Float:y,Float:z, Float:a;
			new model, color1, color2;
			color1 = 0;
			color2 = 0;
			model = GetVehicleModel(GetPlayerVehicleID(playerid));
			x = 1805.93;
			y = -1791.19;
			z = 13.54;
			a = 2.22;
			mysql_format(g_SQL, cQuery, sizeof(cQuery), "INSERT INTO `vehicle` (`owner`, `model`, `color1`, `color2`, `price`, `x`, `y`, `z`, `a`) VALUES (%d, %d, %d, %d, %d, '%f', '%f', '%f', '%f')", pData[playerid][pID], model, color1, color2, cost, x, y, z, a);
			mysql_tquery(g_SQL, cQuery, "OnVehBuyVIPPV", "ddddddffff", playerid, pData[playerid][pID], model, color1, color2, cost, x, y, z, a);
			/*new cQuery[1024], model = GetVehicleModel(GetPlayerVehicleID(playerid)), color1 = 0, color2 = 0,
			Float:x = 1805.13, Float:y = -1708.09, Float:z = 13.54, Float:a = 179.23, price = GetVehicleCost(GetVehicleModel(GetPlayerVehicleID(playerid)));
			format(cQuery, sizeof(cQuery), "INSERT INTO `vehicle` (`owner`, `model`, `color1`, `color2`, `price`, `x`, `y`, `z`, `a`) VALUES (%d, %d, %d, %d, '%f', '%f', '%f', '%f')", pData[playerid][pID], model, color1, color2, price, x, y, z, a);
			MySQL_query(cQuery, false, "OnVehBuyed", "ddddddffff", playerid, pData[playerid][pID], model, color1, color2, price, x, y, z, a);
			Servers(playerid, "harusnya bisaa");*/
			return 1;
		}
		else
		{
			RemovePlayerFromVehicle(playerid);
			//new Float:slx, Float:sly, Float:slz;
			//GetPlayerPos(playerid, slx, sly, slz);
			//SetPlayerPos(playerid, slx, sly, slz+1.3);
			//TogglePlayerControllable(playerid, 1);
			//SetVehicleToRespawn(vehicleid);
			SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
			return 1;
		}
	}
	if(dialogid == DIALOG_BUYPVCP)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					//Bikes
					new str[1024];
					/*format(str, sizeof(str), "%s"WHITE_E"%s\t"LG_E"%s\n", str, GetVehicleModelName(481), FormatMoney(GetVehicleCost(481)));
					format(str, sizeof(str), "%s"WHITE_E"%s\t"LG_E"%s\n", str, GetVehicleModelName(509), FormatMoney(GetVehicleCost(509)));
					format(str, sizeof(str), "%s"WHITE_E"%s\t"LG_E"%s\n", str, GetVehicleModelName(510), FormatMoney(GetVehicleCost(510)));
					format(str, sizeof(str), "%s"WHITE_E"%s\t"LG_E"%s\n", str, GetVehicleModelName(462), FormatMoney(GetVehicleCost(462)));
					format(str, sizeof(str), "%s"WHITE_E"%s\t"LG_E"%s\n", str, GetVehicleModelName(586), FormatMoney(GetVehicleCost(586)));
					format(str, sizeof(str), "%s"WHITE_E"%s\t"LG_E"%s\n", str, GetVehicleModelName(581), FormatMoney(GetVehicleCost(581)));
					format(str, sizeof(str), "%s"WHITE_E"%s\t"LG_E"%s\n", str, GetVehicleModelName(461), FormatMoney(GetVehicleCost(461)));
					format(str, sizeof(str), "%s"WHITE_E"%s\t"LG_E"%s\n", str, GetVehicleModelName(521), FormatMoney(GetVehicleCost(521)));
					format(str, sizeof(str), "%s"WHITE_E"%s\t"LG_E"%s\n", str, GetVehicleModelName(463), FormatMoney(GetVehicleCost(463)));
					format(str, sizeof(str), "%s"WHITE_E"%s\t"LG_E"%s\n", str, GetVehicleModelName(468), FormatMoney(GetVehicleCost(468)));*/
					
					format(str, sizeof(str), ""WHITE_E"%s\t\t"LG_E"%s\n%s\t\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n", 
					GetVehicleModelName(481), FormatMoney(GetVehicleCost(481)), 
					GetVehicleModelName(509), FormatMoney(GetVehicleCost(509)),
					GetVehicleModelName(510), FormatMoney(GetVehicleCost(510)),
					GetVehicleModelName(462), FormatMoney(GetVehicleCost(462)),
					GetVehicleModelName(586), FormatMoney(GetVehicleCost(586)),
					GetVehicleModelName(581), FormatMoney(GetVehicleCost(581)),
					GetVehicleModelName(461), FormatMoney(GetVehicleCost(461)),
					GetVehicleModelName(521), FormatMoney(GetVehicleCost(521)),
					GetVehicleModelName(463), FormatMoney(GetVehicleCost(463)),
					GetVehicleModelName(468), FormatMoney(GetVehicleCost(468))
					);
					
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_BIKES, DIALOG_STYLE_LIST, "Bikes", str, "Buy", "Close");
				}
				case 1:
				{
					//Cars
					new str[1024];
					format(str, sizeof(str), ""WHITE_E"%s\t\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n", 
					GetVehicleModelName(400), FormatMoney(GetVehicleCost(400)), 
					GetVehicleModelName(412), FormatMoney(GetVehicleCost(412)),
					GetVehicleModelName(419), FormatMoney(GetVehicleCost(419)),
					GetVehicleModelName(426), FormatMoney(GetVehicleCost(426)),
					GetVehicleModelName(436), FormatMoney(GetVehicleCost(436)),
					GetVehicleModelName(466), FormatMoney(GetVehicleCost(466)),
					GetVehicleModelName(467), FormatMoney(GetVehicleCost(467)),
					GetVehicleModelName(474), FormatMoney(GetVehicleCost(474)),
					GetVehicleModelName(475), FormatMoney(GetVehicleCost(475)),
					GetVehicleModelName(480), FormatMoney(GetVehicleCost(480)),
					GetVehicleModelName(603), FormatMoney(GetVehicleCost(603)),
					GetVehicleModelName(421), FormatMoney(GetVehicleCost(421)),
					GetVehicleModelName(602), FormatMoney(GetVehicleCost(602)),
					GetVehicleModelName(492), FormatMoney(GetVehicleCost(492)),
					GetVehicleModelName(545), FormatMoney(GetVehicleCost(545)),
					GetVehicleModelName(489), FormatMoney(GetVehicleCost(489)),
					GetVehicleModelName(405), FormatMoney(GetVehicleCost(405)),
					GetVehicleModelName(445), FormatMoney(GetVehicleCost(445)),
					GetVehicleModelName(579), FormatMoney(GetVehicleCost(579)),
					GetVehicleModelName(507), FormatMoney(GetVehicleCost(507))
					);
					
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CARS, DIALOG_STYLE_LIST, "Cars", str, "Buy", "Close");
				}
				case 2:
				{
					//Unique Cars
					new str[1024];
					format(str, sizeof(str), ""WHITE_E"%s\t\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n", 
					GetVehicleModelName(483), FormatMoney(GetVehicleCost(483)), 
					GetVehicleModelName(534), FormatMoney(GetVehicleCost(534)),
					GetVehicleModelName(535), FormatMoney(GetVehicleCost(535)),
					GetVehicleModelName(536), FormatMoney(GetVehicleCost(536)),
					GetVehicleModelName(558), FormatMoney(GetVehicleCost(558)),
					GetVehicleModelName(559), FormatMoney(GetVehicleCost(559)),
					GetVehicleModelName(560), FormatMoney(GetVehicleCost(560)),
					GetVehicleModelName(561), FormatMoney(GetVehicleCost(561)),
					GetVehicleModelName(562), FormatMoney(GetVehicleCost(562)),
					GetVehicleModelName(565), FormatMoney(GetVehicleCost(565)),
					GetVehicleModelName(567), FormatMoney(GetVehicleCost(567)),
					GetVehicleModelName(575), FormatMoney(GetVehicleCost(575)),
					GetVehicleModelName(576), FormatMoney(GetVehicleCost(576))
					);
					
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_UCARS, DIALOG_STYLE_LIST, "Unique Cars", str, "Buy", "Close");
				}
				case 3:
				{
					//Job Cars
					new str[1024];
					format(str, sizeof(str), ""WHITE_E"%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s\n%s\t"LG_E"%s", 
					GetVehicleModelName(420), FormatMoney(GetVehicleCost(420)), 
					GetVehicleModelName(438), FormatMoney(GetVehicleCost(438)), 
					GetVehicleModelName(403), FormatMoney(GetVehicleCost(403)), 
					GetVehicleModelName(413), FormatMoney(GetVehicleCost(413)),
					GetVehicleModelName(414), FormatMoney(GetVehicleCost(414)),
					GetVehicleModelName(422), FormatMoney(GetVehicleCost(422)),
					GetVehicleModelName(440), FormatMoney(GetVehicleCost(440)),
					GetVehicleModelName(455), FormatMoney(GetVehicleCost(455)),
					GetVehicleModelName(456), FormatMoney(GetVehicleCost(456)),
					GetVehicleModelName(478), FormatMoney(GetVehicleCost(478)),
					GetVehicleModelName(482), FormatMoney(GetVehicleCost(482)),
					GetVehicleModelName(498), FormatMoney(GetVehicleCost(498)),
					GetVehicleModelName(499), FormatMoney(GetVehicleCost(499)),
					GetVehicleModelName(423), FormatMoney(GetVehicleCost(423)),
					GetVehicleModelName(588), FormatMoney(GetVehicleCost(588)),
					GetVehicleModelName(524), FormatMoney(GetVehicleCost(524)),
					GetVehicleModelName(525), FormatMoney(GetVehicleCost(525)),
					GetVehicleModelName(543), FormatMoney(GetVehicleCost(543)),
					GetVehicleModelName(552), FormatMoney(GetVehicleCost(552)),
					GetVehicleModelName(554), FormatMoney(GetVehicleCost(554)),
					GetVehicleModelName(578), FormatMoney(GetVehicleCost(578)),
					GetVehicleModelName(609), FormatMoney(GetVehicleCost(609))
					//GetVehicleModelName(530), FormatMoney(GetVehicleCost(530)) //fortklift
					);
					
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_JOBCARS, DIALOG_STYLE_LIST, "Job Cars", str, "Buy", "Close");
				}
				case 4:
				{
					// VIP Cars
					new str[1024];
					format(str, sizeof(str), ""WHITE_E"%s\t\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n%s\t"YELLOW_E"%d gold\n", 
					GetVehicleModelName(522), GetVipVehicleCost(522), 
					GetVehicleModelName(411), GetVipVehicleCost(411), 
					GetVehicleModelName(451), GetVipVehicleCost(451),
					GetVehicleModelName(415), GetVipVehicleCost(415), 
					GetVehicleModelName(402), GetVipVehicleCost(402), 
					GetVehicleModelName(541), GetVipVehicleCost(541), 
					GetVehicleModelName(429), GetVipVehicleCost(429), 
					GetVehicleModelName(506), GetVipVehicleCost(506), 
					GetVehicleModelName(494), GetVipVehicleCost(494), 
					GetVehicleModelName(502), GetVipVehicleCost(502), 
					GetVehicleModelName(503), GetVipVehicleCost(503), 
					GetVehicleModelName(409), GetVipVehicleCost(409), 
					GetVehicleModelName(477), GetVipVehicleCost(477)
					);
					
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCARS, DIALOG_STYLE_LIST, "Vip Cars", str, "Buy", "Close");
				}
			}
		}
	}
	if(dialogid == DIALOG_BUYPVCP_BIKES)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new modelid = 481;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 1:
				{
					new modelid = 509;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 2:
				{
					new modelid = 510;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 3:
				{
					new modelid = 462;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 4:
				{
					new modelid = 586;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 5:
				{
					new modelid = 581;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 6:
				{
					new modelid = 461;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 7:
				{
					new modelid = 521;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 8:
				{
					new modelid = 463;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 9:
				{
					new modelid = 468;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
			}
		}
	}
	if(dialogid == DIALOG_BUYPVCP_CARS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new modelid = 400;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 1:
				{
					new modelid = 412;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 2:
				{
					new modelid = 419;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 3:
				{
					new modelid = 426;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 4:
				{
					new modelid = 436;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 5:
				{
					new modelid = 466;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 6:
				{
					new modelid = 467;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 7:
				{
					new modelid = 474;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 8:
				{
					new modelid = 475;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 9:
				{
					new modelid = 480;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 10:
				{
					new modelid = 603;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 11:
				{
					new modelid = 421;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 12:
				{
					new modelid = 602;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 13:
				{
					new modelid = 492;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 14:
				{
					new modelid = 545;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 15:
				{
					new modelid = 489;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 16:
				{
					new modelid = 405;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 17:
				{
					new modelid = 445;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 18:
				{
					new modelid = 579;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 19:
				{
					new modelid = 507;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
			}
		}
	}
	if(dialogid == DIALOG_BUYPVCP_UCARS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new modelid = 483;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 1:
				{
					new modelid = 534;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 2:
				{
					new modelid = 535;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 3:
				{
					new modelid = 536;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 4:
				{
					new modelid = 558;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 5:
				{
					new modelid = 559;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 6:
				{
					new modelid = 560;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 7:
				{
					new modelid = 561;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 8:
				{
					new modelid = 562;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 9:
				{
					new modelid = 565;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 10:
				{
					new modelid = 567;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 11:
				{
					new modelid = 575;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 12:
				{
					new modelid = 576;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
			}
		}
	}
	if(dialogid == DIALOG_BUYPVCP_JOBCARS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new modelid = 420;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 1:
				{
					new modelid = 438;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 2:
				{
					new modelid = 403;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 3:
				{
					new modelid = 413;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 4:
				{
					new modelid = 414;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 5:
				{
					new modelid = 422;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 6:
				{
					new modelid = 440;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 7:
				{
					new modelid = 455;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 8:
				{
					new modelid = 456;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 9:
				{
					new modelid = 478;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 10:
				{
					new modelid = 482;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 11:
				{
					new modelid = 498;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 12:
				{
					new modelid = 499;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 13:
				{
					new modelid = 423;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 14:
				{
					new modelid = 588;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 15:
				{
					new modelid = 524;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 16:
				{
					new modelid = 525;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 17:
				{
					new modelid = 543;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 18:
				{
					new modelid = 552;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 19:
				{
					new modelid = 554;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 20:
				{
					new modelid = 578;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 21:
				{
					new modelid = 609;
					new tstr[128], price = GetVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"%s", GetVehicleModelName(modelid), FormatMoney(price));
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_CONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
			}
		}
	}
	if(dialogid == DIALOG_BUYPVCP_VIPCARS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new modelid = 522;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 1:
				{
					new modelid = 411;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 2:
				{
					new modelid = 451;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 3:
				{
					new modelid = 415;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 4:
				{
					new modelid = 502;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 5:
				{
					new modelid = 541;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 6:
				{
					new modelid = 429;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 7:
				{
					new modelid = 506;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 8:
				{
					new modelid = 494;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 9:
				{
					new modelid = 502;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 10:
				{
					new modelid = 503;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 11:
				{
					new modelid = 409;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
				case 12:
				{
					new modelid = 477;
					new tstr[128], price = GetVipVehicleCost(modelid);
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan membeli kendaraan "PINK_E"%s "WHITE_E"dengan harga "YELLOW_E"%d gold", GetVehicleModelName(modelid), price);
					ShowPlayerDialog(playerid, DIALOG_BUYPVCP_VIPCONFIRM, DIALOG_STYLE_MSGBOX, "Private Vehicles", tstr, "Buy", "Batal");
				}
			}
		}
	}
	if(dialogid == DIALOG_RENT_JOBCARS)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new modelid = 414;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 1:
				{
					new modelid = 455;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 2:
				{
					new modelid = 456;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 3:
				{
					new modelid = 498;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 4:
				{
					new modelid = 499;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 5:
				{
					new modelid = 609;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 6:
				{
					new modelid = 478;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 7:
				{
					new modelid = 422;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 8:
				{
					new modelid = 543;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 9:
				{
					new modelid = 554;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 10:
				{
					new modelid = 525;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 11:
				{
					new modelid = 438;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
				case 12:
				{
					new modelid = 420;
					new tstr[128];
					pData[playerid][pBuyPvModel] = modelid;
					format(tstr, sizeof(tstr), ""WHITE_E"Anda akan menyewa kendaraan "PINK_E"%s "WHITE_E"dengan harga "LG_E"$500 / one days", GetVehicleModelName(modelid));
					ShowPlayerDialog(playerid, DIALOG_RENT_JOBCARSCONFIRM, DIALOG_STYLE_MSGBOX, "Rental Vehicles", tstr, "Rental", "Batal");
				}
			}
		}
	}
	if(dialogid == DIALOG_RENT_JOBCARSCONFIRM)
	{
		new modelid = pData[playerid][pBuyPvModel];
		if(response)
		{
			if(modelid <= 0) return Error(playerid, "Invalid model id.");
			new cost = GetVehicleCost(modelid);
			if(pData[playerid][pMoney] < 500)
			{
				Error(playerid, "Uang anda tidak mencukupi.!");
				return 1;
			}
			new count = 0, limit = MAX_PLAYER_VEHICLE + pData[playerid][pVip];
			foreach(new ii : PVehicles)
			{
				if(pvData[ii][cOwner] == pData[playerid][pID])
					count++;
			}
			if(count >= limit)
			{
				Error(playerid, "Slot kendaraan anda sudah penuh, silahkan jual beberapa kendaraan anda terlebih dahulu!");
				return 1;
			}
			GivePlayerMoneyEx(playerid, -500);
			new cQuery[1024];
			new Float:x,Float:y,Float:z, Float:a;
			new model, color1, color2, rental;
			color1 = 0;
			color2 = 0;
			model = modelid;
			x = 1798.24;
			y = -1791.35;
			z = 13.53;
			a = 94.50;
			rental = gettime() + (1 * 86400);
			mysql_format(g_SQL, cQuery, sizeof(cQuery), "INSERT INTO `vehicle` (`owner`, `model`, `color1`, `color2`, `price`, `x`, `y`, `z`, `a`, `rental`) VALUES (%d, %d, %d, %d, %d, '%f', '%f', '%f', '%f', '%d')", pData[playerid][pID], model, color1, color2, cost, x, y, z, a, rental);
			mysql_tquery(g_SQL, cQuery, "OnVehRentPV", "ddddddffffd", playerid, pData[playerid][pID], model, color1, color2, cost, x, y, z, a, rental);
			return 1;
		}
		else
		{
			pData[playerid][pBuyPvModel] = 0;
		}
	}
	if(dialogid == DIALOG_BUYPVCP_CONFIRM)
	{
		new modelid = pData[playerid][pBuyPvModel];
		if(response)
		{
			if(modelid <= 0) return Error(playerid, "Invalid model id.");
			new cost = GetVehicleCost(modelid);
			if(pData[playerid][pMoney] < cost)
			{
				Error(playerid, "Uang anda tidak mencukupi.!");
				return 1;
			}
			new count = 0, limit = MAX_PLAYER_VEHICLE + pData[playerid][pVip];
			foreach(new ii : PVehicles)
			{
				if(pvData[ii][cOwner] == pData[playerid][pID])
					count++;
			}
			if(count >= limit)
			{
				Error(playerid, "Slot kendaraan anda sudah penuh, silahkan jual beberapa kendaraan anda terlebih dahulu!");
				return 1;
			}
			GivePlayerMoneyEx(playerid, -cost);
			new cQuery[1024];
			new Float:x,Float:y,Float:z, Float:a;
			new model, color1, color2;
			color1 = 0;
			color2 = 0;
			model = modelid;
			x = 1798.24;
			y = -1791.35;
			z = 13.53;
			a = 94.50;
			mysql_format(g_SQL, cQuery, sizeof(cQuery), "INSERT INTO `vehicle` (`owner`, `model`, `color1`, `color2`, `price`, `x`, `y`, `z`, `a`) VALUES (%d, %d, %d, %d, %d, '%f', '%f', '%f', '%f')", pData[playerid][pID], model, color1, color2, cost, x, y, z, a);
			mysql_tquery(g_SQL, cQuery, "OnVehBuyPV", "ddddddffff", playerid, pData[playerid][pID], model, color1, color2, cost, x, y, z, a);
			return 1;
		}
		else
		{
			pData[playerid][pBuyPvModel] = 0;
		}
	}
	if(dialogid == DIALOG_BUYPVCP_VIPCONFIRM)
	{
		new modelid = pData[playerid][pBuyPvModel];
		if(response)
		{
			if(modelid <= 0) return Error(playerid, "Invalid model id.");
			new cost = GetVipVehicleCost(modelid);
			if(pData[playerid][pGold] < cost)
			{
				Error(playerid, "Uang anda tidak mencukupi.!");
				return 1;
			}
			new count = 0, limit = MAX_PLAYER_VEHICLE + pData[playerid][pVip];
			foreach(new ii : PVehicles)
			{
				if(pvData[ii][cOwner] == pData[playerid][pID])
					count++;
			}
			if(count >= limit)
			{
				Error(playerid, "Slot kendaraan anda sudah penuh, silahkan jual beberapa kendaraan anda terlebih dahulu!");
				return 1;
			}
			pData[playerid][pGold] -= cost;
			new cQuery[1024];
			new Float:x,Float:y,Float:z, Float:a;
			new model, color1, color2;
			color1 = 0;
			color2 = 0;
			model = modelid;
			x = 1798.24;
			y = -1791.35;
			z = 13.53;
			a = 94.50;
			mysql_format(g_SQL, cQuery, sizeof(cQuery), "INSERT INTO `vehicle` (`owner`, `model`, `color1`, `color2`, `price`, `x`, `y`, `z`, `a`) VALUES (%d, %d, %d, %d, %d, '%f', '%f', '%f', '%f')", pData[playerid][pID], model, color1, color2, cost, x, y, z, a);
			mysql_tquery(g_SQL, cQuery, "OnVehBuyVIPPV", "ddddddffff", playerid, pData[playerid][pID], model, color1, color2, cost, x, y, z, a);
			return 1;
		}
		else
		{
			pData[playerid][pBuyPvModel] = 0;
		}
	}
	/*if(dialogid == DIALOG_SALARY)
	{
		if(!response) 
		{
			ListPage[playerid]--;
			if(ListPage[playerid] < 0)
			{
				ListPage[playerid] = 0;
				return 1;
			}
		}
		else
		{
			ListPage[playerid]++;
		}
		
		DisplaySalary(playerid);
		return 1;
	}*/
	if(dialogid == DIALOG_PAYCHECK)
	{
		if(response)
		{
			if(pData[playerid][pPaycheck] < 3600) return Error(playerid, "Sekarang belum waktunya anda mengambil paycheck.");
			
			new query[512];
			mysql_format(g_SQL, query, sizeof(query), "SELECT * FROM salary WHERE owner='%d' ORDER BY id ASC LIMIT 30", pData[playerid][pID]);
			mysql_query(g_SQL, query);
			new rows = cache_num_rows();
			if(rows) 
			{
				new list[2000], date[30], info[16], money, totalduty, gajiduty, totalsal, total, pajak, hasil;
				
				totalduty = pData[playerid][pOnDutyTime] + pData[playerid][pTaxiTime];
				for(new i; i < rows; ++i)
				{
					cache_get_value_name(i, "info", info);
					cache_get_value_name(i, "date", date);
					cache_get_value_name_int(i, "money", money);
					totalsal += money;
				}
				
				if(totalduty > 600)
				{
					gajiduty = 600;
				}
				else
				{
					gajiduty = totalduty;
				}
				total = gajiduty + totalsal;
				pajak = total / 100 * 10;
				hasil = total - pajak;
				
				format(list, sizeof(list), "Total gaji yang masuk ke rekening bank anda adalah: "LG_E"%s", FormatMoney(hasil));
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Paycheck", list, "Close", "");
				pData[playerid][pBankMoney] += hasil;
				Server_MinMoney(hasil);
				pData[playerid][pPaycheck] = 0;
				pData[playerid][pOnDutyTime] = 0;
				pData[playerid][pTaxiTime] = 0;
				mysql_format(g_SQL, query, sizeof(query), "DELETE FROM salary WHERE owner='%d'", pData[playerid][pID]);
				mysql_query(g_SQL, query);
			}
			else
			{
				new list[2000], totalduty, gajiduty, total, pajak, hasil;
				
				totalduty = pData[playerid][pOnDutyTime] + pData[playerid][pTaxiTime];
				
				if(totalduty > 600)
				{
					gajiduty = 600;
				}
				else
				{
					gajiduty = totalduty;
				}
				total = gajiduty;
				pajak = total / 100 * 10;
				hasil = total - pajak;
				
				format(list, sizeof(list), "Total gaji yang masuk ke rekening bank anda adalah: "LG_E"%s", FormatMoney(hasil));
				ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Paycheck", list, "Close", "");
				pData[playerid][pBankMoney] += hasil;
				Server_MinMoney(hasil);
				pData[playerid][pPaycheck] = 0;
				pData[playerid][pOnDutyTime] = 0;
				pData[playerid][pTaxiTime] = 0;
			}
		}
	}
	// Re-Update By GloryRP
	// Scripter : MrDNM A.K.A Hilman
	if(dialogid == DIALOG_SWEEPER)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		if(response)
		{
		    switch(listitem)
		    {
		        case 0:
		        {
		            if(pData[playerid][pSideJobTime] > 0)
					{
						Error(playerid, "Anda harus menunggu "GREY2_E"%d "WHITE_E"detik lagi.", pData[playerid][pSideJobTime]);
						RemovePlayerFromVehicle(playerid);
						SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
						return 1;
					}

					pData[playerid][pSideJob] = 1;
					SetPlayerCheckpoint(playerid, sweperpoint1, 3.0);
					InfoTD_MSG(playerid, 3000, "Follow the checkpoint!");
				}
				case 1:
				{
				    if(pData[playerid][pSideJobTime] > 0)
					{
						Error(playerid, "Anda harus menunggu "GREY2_E"%d "WHITE_E"detik lagi.", pData[playerid][pSideJobTime]);
						RemovePlayerFromVehicle(playerid);
						SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
						return 1;
					}

					pData[playerid][pSideJob] = 1;
					SetPlayerCheckpoint(playerid, swepermenengah1, 3.0);
					InfoTD_MSG(playerid, 3000, "Follow the checkpoint!");
				}
				case 2:
				{
				    if(pData[playerid][pSideJobTime] > 0)
					{
						Error(playerid, "Anda harus menunggu "GREY2_E"%d "WHITE_E"detik lagi.", pData[playerid][pSideJobTime]);
						RemovePlayerFromVehicle(playerid);
						SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
						return 1;
					}

					pData[playerid][pSideJob] = 1;
					SetPlayerCheckpoint(playerid, sweperpanjang1, 3.0);
					InfoTD_MSG(playerid, 3000, "Follow the checkpoint!");
				}
			}
		}
		else
		{
			RemovePlayerFromVehicle(playerid);
			SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
		}
	}
	if(dialogid == DIALOG_BUS)
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		if(response)
		{
			if(pData[playerid][pSideJobTime] > 0)
			{
				Error(playerid, "Anda harus menunggu "GREY2_E"%d "WHITE_E"detik lagi.", pData[playerid][pSideJobTime]);
				RemovePlayerFromVehicle(playerid);
				SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
				return 1;
			}
			
			pData[playerid][pSideJob] = 2;
			SetPlayerCheckpoint(playerid, buspoint1, 3.0);
			InfoTD_MSG(playerid, 3000, "Follow the checkpoint!");
		}
		else
		{
			RemovePlayerFromVehicle(playerid);
			SetTimerEx("RespawnPV", 3000, false, "d", vehicleid);
		}
	}
    return 1;
}
