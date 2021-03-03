//======== Sweper ===========
// Jarak Pendek //
#define sweperpoint1 1300.1277,-1746.0057,13.3828
#define sweperpoint2 1198.3400,-1706.6813,13.5469
#define sweperpoint3 1040.1805,-1695.5941,13.3828
#define sweperpoint4 1041.1193,-1559.6353,13.3828
#define sweperpoint5 1065.2335,-1408.1826,13.3828
#define sweperpoint6 1175.8345,-1407.7174,13.3828
#define sweperpoint7 1328.8345,-1408.1843,13.3828
#define sweperpoint8 1344.8881,-1436.1655,13.3828
#define sweperpoint9 1295.4325,-1557.7495,13.3828
#define sweperpoint10 1295.0022,-1698.7495,13.3828
#define sweperpoint11 1301.3141,-1819.2825,13.3828
#define sweperpoint12 1302.6243,-1863.4994,13.5469

// Jarak Menengah //
#define swepermenengah1 1322.3806, -1855.4418, 13.3828 // ROUTE MENENGAH 1
#define swepermenengah2 1436.2692, -1874.9744, 13.3828 // ROUTE MENENGAH 2
#define swepermenengah3 1596.8768, -1874.3141, 13.3828 // ROUTE MENENGAH 3
#define swepermenengah4 1692.3854, -1819.1548, 13.3828 // ROUTE MENENGAH 4
#define swepermenengah5 1690.3802, -1591.4683, 13.3791 // ROUTE MENENGAH 5
#define swepermenengah6 1442.8287, -1590.1929, 13.3828 // ROUTE MENENGAH 6
#define swepermenengah7 1316.1829, -1568.7970, 13.3828 // ROUTE MENENGAH 7
#define swepermenengah8 1358.0167, -1438.5800, 13.3906 // ROUTE MENENGAH 8
#define swepermenengah9 1359.3069, -1232.0049, 13.3924 // ROUTE MENENGAH 9
#define swepermenengah10 1359.2267, -1157.6266, 23.6498 // ROUTE MENENGAH 10
#define swepermenengah11 1340.7286, -1158.4944, 23.6734 // ROUTE MENENGAH 11
#define swepermenengah12 1339.9044, -1378.3763, 13.4903 // ROUTE MENENGAH 12
#define swepermenengah13 1310.9677, -1509.3569, 13.3906 // ROUTE MENENGAH 13
#define swepermenengah14 1295.4655, -1705.0330, 13.3828 // ROUTE MENENGAH 14
#define swepermenengah15 1295.3354, -1826.8168, 13.3828 // ROUTE MENENGAH 15
#define swepermenengah16 1302.3849, -1862.3517, 13.5801 // ROUTE MENENGAH 16

// Jarak Jauh
#define sweperpanjang1 1285.4740, -1850.2220, 13.3906 // JARAK JAUH 1
#define sweperpanjang2 1206.8562, -1849.7533, 13.3828 // JARAK JAUH 2
#define sweperpanjang3 1065.8033, -1849.4417, 13.3984 // JARAK JAUH 3
#define sweperpanjang4 978.0881, -1781.6448, 14.0904 // JARAK JAUH 4
#define sweperpanjang5 812.6441, -1767.0714, 13.3984 // JARAK JAUH 5
#define sweperpanjang6 647.6352, -1731.8026, 13.6689 // JARAK JAUH 6
#define sweperpanjang7 637.3500, -1705.3087, 14.5459 // JARAK JAUH 7
#define sweperpanjang8 639.8298, -1570.1671, 15.4523 // JARAK JAUH 8
#define sweperpanjang9 640.4358, -1430.0045, 13.8880 // JARAK JAUH 9
#define sweperpanjang10 639.3685, -1265.8976, 16.6179 // JARAK JAUH 10
#define sweperpanjang11 632.1489, -1217.5557, 18.1094 // JARAK JAUH 11
#define sweperpanjang12 716.2875, -1117.0114, 18.2018 // JARAK JAUH 12
#define sweperpanjang13 825.7778, -1050.4944, 25.1225 // JARAK JAUH 13
#define sweperpanjang14 951.0336, -975.8700, 38.6870 // JARAK JAUH 14
#define sweperpanjang15 1113.1478, -957.6995, 42.5669 // JARAK JAUH 15
#define sweperpanjang16 1303.7998, -934.4067, 39.2879 // JARAK JAUH 16
#define sweperpanjang17 1360.3311, -945.7771, 34.1875 // JARAK JAUH 17
#define sweperpanjang18 1359.0056, -954.2535, 34.1561 // JARAK JAUH 18
#define sweperpanjang19 1351.4233, -1054.0005, 26.6245 // JARAK JAUH 19
#define sweperpanjang20 1340.0039, -1168.3199, 23.7203 // JARAK JAUH 20
#define sweperpanjang21 1339.8823, -1280.1665, 13.3828 // JARAK JAUH 21
#define sweperpanjang22 1340.2689, -1417.2869, 13.3828 // JARAK JAUH 22
#define sweperpanjang23 1295.9324, -1560.3309, 13.3906 // JARAK JAUH 23
#define sweperpanjang24 1294.9559, -1681.8401, 13.3828 // JARAK JAUH 24
#define sweperpanjang25 1294.8555, -1820.0055, 13.3828 // JARAK JAUH 25
#define sweperpanjang26 1301.9388, -1860.5156, 13.5469 // JARAK JAUH 26

new SweepVeh[5];

AddSweeperVehicle()
{
	SweepVeh[0] = AddStaticVehicleEx(574, 1303.5151, -1878.5725, 14.0000, 0.0000, 1, 1, VEHICLE_RESPAWN);
	SweepVeh[1] = AddStaticVehicleEx(574, 1301.2148, -1878.5293, 14.0000, 0.0000, 1, 1, VEHICLE_RESPAWN);
	SweepVeh[2] = AddStaticVehicleEx(574, 1298.8950, -1878.4896, 14.0000, 0.0000, 1, 1, VEHICLE_RESPAWN);
	//SweepVeh[3] = AddStaticVehicleEx(574, 1295.0103, -1878.3979, 14.0000, 0.0000, 1, 1, VEHICLE_RESPAWN);
	//SweepVeh[4] = AddStaticVehicleEx(574, 1291.9260, -1878.4087, 14.0000, 0.0000, 1, 1, VEHICLE_RESPAWN);
}

IsASweeperVeh(carid)
{
	for(new v = 0; v < sizeof(SweepVeh); v++) {
	    if(carid == SweepVeh[v]) return 1;
	}
	return 0;
}
