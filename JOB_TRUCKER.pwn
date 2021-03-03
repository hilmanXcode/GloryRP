CreateJoinTruckPoint()
{
	//JOBS
	new strings[128];
	CreateDynamicPickup(1239, 23, -77.38, -1136.52, 1.07, -1);
	format(strings, sizeof(strings), "[TRUCKER JOBS]\n{FFFFFF}/joinjob to join");
	CreateDynamic3DTextLabel(strings, COLOR_YELLOW, -77.38, -1136.52, 1.07, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1); // truck
}

//Mission
GetRestockBisnis()
{
	new tmpcount;
	foreach(new id : Bisnis)
	{
	    if(bData[id][bRestock] == 1)
	    {
     		tmpcount++;
		}
	}
	return tmpcount;
}

ReturnRestockBisnisID(slot)
{
	new tmpcount;
	if(slot < 1 && slot > MAX_BISNIS) return -1;
	foreach(new id : Bisnis)
	{
	    if(bData[id][bRestock] == 1)
	    {
     		tmpcount++;
       		if(tmpcount == slot)
       		{
        		return id;
  			}
	    }
	}
	return -1;
}

//Hauling
GetRestockGStation()
{
	new tmpcount;
	foreach(new id : GStation)
	{
	    if(gsData[id][gsStock] < 7000)
	    {
     		tmpcount++;
		}
	}
	return tmpcount;
}

ReturnRestockGStationID(slot)
{
	new tmpcount;
	if(slot < 1 && slot > MAX_GSTATION) return -1;
	foreach(new id : GStation)
	{
	    if(gsData[id][gsStock] < 7000)
	    {
     		tmpcount++;
       		if(tmpcount == slot)
       		{
        		return id;
  			}
	    }
	}
	return -1;
}

//Mission Commands
CMD:mission(playerid, params[])
{
	if(pData[playerid][pJob] == 4 || pData[playerid][pJob2] == 4)
	{
		if(GetRestockBisnis() <= 0) return Error(playerid, "Mission sedang kosong.");
		new id, count = GetRestockBisnis(), mission[128], type[32], lstr[512];
		
		strcat(mission,"No\tBusID\tBusType\tBusName\n",sizeof(mission));
		Loop(itt, (count + 1), 1)
		{
			id = ReturnRestockBisnisID(itt);
			if(bData[id][bType] == 1)
			{
				type= "Fast Food";
			}
			else if(bData[id][bType] == 2)
			{
				type= "Market";
			}
			else if(bData[id][bType] == 3)
			{
				type= "Clothes";
			}
			else if(bData[id][bType] == 4)
			{
				type= "Ammunation";
			}
			else
			{
				type= "Unknow";
			}
			if(itt == count)
			{
				format(lstr,sizeof(lstr), "%d\t%d\t%s\t%s\n", itt, id, type, bData[id][bName]);	
			}
			else format(lstr,sizeof(lstr), "%d\t%d\t%s\t%s\n", itt, id, type, bData[id][bName]);
			strcat(mission,lstr,sizeof(mission));
		}
		ShowPlayerDialog(playerid, DIALOG_RESTOCK, DIALOG_STYLE_TABLIST_HEADERS,"Mission",mission,"Start","Cancel");
	}
	else return Error(playerid, "You are not trucker job.");
	return 1;
}

CMD:storeproduct(playerid, params[])
{
	if(pData[playerid][pJob] == 4 || pData[playerid][pJob2] == 4)
	{
		new bid = pData[playerid][pMission], vehicleid = GetPlayerVehicleID(playerid), carid = -1, total, Float:percent, pay, convert;
		if(bid == -1) return Error(playerid, "You dont have mission.");
		if(IsPlayerInRangeOfPoint(playerid, 4.8, bData[bid][bExtposX], bData[bid][bExtposY], bData[bid][bExtposZ]))
		{
			if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER && !IsATruck(vehicleid)) return Error(playerid, "Anda harus mengendarai truck.");
			if(VehProduct[vehicleid] < 1) return Error(playerid, "Product is empty in this vehicle.");
			total = VehProduct[vehicleid] * ProductPrice;
			percent = (total / 100) * 50;
			convert = floatround(percent, floatround_floor);
			pay = total + convert;
			bData[bid][bProd] += VehProduct[vehicleid];
			bData[bid][bMoney] -= pay;
			Info(playerid, "Anda menjual "RED_E"%d "WHITE_E"product dengan seharga "GREEN_E"%s", VehProduct[vehicleid], FormatMoney(pay));
			GivePlayerMoneyEx(playerid, pay);
			if((carid = Vehicle_Nearest(playerid)) != -1)
			{
				pvData[carid][cProduct] = 0;
				Info(playerid, "Anda mendapatkan uang 20 percent dari hasil stock product anda.");
			}
			VehProduct[vehicleid] = 0;
			pData[playerid][pMission] = -1;
		}
		else return Error(playerid, "Anda harus berada didekat dengan bisnis mission anda.");
	}
	else return Error(playerid, "You are not trucker job.");
	return 1;
}
/* New Update ! */
CMD:getcrate(playerid, params[])
{
    if(IsPlayerInRangeOfPoint(playerid, 2.5, 315.07, 926.53, 20.46))
	{
	    if(pData[playerid][pAdminDuty] == 1) return Error(playerid, "Kamu Sedang Duty Admin !");
	    if(pData[playerid][pJobTime] > 0) return Error(playerid, "Anda harus menunggu "GREY2_E"%d "WHITE_E"detik untuk bisa bekerja kembali.", pData[playerid][pJobTime]);
	    if(pData[playerid][pJob] == 4 || pData[playerid][pJob2] == 4)
	    {
	        new updatestock[500];
	        if(SedangAngkat[playerid] == 1) return Error(playerid, "Kamu Sedang Mengangkat Crate RawComponent");
	        if(Component < 100) return Error(playerid, "Tidak Ada Crate Saat Ini.");
	        new vehicleid =  GetPVarInt(playerid, "LastVehicleID");
	        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER && !IsATruck(vehicleid)) return Error(playerid, "Anda harus menaiki truck terlebih dahulu.");
//   			if(!IsATruck(playerid)) return Error(playerid, "Silahkan Naik Kendaraan Truck Terlebih Dahulu");
			if(pData[playerid][pCrateComponent] == 5) return Error(playerid, "Truck Sudah Mencapai Batas Maksimum");
			GetVehicleBoot(vehicleid, pData[playerid][pTruckerX], pData[playerid][pTruckerY], pData[playerid][pTruckerZ]);
		 	SetPlayerAttachedObject(playerid, 1 ,3052, 1,0.11,0.36,0.0,0.0,90.0);
		 	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.1, 1, 1, 1, 1, 1, 1);
	        Component -= 100;
	        format(updatestock, sizeof(updatestock), "[Miner]\n"WHITE_E"CrateRawComponent"LG_E"\n"LB_E"/getcrate");
			UpdateDynamic3DTextLabelText(CompText, COLOR_YELLOW, updatestock);
	//        TruckerCp[playerid] = CreateDynamicCP(pData[playerid][pTruckerX], pData[playerid][pTruckerY], pData[playerid][pTruckerZ], 3.0, .playerid = playerid);
	        SedangAngkat[playerid] = 1;
		}
		else return Error(playerid, "You are not trucker job");
 	}
 	else return Error(playerid, "Kamu Harus Berada di Tempat Pengambilan Crate");
	return 1;
}

CMD:loadcrate(playerid, params[])
{
	if(pData[playerid][pJob] == 4 || pData[playerid][pJob2] == 4)
	{
		if(SedangAngkat[playerid] == 0) return Error(playerid, "Kamu Tidak Sedang Mengangkat Crate!");
	    if(pData[playerid][pAdminDuty] == 1) return Error(playerid, "Kamu Sedang Duty Admin !");
		if(IsPlayerInAnyVehicle(playerid)) return Error(playerid, "Kamu Bisa Menggunakan Command Ini Hanya di luar kendaraan");
		if(IsPlayerInRangeOfPoint(playerid, 3.0, pData[playerid][pTruckerX], pData[playerid][pTruckerY], pData[playerid][pTruckerZ]))
		{
		    ApplyAnimation(playerid, "CARRY", "putdwn05", 4.1, 0, 1, 1, 0, 0, 1);
		    RemovePlayerAttachedObject(playerid, 1);
		    DisablePlayerCheckpoint(playerid);
		    SedangAngkat[playerid] = 0;
			pData[playerid][pCrateComponent]++;
            SendClientMessageEx(playerid, COLOR_RED, "[Truck]"YELLOW_E" Kamu Telah Memasukkan/Menaruh %d CrateRawComponent Ke Truck Mu ", pData[playerid][pCrateComponent]);
            SedangAngkat[playerid] = 0;
			new INI:File = INI_Open(UserPath(playerid));
			INI_SetTag(File, "data");
		    INI_WriteInt(File, "pCrateComponent", pData[playerid][pCrateComponent]);
		   	INI_Close(File);
		    return 1;
		}
	}
	else return Error(playerid, "You are not trucker job");
	return 1;
}
CMD:unloadcrate(playerid, params[])
{
	if(pData[playerid][pJob] == 4 || pData[playerid][pJob2] == 4)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
	    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER && !IsATruck(vehicleid)) return Error(playerid, "Anda harus mengendarai truck.");
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 797.6823, -617.5379, 16.3359))
		{
		    if(pData[playerid][pCrateComponent] == 0) return SendClientMessage(playerid, COLOR_RED, "[Trucker-Job]"YELLOW_E"Kamu Tidak Membawa Crate Di Dalam Truck Mu!");
//		    new updatestock[256];
		    if(pData[playerid][pCrateComponent] == 1)
		    {
//				new updatestock[300];
		        AddPlayerSalary(playerid, "Truck Corp.", 100);
				Info(playerid, "Truck.Co telah masuk ke pending salary anda!");
		        pData[playerid][pCrateComponent] = 0;
		        StockComp += 20;
//		        format(updatestock, sizeof(updatestock), "[Component Storage]\nComponent Available : %d\nComponent Price : $5\n'/buy' untuk membeli Komponen",StockComp);
//				UpdateDynamic3DTextLabelText(CompTextBuy, COLOR_YELLOW, updatestock);
				pData[playerid][pJobTime] = 600;
		        SaveStockComp();
		        Server_Save();
			}
			if(pData[playerid][pCrateComponent] == 2)
		    {
//		        new updatestock[300];
		        AddPlayerSalary(playerid, "Truck Corp.", 200);
				Info(playerid, "Truck.Co telah masuk ke pending salary anda!");
		        pData[playerid][pCrateComponent] = 0;
		        StockComp += 40;
//		        format(updatestock, sizeof(updatestock), "[Component Storage]\nComponent Available : %d\nComponent Price : $5\n'/buy' untuk membeli Komponen",StockComp);
//				UpdateDynamic3DTextLabelText(CompTextBuy, COLOR_YELLOW, updatestock);
				pData[playerid][pJobTime] = 600;
		        SaveStockComp();
		        Server_Save();
			}
			if(pData[playerid][pCrateComponent] == 3)
		    {
//		        new updatestock[300];
		        AddPlayerSalary(playerid, "Truck Corp.", 300);
				Info(playerid, "Truck.Co telah masuk ke pending salary anda!");
		        pData[playerid][pCrateComponent] = 0;
		        StockComp += 60;
//		        format(updatestock, sizeof(updatestock), "[Component Storage]\nComponent Available : %d\nComponent Price : $5\n'/buy' untuk membeli Komponen",StockComp);
//				UpdateDynamic3DTextLabelText(CompTextBuy, COLOR_YELLOW, updatestock);
				pData[playerid][pJobTime] = 600;
		        SaveStockComp();
		        Server_Save();
			}
			if(pData[playerid][pCrateComponent] == 4)
		    {
//		        new updatestock[300];
		        AddPlayerSalary(playerid, "Truck Corp.", 400);
				Info(playerid, "Truck.Co telah masuk ke pending salary anda!");
		        pData[playerid][pCrateComponent] = 0;
		        StockComp += 80;
//		        format(updatestock, sizeof(updatestock), "[Component Storage]\nComponent Available : %d\nComponent Price : $5\n'/buy' untuk membeli Komponen",StockComp);
//				UpdateDynamic3DTextLabelText(CompTextBuy, COLOR_YELLOW, updatestock);
				pData[playerid][pJobTime] = 600;
		        SaveStockComp();
		        Server_Save();
			}
			if(pData[playerid][pCrateComponent] == 5)
		    {
//		        new updatestock[300];
		        AddPlayerSalary(playerid, "Truck Corp.", 500);
				Info(playerid, "Truck.Co telah masuk ke pending salary anda!");
		        pData[playerid][pCrateComponent] = 0;
		        StockComp += 100;
//		        format(updatestock, sizeof(updatestock), "[Component Storage]\nComponent Available : %d\nComponent Price : $5\n'/buy' untuk membeli Komponen",StockComp);
//				UpdateDynamic3DTextLabelText(CompTextBuy, COLOR_YELLOW, updatestock);
				pData[playerid][pJobTime] = 600;
				pData[playerid][pCrateMessage] = 0;
		        SaveStockComp();
		        Server_Save();
			}
//			format(updatestock, sizeof(updatestock), "[Component Storage]\nComponent Available : %d\nComponent Price : $5\n/buy untuk membeli Komponen",StockComp);
//			UpdateDynamic3DTextLabelText(CompTextBuy, COLOR_YELLOW, updatestock);
		}
	}
	return 1;
}

/* Akhir Project Remake*/

//Hauling Commands
CMD:hauling(playerid, params[])
{
	if(pData[playerid][pJob] == 4 || pData[playerid][pJob2] == 4)
	{
		if(GetRestockGStation() <= 0) return Error(playerid, "Hauling sedang kosong.");
		new id, count = GetRestockGStation(), hauling[128], lstr[512];
		
		strcat(hauling,"No\tGas Station ID\tLocation\n",sizeof(hauling));
		Loop(itt, (count + 1), 1)
		{
			id = ReturnRestockGStationID(itt);
			if(itt == count)
			{
				format(lstr,sizeof(lstr), "%d\t%d\t%s\n", itt, id, GetLocation(gsData[id][gsPosX], gsData[id][gsPosY], gsData[id][gsPosZ]));	
			}
			else format(lstr,sizeof(lstr), "%d\t%d\t%s\n", itt, id, GetLocation(gsData[id][gsPosX], gsData[id][gsPosY], gsData[id][gsPosZ]));
			strcat(hauling,lstr,sizeof(hauling));
		}
		ShowPlayerDialog(playerid, DIALOG_HAULING, DIALOG_STYLE_TABLIST_HEADERS,"Hauling",hauling,"Start","Cancel");
	}
	else return Error(playerid, "You are not trucker job.");
	return 1;
}

CMD:storegas(playerid, params[])
{
	if(pData[playerid][pJob] == 4 || pData[playerid][pJob2] == 4)
	{
		new id = pData[playerid][pHauling], vehicleid = GetPlayerVehicleID(playerid), carid = -1, total, Float:percent, pay, convert;
		if(id == -1) return Error(playerid, "You dont have hauling.");
		if(IsPlayerInRangeOfPoint(playerid, 3.5, gsData[id][gsPosX], gsData[id][gsPosY], gsData[id][gsPosZ]))
		{
			if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER && !IsATruck(vehicleid)) return Error(playerid, "Anda harus mengendarai truck.");
			if(VehGasOil[vehicleid] < 1) return Error(playerid, "GasOil is empty in this vehicle.");
			total = VehGasOil[vehicleid] * GasOilPrice;
			percent = (total / 100) * 25;
			convert = floatround(percent, floatround_ceil);
			pay = total + convert;
			gsData[id][gsStock] += VehGasOil[vehicleid];
			Server_MinMoney(pay);
			Info(playerid, "Anda menjual "RED_E"%d "WHITE_E"liters gas oil dengan seharga "GREEN_E"%s", VehGasOil[vehicleid], FormatMoney(pay));
			GivePlayerMoneyEx(playerid, pay);
			if((carid = Vehicle_Nearest(playerid)) != -1)
			{
				pvData[carid][cGasOil] = 0;
				Info(playerid, "Anda mendapatkan uang 25 percent dari hasil stock liters gas oil anda.");
			}
			VehGasOil[vehicleid] = 0;
			pData[playerid][pHauling] = -1;
			GStation_Refresh(id);
			GStation_Save(id);
		}
		else return Error(playerid, "Anda harus berada didekat dengan gas oil hauling anda.");
	}
	else return Error(playerid, "You are not trucker job.");
	return 1;
}
